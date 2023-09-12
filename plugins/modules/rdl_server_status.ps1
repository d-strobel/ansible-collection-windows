#!powershell

# Copyright: (c) 2023, Dustin Strobel (@d-strobel), Yasmin Hinel (@yahikii)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        method       = @{ type = "str"; choices = "automatic", "manual"; default = "automatic" }
        confirm_code = @{ type = "str" }
        state        = @{ type = "str"; choices = "activated", "deactivated"; default = "activated" }
    }
    required_if         = @(
        , @("method", "manual", @("confirm_code"))
    )
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$method = $module.Params.method
$confirmCode = $module.Params.confirm_code
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Check confirm code
if($confirmCode){
    if($confirmCode -notmatch "^[a-zA-Z0-9]{35}$"){
        $module.FailJson("The confirm_code parameter must be a 35-character alphanumeric string that cannot include hyphens")
    }
}

# Create wmi class
try {
    $wmiClass = ([wmiclass]"\\localhost\root\cimv2:Win32_TSLicenseServer")
}
catch {
    $module.FailJson("Failed to create wmi class 'Win32_TSLicenseServer'", $Error[0])
}

# Get server activation status
try {
    $serverActivationStatus = $wmiClass.GetActivationStatus()
}
catch {
    $module.FailJson("Failed to retrieve activation status", $Error[0])
}

# Early exit
if (($serverActivationStatus.ActivationStatus -eq 1) -and ($state -eq "deactivated")) {
    $module.ExitJson()
}

# Absent
if (($serverActivationStatus.ActivationStatus -eq 0) -and ($state -eq "deactivated")) {
    if ($method -eq "automatic") {
        try {
            $result = $wmiClass.DeactivateServerAutomatic()
            if ($result.ActivationStatus -ne 1) {
                $module.FailJson("Failed to deactivate the license server", $Error[0])
            }
        }
        catch {
            $module.FailJson("Failed to deactivate the license server", $Error[0])
        }
    }
    else {
        try {
            $result = $wmiClass.DeactivateServer($confirmCode)
            if ($result.ActivationStatus -ne 1) {
                $module.FailJson("Failed to deactivate the license server", $Error[0])
            }
        }
        catch {
            $module.FailJson("Failed to deactivate the license server", $Error[0])
        }
    }
    $module.ExitJson()
}

# Present
if (($serverActivationStatus.ActivationStatus -eq 1) -and ($state -eq "activated")) {
    if ($method -eq "automatic") {
        try {
            $result = $wmiClass.ActivateServerAutomatic()
            if ($result.ActivationStatus -ne 0) {
                $module.FailJson("Failed to activate the license server", $Error[0])
            }
        }
        catch {
            $module.FailJson("Failed to activate the license server", $Error[0])
        }
    }
    else {
        try {
            $result = $wmiClass.ActivateServer($confirmCode)
            if ($result.ActivationStatus -ne 0) {
                $module.FailJson("Failed to activate the license server", $Error[0])
            }
        }
        catch {
            $module.FailJson("Failed to activate the license server", $Error[0])
        }
    }
    $module.ExitJson()
}

# Reactivate
try {
    $licenseID = $wmiClass.GetLicenseServerId()
}
catch {
    $module.FailJson("Failed to retrieve license server id", $Error[0])
}

if ($licenseID.sLicenseServerId -ne $confirmCode) {
    try {
        $result = $wmiClass.ReactivateServer()
        if ($result.ActivationStatus -ne 0) {
            $module.FailJson("Failed to reactivate the license server", $Error[0])
        }
    }
    catch {
        $module.FailJson("Failed to reactivate the license server", $Error[0])
    }
    $module.ExitJson()
}

$module.ExitJson()