#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name                 = @{ type = "str"; required = $true }
        partner_server       = @{ type = "str"; required = $true }
        scopes               = @{ type = "list" ; elements = "str"; required = $true }
        shared_secret        = @{ type = "str" }
        shared_secret_update = @{ type = "str"; choices = "always", "never"; default = "never" }
        mode                 = @{ type = "str"; choices = "loadbalance", "hotstandby"; default = "loadbalance" }
        server_role          = @{ type = "str"; choices = "active", "standby" }
        loadbalance_percent  = @{ type = "int"; default = 50 }
        state                = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }

    required_if         = @(
        , @("mode", "loadbalance", @("loadbalance_percent"))
        , @("mode", "hotstandby", @("server_role"))
    )

    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$name = $module.Params.name
$partnerServer = $module.Params.partner_server
$scopeId = $module.Params.scopes
$sharedSecret = $module.Params.shared_secret
$sharedSecretUpdate = $module.Params.shared_secret_update
$mode = $module.Params.mode
$serverRole = $module.Params.server_role
$loadbalancePercent = $module.Params.loadbalance_percent
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get failover
$dhcpServersFailover = Get-DhcpServerv4Failover -Name $name -ErrorAction SilentlyContinue

# Early exit
if (($null -eq $dhcpServersFailover) -and ($state -eq "absent")) {
    $module.ExitJson()
}

# Remove failover
if (($null -ne $dhcpServersFailover) -and ($state -eq "absent")) {
    try {
        Remove-DhcpServerv4Failover -Name $name -Confirm:$false | Out-Null

        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove the failover '$name'", $Error[0])
    }
}

# New failover
if (($null -eq $dhcpServersFailover) -and ($state -eq "present")) {
    try {
        if ($sharedSecret) {
            if ($mode -eq "loadbalance") {
                Add-DhcpServerv4Failover `
                    -Name $name `
                    -PartnerServer $partnerServer `
                    -ScopeId $scopeId `
                    -SharedSecret $sharedSecret `
                    -LoadBalancePercent $loadbalancePercent `
                    -Confirm:$false `
                    -Force
            }
            else {
                Add-DhcpServerv4Failover `
                    -Name $name `
                    -PartnerServer $partnerServer `
                    -ScopeId $scopeId `
                    -SharedSecret $sharedSecret `
                    -ServerRole $serverRole `
                    -Confirm:$false `
                    -Force
            }
        }
        else {
            if ($mode -eq "loadbalance") {
                Add-DhcpServerv4Failover `
                    -Name $name `
                    -PartnerServer $partnerServer `
                    -ScopeId $scopeId `
                    -LoadBalancePercent $loadbalancePercent `
                    -Confirm:$false
            }
            else {
                Add-DhcpServerv4Failover `
                    -Name $name `
                    -PartnerServer $partnerServer `
                    -ScopeId $scopeId `
                    -ServerRole $serverRole `
                    -Confirm:$false
            }
        }

        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to add the failover '$name'", $Error[0])
    }
}

# Compare failover mode
if ($dhcpServersFailover.Mode -ne $mode) {
    try {
        Set-DhcpServerv4Failover -Name $name -Mode $mode -Confirm:$false
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set failover mode to '$mode'", $Error[0])
    }
}

# Update shared secret
if ($sharedSecretUpdate -eq "always") {
    try {
        Set-DhcpServerv4Failover -Name $name -SharedSecret $sharedSecret -Confirm:$false -Force
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set shared secret", $Error[0])
    }
}

# Compare loadbalance parameters
if (
    ($dhcpServersFailover.Mode -eq "loadbalance") -and
    ($dhcpServersFailover.LoadbalancePercent -ne $loadbalancePercent)
) {
    try {
        Set-DhcpServerv4Failover -Name $name -LoadBalancePercent $loadbalancePercent -Confirm:$false
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set loadbalance_percent to $loadbalancePercent %", $Error[0])
    }
}

# Compare scopes
$scopesToCompare = @()
$dhcpServersFailover.ScopeId | ForEach-Object {
    $scopesToCompare += $_.IPAddressToString
}

$compareScopes = Compare-Object -ReferenceObject $scopesToCompare -DifferenceObject $scopeId

# Add scopes
$scopesToAdd = $compareScopes | Where-Object {$_.SideIndicator -eq "=>"} | Select-Object -ExpandProperty InputObject
if ($scopesToAdd) {
    try {
        Add-DhcpServerv4FailoverScope -Name $name -ScopeId $scopesToAdd -Confirm:$false
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to add the following scopes: $scopesToAdd", $Error[0])
    }
}

# Remove scopes
$scopesToRemove = $compareScopes | Where-Object {$_.SideIndicator -eq "<="} | Select-Object -ExpandProperty InputObject
if ($scopesToRemove) {
    try {
        Remove-DhcpServerv4FailoverScope -Name $name -ScopeId $scopesToRemove -Confirm:$false
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove the following scopes: $scopesToRemove", $Error[0])
    }
}

$module.ExitJson()