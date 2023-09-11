#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name  = @{ type = "str"; required = $true }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$name = $module.Params.name
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wsus config
try {
    $wsus = Get-WsusServer
}
catch {
    $module.FailJson("Failed to get WSUS configuration", $Error[0])
}

try {
    $targetGroup = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq $name }
}
catch {
    $module.FailJson("Failed to get computer target group", $Error[0])
}

if (($null -ne $targetGroup) -and ($state -eq "absent")) {
    try {
        $targetGroup.Delete()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove computer target group $targetGroup", $Error[0])
    }

}
elseif (($null -eq $targetGroup) -and ($state -eq "present")) {
    try {
        $targetGroup = $wsus.CreateComputerTargetGroup($name)
        $module.Result.id = $targetGroup.Id
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to create computer target group $name", $Error[0])
    }
}
elseif (($null -ne $targetGroup) -and ($state -eq "present")) {
    $module.Result.id = $targetGroup.Id
}

$module.ExitJson()