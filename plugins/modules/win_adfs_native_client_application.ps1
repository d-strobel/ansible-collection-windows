#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel), Yasmin Hinel (@seasxlticecream)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        group_identifier = @{ type = "str"; required = $true }
        name             = @{ type = "str" }
        description      = @{ type = "str" }
        redirect_uri     = @{ type = "list"; elements = "str" }
        logout_uri       = @{ type = "str"; default = "" }
        state            = @{ type = "str"; choices = "absent", "present"; default = "present" }
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
    }
    "present" {
        $present = $true
    }
}

# Set the Name to Group Identifier if not present
if ($null -eq $module.Params.name) {
    $module.Params.name = "$($module.Params.group_identifier) - Native Client Application"
}

# Ensure powershell module is loaded
if(-not (Import-AdfsPowershellModule)) {
    $module.FailJson("Failed to load PowerShell-Module for ADFS")
}

# Search for native application group
$adfsNativeClientApplication = Get-AdfsNativeClientApplication -ApplicationGroupIdentifier $module.Params.group_identifier -ErrorAction SilentlyContinue

# Create native client application if it not exists
if ($null -eq $adfsNativeClientApplication -and $present) {
    # Application identifier
    $adfsApplicationIdentifier = (New-Guid).Guid
    $module.Result.application_identifier = $adfsApplicationIdentifier

    try {
        Add-AdfsNativeClientApplication `
            -ApplicationGroupIdentifier $module.Params.group_identifier `
            -Name $module.Params.name `
            -Identifier $adfsApplicationIdentifier `
            -RedirectUri $module.Params.redirect_uri `
            -Description $module.Params.description `
            -LogoutUri $adfsLogoutUri `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to add native client application.", $_)
    }
    $module.Result.changed = $true
    $module.ExitJson()
}
elseif ($null -eq $adfsNativeClientApplication -and -not $present) {
    $module.ExitJson()
}

# Set application_identifier
$adfsApplicationIdentifier = $adfsNativeClientApplication.Identifier
$module.Result.application_identifier = $adfsApplicationIdentifier

# Remove native client application if state == absent
if ($adfsNativeClientApplication -and -not $present) {
    try {
        Remove-AdfsNativeClientApplication `
            -TargetIdentifier $adfsApplicationIdentifier `
            -Confirm:$false `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to remove native client application.", $_)
    }

    $module.Result.changed = $true
    $module.ExitJson()
}

# Check if anything must be changed
if (
    ($adfsNativeClientApplication.Description -ne $module.Params.description) `
        -or ($adfsNativeClientApplication.Name -ne $module.Params.name) `
        -or ($adfsNativeClientApplication.LogoutUri -ne $adfsLogoutUri) `
        -or (Compare-Object -ReferenceObject $adfsNativeClientApplication.RedirectUri -DifferenceObject $module.Params.redirect_uri)
) {
    # Apply changes
    try {
        Set-AdfsNativeClientApplication `
            -TargetIdentifier $adfsApplicationIdentifier `
            -Description $module.Params.description `
            -Name $module.Params.name `
            -RedirectUri $module.Params.redirect_uri `
            -LogoutUri $adfsLogoutUri `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to modify native client application description.", $_)
    }
    $module.Result.changed = $true
}

$module.ExitJson()