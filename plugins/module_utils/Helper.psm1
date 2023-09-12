function Import-AdfsPowershellModule {
    $adfsModule = "ADFS"

    try {
        if ($null -eq (Get-Module $adfsModule -ErrorAction SilentlyContinue)) {
            Import-Module $adfsModule
        }
    }
    catch {
        return $Error[0]
    }
}

# Access control policy
function Get-AdfsAccessControlPolicySpecs {
    # Output the specs
    @{
        options     = @{
            access_control_policy  = @{
                type    = "str"
                choices = @(
                    "permit_everyone",
                    "permit_specific_group",
                    "permit_everyone_and_require_mfa",
                    "permit_everyone_and_require_mfa_for_specific_group",
                    "permit_everyone_and_require_mfa_or_auto_device_registration",
                    "permit_everyone_and_require_mfa_from_unauthenticated_devices",
                    "permit_everyone_and_require_mfa_from_extranet_access"
                )
            }
            access_control_group   = @{type = "list"; elements = "str" }
            access_control_exclude = @{type = "list"; elements = "str" }
        }

        required_if = @(
            , @("access_control_policy", "permit_specific_group", @("access_control_group"))
            , @("access_control_policy", "permit_everyone_and_require_mfa_for_specific_group", @("access_control_group", "access_control_exclude"))
        )
    }
}

# Transform rules
function Get-AdfsTransformRulesSpecs {
    # Output the specs
    @{
        options = @{
            domain           = @{ type = "str" }
            claim_attributes = @{
                type              = "list"
                elements          = "dict"
                options           = @{
                    type      = @{ type = "str"; choices = "ldap", "group" }
                    condition = @{ type = "str" }
                    issuance  = @{ type = "str" }
                }
                required_together = @(
                    , @("type", "condition", "issuance")
                )
            }
        }
    }
}

function Get-AdfsTransformRules {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'Ansible.Basic.AnsibleModule' })]
        $Module
    )

    begin {
        [string] $transformRule = ""
        [string] $ldapRuleTypes = ""
        [string] $ldapRuleQuery = ""
    }

    process {
        # Get ClaimDescription for group
        $claimGroup = Get-AdfsClaimDescription -ShortName group
        if ($null -eq $claimGroup) {
            throw "Cannot find the Claim description for group, which is needed to create a claim rule."
        }

        # Get ClaimDescription for groupsid
        $claimGroupSID = Get-AdfsClaimDescription -ShortName groupsid
        if ($null -eq $claimGroupSID) {
            throw "Cannot find the Claim description for groupsid, which is needed to create a claim rule."
        }

        # Build transform rules for claims
        foreach ($claimAttribute in $Module.Params.claim_attributes) {

            switch ($claimAttribute.Type) {
                'group' {
                    # Get SID of group
                    try {
                        $groupObject = New-Object System.Security.Principal.NTAccount("$(($Module.Params.domain).ToUpper())", "$($claimAttribute.Condition)")
                        $groupSID = $groupObject.Translate([System.Security.Principal.SecurityIdentifier]) | Select-Object -ExpandProperty Value
                    }
                    Catch {
                        throw $Error[0]
                    }

                    # Build rule for group
                    $transformRule += "
                        @RuleTemplate = `"EmitGroupClaims`"
                        @RuleName = `"Group $($claimAttribute.Condition)`"
                        c:[Type == `"$($claimGroupSID.ClaimType)`", Value == `"$groupSID`", Issuer == `"AD AUTHORITY`"]
                        => issue(Type = `"$($claimGroup.ClaimType)`", Value = `"$($claimAttribute.Issuance)`", Issuer = c.Issuer, OriginalIssuer = c.OriginalIssuer, ValueType = c.ValueType);
                    "
                }
                'ldap' {
                    # Query output for this claim
                    $ldapRuleQuery += "$($claimAttribute.Issuance),"

                    # Try to find claim type
                    $claimLdap = Get-AdfsClaimDescription -ShortName $claimAttribute.Issuance
                    if ($claimLdap) {
                        $ldapRuleTypes += "`"$($claimLdap.ClaimType)`", "
                    }
                    else {
                        $ldapRuleTypes += "`"$($claimAttribute.Condition)`","
                    }
                }
                Default {
                    throw "Claim type does not match 'group' OR 'ldap'."
                }
            }
        }

        if ($ldapRuleQuery) {
            # Trim strings for claim rules
            $ldapRuleQuery = $ldapRuleQuery.TrimEnd(' , ')
            $ldapRuleTypes = $ldapRuleTypes.TrimEnd(' , ')

            # Build transform rule for ldap claims
            $transformRule += "
            @RuleTemplate = `"LdapClaims`"
            @RuleName = `"LDAP Claims`"
            c:[Type == `"http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname`", Issuer == `"AD AUTHORITY`"]
            => issue(store = `"Active Directory`", types = ($ldapRuleTypes), query = `";$ldapRuleQuery;{0}`", param = c.Value);
        "
        }
    }

    end {
        return $transformRule
    }
}

# Export functions
$exportMembers = @{
    Function = @(
        'Import-AdfsPowershellModule',
        'Get-AdfsAccessControlPolicySpecs',
        'Get-AdfsTransformRulesSpecs',
        'Get-AdfsTransformRules'
    )
}
Export-ModuleMember @exportMembers