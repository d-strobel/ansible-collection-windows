#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel), Yasmin Hinel (@seasxlticecream)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType
#AnsibleRequires -PowerShell ansible_collections.d_strobel.windows_adfs.plugins.module_utils.Helper

$spec = @{
    options             = @{
        name             = @{ type = "str" }
        group_identifier = @{ type = "str"; required = $true }
        description      = @{ type = "str" }
        state            = @{ type = "str"; choices = "absent", "present", "disabled"; default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# ErrorAction
$ErrorActionPreference = 'Stop'

# State
switch ($module.Params.state) {
    "absent" {
        $present = $false
        $disabled = $false
    }
    "present" {
        $present = $true
        $disabled = $false
    }
    "disabled" {
        $present = $true
        $disabled = $true
    }
}

# Set the Name to Group Identifier if not present
if ($null -eq $module.Params.name) {
    $module.Params.name = $module.Params.group_identifier
}

# Always return group identifier
$module.Result.group_identifier = $module.Params.group_identifier

# Ensure powershell module is loaded
if(-not (Import-AdfsPowershellModule)) {
    $module.FailJson("Failed to load PowerShell-Module for ADFS")
}

# Search for application group
$applicationGroup = Get-AdfsApplicationGroup -ApplicationGroupIdentifier $module.Params.group_identifier -ErrorAction SilentlyContinue

# Create application group if it not exists
if ($null -eq $applicationGroup -and $present) {
    try {
        New-AdfsApplicationGroup `
            -Name $module.Params.name `
            -ApplicationGroupIdentifier $module.Params.group_identifier `
            -Description $module.Params.description `
            -Disabled:$disabled `
            -WhatIf:$module.CheckMode `
        | Out-Null
    }
    catch {
        $module.FailJson("Failed to create application group '$($module.Params.name)'.", $_)
    }
    $module.Result.changed = $true
    $module.ExitJson()
}
elseif ($null -eq $applicationGroup -and -not $present) {
    $module.ExitJson()
}

# Remove application group if state == absent
if ($applicationGroup -and -not $present) {
    try {
        Remove-AdfsApplicationGroup `
            -TargetApplicationGroupIdentifier $module.Params.group_identifier `
            -Confirm:$false `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to remove application group '$($module.Params.name)'.", $_)
    }
    $module.Result.changed = $true
    $module.ExitJson()
}

# Check description
if ($module.Params.description -and ($applicationGroup.Description -ne $module.Params.description)) {
    try {
        Set-AdfsApplicationGroup `
            -TargetApplicationGroupIdentifier $module.Params.group_identifier `
            -Description $module.Params.description `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to modify application group description.", $_)
    }
    $module.Result.changed = $true
}

# Check name
if ($module.Params.name -and ($applicationGroup.Name -ne $module.Params.name)) {
    try {
        Set-AdfsApplicationGroup `
            -TargetApplicationGroupIdentifier $module.Params.group_identifier `
            -Name $module.Params.name `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to modify application group name.", $_)
    }
    $module.Result.changed = $true
}

# disable group
if ($disabled -and ($applicationGroup.Enabled)) {
    try {
        Disable-AdfsApplicationGroup `
            -TargetApplicationGroupIdentifier $module.Params.group_identifier `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to disable application group.", $_)
    }
    $module.Result.changed = $true
}
# enable group
elseif (-not $disabled -and ($applicationGroup.Enabled -eq $false)) {
    try {
        Enable-AdfsApplicationGroup `
            -TargetApplicationGroupIdentifier $module.Params.group_identifier `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to enable application group.", $_)
    }
    $module.Result.changed = $true
}

$module.ExitJson()