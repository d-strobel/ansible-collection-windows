#!powershell

# Copyright: (c) 2023, Dustin Strobel (@d-strobel), Yasmin Hinel (@yahikii), Pascal Breuning (@raumdonut)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        update_location        = @{ type = "str"; choices = "local", "microsoft_update"; default = "local"}
        state                  = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$updatelocation = $module.Params.update_location
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wsus config
try {
    $wsus = Get-WsusServer
    $configuration = $wsus.GetConfiguration()
}
catch {
    $module.FailJson("Failed to get WSUS configuration", $Error[0])
}
if (($updatelocation -eq "local") -and ($state -eq "absent")) {
    try {
        $configuration.HostBinariesOnMicrosoftUpdate = $false
        $configuration.Save()
    }
    catch {
        $module.FailJson("Failed to set updatefile location to local", $Error[0])
    }
}
elseif (($updatelocation -eq "local") -and ($state -ne "absent")) {
    try {
        $configuration.HostBinariesOnMicrosoftUpdate = $false
        $configuration.Save()
    }
    catch {
        $module.FailJson("Failed to set updatefile location to local", $Error[0])
    }
}
elseif (($updatelocation -eq "microsoft_update") -and ($state -eq "absent")) {
    try {
        $configuration.HostBinariesOnMicrosoftUpdate = $false
        $configuration.Save()
    }
    catch {
        $module.FailJson("Failed to set updatefile location to microsoft_update", $Error[0])
    }
}
elseif (($updatelocation -eq "microsoft_update") -and ($state -ne "absent")) {
    try {
        $configuration.HostBinariesOnMicrosoftUpdate = $true
        $configuration.Save()
    }
    catch {
        $module.FailJson("Failed to set updatefile location to microsoft_update", $Error[0])
    }
}
$module.ExitJson()