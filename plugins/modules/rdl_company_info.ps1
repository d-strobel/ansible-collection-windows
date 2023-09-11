#!powershell

# Copyright: (c) 2023, Dustin Strobel (@d-strobel), Yasmin Hinel (@seasxlticecream)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        first_name     = @{ type = "str"; default = "" }
        last_name      = @{ type = "str"; default = "" }
        company        = @{ type = "str"; default = "" }
        country_region = @{ type = "str"; default = "" }
        email          = @{ type = "str"; default = "" }
        org_unit       = @{ type = "str"; default = "" }
        address        = @{ type = "str"; default = "" }
        postal_code    = @{ type = "str"; default = "" }
        city           = @{ type = "str"; default = "" }
        federal_state  = @{ type = "str"; default = "" }
        state          = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$firstName = $module.Params.first_name
$lastName = $module.Params.last_name
$company = $module.Params.company
$countryRegion = $module.Params.country_region
$email = $module.Params.Email
$orgUnit = $module.Params.org_unit
$address = $module.Params.address
$postalCode = $module.Params.postal_code
$city = $module.Params.city
$federalState = $module.Params.federal_state
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'



# Get wmi object
try {
    $wmiObject = Get-WMIObject Win32_TSLicenseServer
}
catch {
    $module.FailJson("Failed to get the wmi object 'Win32_TSLicenseServer'", $Error[0])
}

# FirstName
if ($firstName -and $wmiObject.FirstName -and ($state -eq "absent")) {
    try {
        $wmiObject.FirstName = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove first name", $Error[0])
    }
}
elseif ($firstName -and ($wmiObject.FirstName -ne $firstName) -and ($state -eq "present")) {
    try {
        $wmiObject.FirstName = $firstName
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set first name", $Error[0])
    }
}

# LastName
if ($lastName -and $wmiObject.LastName -and ($state -eq "absent")) {
    try {
        $wmiObject.LastName = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove last name", $Error[0])
    }
}
elseif ($lastName -and ($wmiObject.LastName -ne $lastName) -and ($state -eq "present")) {
    try {
        $wmiObject.LastName = $lastName
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set last name", $Error[0])
    }
}

# Company
if ($company -and $wmiObject.Company -and ($state -eq "absent")) {
    try {
        $wmiObject.Company = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove company", $Error[0])
    }
}
elseif ($company -and ($wmiObject.Company -ne $company) -and ($state -eq "present")) {
    try {
        $wmiObject.Company = $company
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set company", $Error[0])
    }
}

# CountryRegion
if ($countryRegion -and $wmiObject.CountryRegion -and ($state -eq "absent")) {
    try {
        $wmiObject.CountryRegion = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove country/region", $Error[0])
    }
}
elseif ($countryRegion -and ($wmiObject.CountryRegion -ne $countryRegion) -and ($state -eq "present")) {
    try {
        $wmiObject.CountryRegion = $countryRegion
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set country/region", $Error[0])
    }
}

# Email
if ($email -and $wmiObject.eMail -and ($state -eq "absent")) {
    try {
        $wmiObject.eMail = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove email", $Error[0])
    }
}
elseif ($email -and ($wmiObject.eMail -ne $email) -and ($state -eq "present")) {
    try {
        $wmiObject.eMail = $email
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set email", $Error[0])
    }
}

# Organization Unit
if ($orgUnit -and $wmiObject.OrgUnit -and ($state -eq "absent")) {
    try {
        $wmiObject.orgUnit = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove organization unit", $Error[0])
    }
}
elseif ($orgUnit -and ($wmiObject.OrgUnit -ne $orgUnit) -and ($state -eq "present")) {
    try {
        $wmiObject.OrgUnit = $orgUnit
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set organization unit", $Error[0])
    }
}

# Address
if ($address -and $wmiObject.Address -and ($state -eq "absent")) {
    try {
        $wmiObject.Address = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove smtp address", $Error[0])
    }
}
elseif ($address -and ($wmiObject.Address -ne $address) -and ($state -eq "present")) {
    try {
        $wmiObject.Address = $address
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set address", $Error[0])
    }
}

# Postalcode
if ($postalCode -and $wmiObject.PostalCode -and ($state -eq "absent")) {
    try {
        $wmiObject.PostalCode = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove postal_code", $Error[0])
    }
}
elseif ($postalCode -and ($wmiObject.PostalCode -ne $postalCode) -and ($state -eq "present")) {
    try {
        $wmiObject.PostalCode = $postalCode
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set postal_code", $Error[0])
    }
}

# City
if ($city -and $wmiObject.City -and ($state -eq "absent")) {
    try {
        $wmiObject.City = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove city", $Error[0])
    }
}
elseif ($city -and ($wmiObject.City -ne $city) -and ($state -eq "present")) {
    try {
        $wmiObject.City = $city
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set city", $Error[0])
    }
}

# Federal State
if ($federalState -and $wmiObject.State -and ($state -eq "absent")) {
    try {
        $wmiObject.State = ""
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to remove federal state", $Error[0])
    }
}
elseif ($federalState -and ($wmiObject.State -ne $federalState) -and ($state -eq "present")) {
    try {
        $wmiObject.State = $federalState
        $wmiObject.Put() | Out-Null
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to set federal state", $Error[0])
    }
}

$module.ExitJson()