#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name            = @{ type = "str"; required = $true }
        description     = @{ type = "str" }
        include_pattern = @{ type = "list"; elements = "str"; required = $true }
        exclude_pattern = @{ type = "list"; elements = "str" }
        state           = @{ type = "str"; choices = "absent", "present"; default = "present" }
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

# Create file group if it not exists
$fileGroup = Get-FsrmFileGroup -Name $module.Params.name -ErrorAction SilentlyContinue

if ($null -eq $fileGroup -and $present) {
    try {
        New-FsrmFileGroup `
            -Name $module.Params.name `
            -Description $module.Params.description `
            -IncludePattern $module.Params.include_pattern `
            -ExcludePattern $module.Params.exclude_pattern `
            -WhatIf:$module.CheckMode `
        | Out-Null
    }
    catch {
        $module.FailJson("Failed to create file group '$($module.Params.name)'.", $_)
    }
    $module.Result.changed = $true
    $module.ExitJson()
}

# Remove file group if state == absent
if ($fileGroup -and -not $present) {
    try {
        Remove-FsrmFileGroup `
            -Name $module.Params.name `
            -confirm:$false `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to remove file group '$($module.Params.name)'.", $_)
    }
    $module.Result.changed = $true
    $module.ExitJson()
}

# Check description
if ($module.Params.description -and ($fileGroup.Description -ne $module.Params.description)) {
    try {
        Set-FsrmFileGroup `
            -Name $module.Params.name `
            -Description $module.Params.description `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to modify file group description.", $_)
    }
    $module.Result.changed = $true
}

# Check included patterns
if ($module.Params.include_pattern -and (Compare-Object -ReferenceObject $module.Params.include_pattern -DifferenceObject $fileGroup.IncludePattern)) {
    try {
        Set-FsrmFileGroup `
            -Name $module.Params.name `
            -IncludePattern $module.Params.include_pattern `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to modify file group included patterns.", $_)
    }
    $module.Result.changed = $true
}

# Check excluded patterns
if ($module.Params.exclude_pattern -and (Compare-Object -ReferenceObject $module.Params.exclude_pattern -DifferenceObject $fileGroup.ExcludePattern)) {
    try {
        Set-FsrmFileGroup `
            -Name $module.Params.name `
            -ExcludePattern $module.Params.exclude_pattern `
            -WhatIf:$module.CheckMode
    }
    catch {
        $module.FailJson("Failed to modify file group excluded patterns.", $_)
    }
    $module.Result.changed = $true
}

$module.ExitJson()