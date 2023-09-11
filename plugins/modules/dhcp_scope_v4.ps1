#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        scope       = @{ type = "str"; required = $true }
        name        = @{ type = "str" }
        description = @{ type = "str" }
        start_range = @{ type = "str"; required = $true }
        end_range   = @{ type = "str"; required = $true }
        subnet_mask = @{ type = "str"; required = $true }
        type        = @{ type = "str"; choices = "dhcp", "bootp", "both"; default = "dhcp" }
        state       = @{ type = "str"; choices = "absent", "present", "inactive"; default = "present" }
    }

    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$scopeId = $module.Params.scope
$name = $module.Params.name
$description = $module.Params.description
$startRange = $module.Params.start_range
$endRange = $module.Params.end_range
$subnetMask = $module.Params.subnet_mask
$type = $module.Params.type
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Check scope
[IPAddress]$scopeCalculator = (([IPAddress]$startRange).Address -band ([IPAddress]$subnetMask).Address)
$validScope = $scopeCalculator.IPAddressToString

if ($scopeCalculator.IPAddressToString -ne $scopeId) {
    $module.FailJson("The scope does not match with the dhcp scope range. For the specified range the scope should be '$validScope'")
}

# Scope state
if ($state -eq 'inactive') {
    $scopeState = "InActive"
}
else {
    $scopeState = "Active"
}

# Get scope
$dhcpServersScope = Get-DhcpServerv4Scope -ScopeId $scopeId -ErrorAction SilentlyContinue

# Early exit
if (($null -eq $dhcpServersScope) -and ($state -eq "absent")) {
    $module.ExitJson()
}

# Remove scope
if (($null -ne $dhcpServersScope) -and ($state -eq "absent")) {
    try {
        Remove-DhcpServerv4Scope -ScopeId $scopeId -Confirm:$false | Out-Null
        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove the scope '$scopeId'", $Error[0])
    }
}

# New scope
if (($null -eq $dhcpServersScope) -and ($state -match "present|inactive")) {
    try {
        Add-DhcpServerv4Scope `
            -StartRange $startRange `
            -EndRange $endRange `
            -SubnetMask $subnetMask `
            -Name $name`
            -Description $description`
            -State $scopeState `
            -Type $type

        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to add the scope '$scopeId'", $Error[0])
    }
}

# Compare changes
if (
    ($dhcpServersScope.StartRange -ne $startRange) -or
    ($dhcpServersScope.EndRange -ne $endRange) -or
    ($dhcpServersScope.Name.Trim() -ne $name) -or
    ($dhcpServersScope.Description.Trim() -ne $description) -or
    ($dhcpServersScope.Type -ne $type) -or
    ($dhcpServersScope.State -ne $scopeState)
) {
    try {
        Set-DhcpServerv4Scope `
            -ScopeId $scopeId `
            -StartRange $startRange `
            -EndRange $endRange `
            -Name $name`
            -Description $description`
            -State $scopeState `
            -Type $type `
            -Confirm:$false

        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set changed parameters for scope '$scopeId'", $Error[0])
    }
}

$module.ExitJson()