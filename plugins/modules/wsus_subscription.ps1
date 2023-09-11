#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        update_classifications = @{ type = "list"; elements = "str" }
        update_categories      = @{ type = "list"; elements = "str"; aliases = "update_products" }
        state                  = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$updateClassifications = $module.Params.update_classifications
$updateCategories = $module.Params.update_categories
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wsus config
try {
    $wsus = Get-WsusServer
    $subscription = $wsus.GetSubscription()
}
catch {
    $module.FailJson("Failed to get WSUS configuration", $Error[0])
}

# Update Classifications
if ($null -ne $updateClassifications) {
    try {
        $allClassifications = $wsus.GetUpdateClassifications()
        $activeClassifications = $subscription.GetUpdateClassifications()
        $newClassifications = $subscription.GetUpdateClassifications()
    }
    catch {
        $module.FailJson("Failed to get synchronized update classifications", $Error[0])
    }

    $i = 0
    foreach ($classification in $updateClassifications) {

        if (($classification -in $activeClassifications.Title) -and ($state -eq "absent")) {
            try {
                $c = $activeClassifications | Where-Object {$_.Title -eq $classification}
                $newClassifications.Remove($c)
            }
            catch {
                $module.FailJson("Failed to remove update classification: $classification", $Error[0])
            }
        }
        elseif (($classification -notin $activeClassifications.Title) -and ($state -eq "present")) {

            # Check if wanted update classification exists
            if ($classification -notin $allClassifications.Title) {
                $module.FailJson("The following update classification does not exist: $classification")
            }

            if ($classification -notin $newClassifications.Title) {
                try {
                    $c = $allClassifications | Where-Object {$_.Title -eq $classification}
                    $newClassifications.Add($c) | Out-Null
                }
                catch {
                    $module.FailJson("Failed to add update classification: $classification", $Error[0])
                }
            }
        }
        $i++
    }

    if (Compare-Object -ReferenceObject $activeClassifications -DifferenceObject $newClassifications) {
        try {
            $subscription.SetUpdateClassifications($newClassifications)
            $subscription.Save()
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to set update classifications: $classification", $Error[0])
        }
    }
}

# Update Categories
if ($null -ne $updateCategories) {
    try {
        $allCategories = $wsus.GetUpdateCategories()
        $activeCategories = $subscription.GetUpdateCategories()
        $newCategories = $subscription.GetUpdateCategories()
    }
    catch {
        $module.FailJson("Failed to get synchronized update categories", $Error[0])
    }

    $i = 0
    foreach ($category in $updateCategories) {

        if (($category -in $activeCategories.Title) -and ($state -eq "absent")) {
            try {
                $activeCategories | Where-Object {$_.Title -eq $category} | ForEach-Object {
                    $newCategories.Remove($_)
                }
            }
            catch {
                $module.FailJson("Failed to remove update category: $category", $Error[0])
            }
        }
        elseif (($category -notin $activeCategories.Title) -and ($state -eq "present")) {

            # Check if wanted update classification exists
            if ($category -notin $allCategories.Title) {
                $module.FailJson("The following update category does not exist: $category")
            }

            if ($category -notin $newCategories.Title) {
                try {
                    $allCategories | Where-Object {$_.Title -eq $category} | ForEach-Object {
                        $newCategories.Add($_) | Out-Null
                    }
                }
                catch {
                    $module.FailJson("Failed to add update category: $category", $Error[0])
                }
            }
        }
        $i++
    }

    if (Compare-Object -ReferenceObject $activeCategories -DifferenceObject $newCategories) {
        try {
            $subscription.SetUpdateCategories($newCategories)
            $subscription.Save()
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to set update category: $category", $Error[0])
        }
    }
}

$module.ExitJson()