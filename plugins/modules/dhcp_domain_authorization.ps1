#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        dns_name   = @{ type = "str" }
        ip_address = @{ type = "str" }
        state      = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }

    required_one_of     = @(
        , @("dns_name", "ip_address")
    )

    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$dns_name = $module.Params.dns_name
$ip_address = $module.Params.ip_address
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

try {
    $dhcpServersInDC = Get-DhcpServerInDC | Where-Object { $_.DnsName -eq $dns_name -or $_.IpAddress -eq $ip_address }
}
catch {
    $module.FailJson("Failed to get dhcp servers in domaincontroller", $Error[0])
}

# Deauthorize
if (($null -ne $dhcpServersInDC) -and ($state -eq "absent")) {
    try {
        if ($dns_name) {
            Remove-DhcpServerInDC -DnsName $dns_name -Confirm:$false | Out-Null
        }
        else {
            Remove-DhcpServerInDC -IPAddress $ip_address -Confirm:$false | Out-Null
        }
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to deauthorize the dhcp server from the domaincontroller", $Error[0])
    }
}
# Authorize
elseif (($null -eq $dhcpServersInDC) -and ($state -eq "present")) {
    try {
        if ($dns_name) {
            Add-DhcpServerInDC -DnsName $dns_name -Confirm:$false | Out-Null
        }
        else {
            Add-DhcpServerInDC -IPAddress $ip_address -Confirm:$false | Out-Null
        }
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to authorize the dhcp server to the domaincontroller", $Error[0])
    }
}

$module.ExitJson()