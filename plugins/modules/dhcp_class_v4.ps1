#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name        = @{ type = "str"; required = $true }
        data        = @{ type = "str" }
        description = @{ type = "str" }
        type        = @{ type = "str"; choices = "user", "vendor"; required = $true }
        state       = @{ type = "str"; choices = "absent", "present" ; default = "present" }
    }

    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$name = $module.Params.name
$data = $module.Params.data
$description = $module.Params.description
$type = $module.Params.type
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get classes
$dhcpServerClass = Get-DhcpServerv4Class -Type $type -Name $name -ErrorAction SilentlyContinue

# Early exit
if (($null -eq $dhcpServerClass) -and ($state -eq "absent")) {
    $module.ExitJson()
}

# Remove class
if (($null -ne $dhcpServerClass) -and ($state -eq "absent")) {
    try {
        Remove-DhcpServerv4Class -Type $type -Name $name -Confirm:$false | Out-Null
        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove the $type class '$name'", $Error[0])
    }
}

# New class
if (($null -eq $dhcpServerClass) -and ($state -eq "present")) {
    try {
        Add-DhcpServerv4Class `
            -Name $name `
            -Type $type `
            -Data $data `
            -Description $description `
            -Confirm:$false

        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to add the $type class '$name'", $Error[0])
    }
}

# Compare changes
if (
    ($dhcpServerClass.Data -ne $data) -or
    ($dhcpServerClass.Description.Trim() -ne $description)
) {
    try {
        Set-DhcpServerv4Class `
            -Name $name `
            -Type $type `
            -Data $data `
            -Description $description `
            -Confirm:$false

        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set changed parameters for $type class '$name'", $Error[0])
    }
}

$module.ExitJson()