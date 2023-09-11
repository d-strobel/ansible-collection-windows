#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        scope       = @{ type = "str"; required = $true }
        start_range = @{ type = "str"; required = $true }
        end_range   = @{ type = "str"; required = $true }
        state       = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }

    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$scopeId = $module.Params.scope
$startRange = $module.Params.start_range
$endRange = $module.Params.end_range
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get exclusion
$dhcpServerExclusion = Get-DhcpServerv4ExclusionRange -ScopeId $scopeId -ErrorAction SilentlyContinue | Where-Object {
    ($_.StartRange -eq $startRange) -and ($_.EndRange -eq $endRange)
}

# Early exit
if (($null -eq $dhcpServerExclusion) -and ($state -eq "absent")) {
    $module.ExitJson()
}

# Remove exclusion
if (($null -ne $dhcpServerExclusion) -and ($state -eq "absent")) {
    try {
        Remove-DhcpServerv4ExclusionRange `
            -ScopeId $scopeId `
            -StartRange $startRange `
            -EndRange $endRange `
            -Confirm:$false `
        | Out-Null

        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove the dhcp exclusion '$startRange - $endRange'", $Error[0])
    }
}

# New exclusion
if (($null -eq $dhcpServerExclusion) -and ($state -eq "present")) {
    try {
        Add-Dhcpserverv4ExclusionRange `
            -ScopeId $scopeId `
            -StartRange $startRange `
            -EndRange $endRange `
            -Confirm:$false `
        | Out-Null

        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to add the exclusion '$startRange - $endRange'", $Error[0])
    }
}

$module.ExitJson()