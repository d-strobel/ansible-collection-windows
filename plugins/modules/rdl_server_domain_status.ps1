#!powershell

# Copyright: (c) 2023, Dustin Strobel (@d-strobel), Yasmin Hinel (@yahikii)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        domain = @{ type = "str"; required = $true }
        state  = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$domain = $module.Params.domain
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wmi class
try {
    $wmiClass = ([wmiclass]"\\localhost\root\cimv2:Win32_TSLicenseServer")
}
catch {
    $module.FailJson("Failed to get wmi class 'Win32_TSLicenseServer'", $Error[0])
}

# Get server domain status
try {
    $serverDomainStatus = $wmiClass.IsLSinTSLSGroup($domain)
}
catch {
    $module.FailJson("Failed to retrieve server domain status", $Error[0])
}

# Early exit
if ((-not $serverDomainStatus.IsMember) -and ($state -eq "absent")) {
    $module.ExitJson()
}

# Absent
if (($serverDomainStatus.IsMember) -and ($state -eq "absent")) {
    try {
        $result = $wmiClass.RemoveLSfromTSLSGroup()
        if ($result.ReturnValue -ne 0) {
            $module.FailJson("Failed to remove the license server from the domain")
        }
    }
    catch {
        $module.FailJson("Failed to remove the license server from the domain", $Error[0])
    }

    $module.ExitJson()
}

# Present
if ((-not $serverDomainStatus.IsMember) -and ($state -eq "present")) {
    try {
        $result = $wmiClass.AddLStoTSLSGroup()
        if ($result.ReturnValue -ne 0) {
            $module.FailJson("Failed to add the license server to the domain")
        }
    }
    catch {
        $module.FailJson("Failed to add the license server to the domain", $Error[0])
    }

    $module.ExitJson()
}

$module.ExitJson()