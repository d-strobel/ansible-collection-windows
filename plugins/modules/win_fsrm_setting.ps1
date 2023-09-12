#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        smtp_server         = @{ type = "str" }
        admin_email_address = @{ type = "str" }
        from_email_address  = @{ type = "str" }
        state               = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# ErrorAction
$ErrorActionPreference = 'Stop'

# State
if ($module.Params.state -eq "present") {
    $present = $true
}
else {
    $present = $false
}

# Ensure powershell module is loaded
$fsrm_module = "FileServerResourceManager"

try {
    if ($null -eq (Get-Module $fsrm_module -ErrorAction SilentlyContinue)) {
        Import-Module $fsrm_module
    }
}
catch {
    $module.FailJson("Failed to load PowerShell module $fsrm_module.", $_)
}

# Get fsrm settings
try {
    $fsrmSettings = Get-FsrmSetting
}
catch {
    $module.FailJson("Failed to get FSRM-Settings.", $_)
}

# SMTP server
if ($module.Params.smtp_server) {
    if (($fsrmSettings.SmtpServer -ne $module.Params.smtp_server) -and $present) {
        try {
            Set-FsrmSetting -SmtpServer $module.Params.smtp_server -WhatIf:$module.CheckMode
        }
        catch {
            $module.FailJson("Failed to set SMTP-Server to '$($module.Params.smtp_server)'.", $_)
        }
        $module.Result.changed = $true
    }
    elseif (-not $present) {
        try {
            Set-FsrmSetting -SmtpServer $null -WhatIf:$module.CheckMode
        }
        catch {
            $module.FailJson("Failed to remove SMTP-Server.", $_)
        }
        $module.Result.changed = $true
    }
}

# Admin email
if ($module.Params.admin_email_address) {
    if (($fsrmSettings.AdminEmailAddress -ne $module.Params.admin_email_address) -and $present) {
        try {
            Set-FsrmSetting -AdminEmailAddress $module.Params.admin_email_address -WhatIf:$module.CheckMode
        }
        catch {
            $module.FailJson("Failed to set Admin E-Mail address to '$($module.Params.admin_email_address)'.", $_)
        }
        $module.Result.changed = $true
    }
    elseif (-not $present) {
        try {
            Set-FsrmSetting -AdminEmailAddress $null -WhatIf:$module.CheckMode
        }
        catch {
            $module.FailJson("Failed to remove 'Admin E-Mail address'.", $_)
        }
        $module.Result.changed = $true
    }
}

# From email
if ($module.Params.from_email_address) {
    if (($fsrmSettings.FromEmailAddress -ne $module.Params.from_email_address) -and $present) {
        try {
            Set-FsrmSetting -FromEmailAddress $module.Params.from_email_address -WhatIf:$module.CheckMode
        }
        catch {
            $module.FailJson("Failed to set From E-Mail address to '$($module.Params.from_email_address)'.", $_)
        }
        $module.Result.changed = $true
    }
    elseif (-not $present) {
        try {
            Set-FsrmSetting -FromEmailAddress $null -WhatIf:$module.CheckMode
        }
        catch {
            $module.FailJson("Failed to remove 'From E-Mail address'.", $_)
        }
        $module.Result.changed = $true
    }
}

# Always return all settings that can be set
$module.Result.settings = Get-FsrmSetting | Select-Object -Property AdminEmailAddress, SmtpServer, FromEmailAddress

# Return
$module.ExitJson()