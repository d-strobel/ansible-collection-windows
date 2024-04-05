#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        option_id     = @{ type = "int"; required = $true }
        scope_id      = @{ type = "str" }
        reserved_ip   = @{ type = "str" }
        value         = @{ type = "list"; elements = "str"; required = $true }
        state         = @{ type = "str"; choices = "absent", "present" ; default = "present" }
    }

    mutually_exclusive = @(
      , @("scope_id", "reserved_ip")
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$optionID = $module.Params.option_id
$scopeID = $module.Params.scope_id
$reservedIP = $module.Params.reserved_ip
$value = $module.Params.value
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get option value for specific input
if ($scopeID) {
    # Need try/catch block to handle non-existing scope.
    # This seems like an issue with the ErrorAction handler.
    try {
      $dhcpServerOptionValue = Get-DhcpServerv4OptionValue -OptionID $optionID -ScopeId $scopeID -ErrorAction SilentlyContinue
    }
    catch {}
}
elseif ($reservedIP) {
    # Need try/catch block to handle non-existing reservations.
    # This seems like an issue with the ErrorAction handler.
    try {
      $dhcpServerOptionValue = Get-DhcpServerv4OptionValue -OptionID $optionID -ReservedIP $reservedIP -ErrorAction SilentlyContinue
    }
    catch {}
}
else { 
  $dhcpServerOptionValue = Get-DhcpServerv4OptionValue -OptionID $optionID -ErrorAction SilentlyContinue
}

# Early exit
if (($null -eq $dhcpServerOptionValue) -and ($state -eq "absent")) {
    $module.ExitJson()
}

# Remove option value
if (($null -ne $dhcpServerOptionValue) -and ($state -eq "absent")) {
    try {
        if ($scopeID) {
            Remove-DhcpServerv4OptionValue -OptionID $optionID -ScopeId $scopeID -Confirm:$false -WhatIf:$module.CheckMode | Out-Null
        }
        elseif ($reservedIP) {
            Remove-DhcpServerv4OptionValue -OptionID $optionID -ReservedIP $reservedIP -Confirm:$false -WhatIf:$module.CheckMode | Out-Null
        }
        else {
            Remove-DhcpServerv4OptionValue -OptionID $optionID -Confirm:$false -WhatIf:$module.CheckMode | Out-Null
        }
        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove DHCP-OptionValue.", $_)
    }
}

# New option value
if ((($null -eq $dhcpServerOptionValue) -and ($state -eq "present")) -or (Compare-Object -ReferenceObject $dhcpServerOptionValue.Value -DifferenceObject $value)) {
    try {
        if ($scopeID) {
            Set-DhcpServerv4OptionValue -OptionID $optionID -ScopeId $scopeID -Value $value -Force -WhatIf:$module.CheckMode | Out-Null
        }
        elseif ($reservedIP) {
            Set-DhcpServerv4OptionValue -OptionID $optionID -ReservedIP $reservedIP -Value $value -Force -WhatIf:$module.CheckMode | Out-Null
        }
        else {
            Set-DhcpServerv4OptionValue -OptionID $optionID -Value $value -Force -WhatIf:$module.CheckMode | Out-Null
        }
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set DHCP-OptionValue.", $_)
    }
}

$module.ExitJson()
