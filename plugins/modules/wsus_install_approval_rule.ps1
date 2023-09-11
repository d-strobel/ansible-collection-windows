#!powershell

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType

$spec = @{
    options             = @{
        name                   = @{ type = "str"; required = $true }
        computer_target_groups = @{ type = "list"; elements = "str" }
        update_classifications = @{ type = "list"; elements = "str" }
        update_categories      = @{ type = "list"; elements = "str"; aliases = "update_products" }
        deadline               = @{ type = "str" }
        state                  = @{ type = "str"; choices = "absent", "present", "disabled"; default = "present" }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

# Map variables
$name = $module.Params.name
$computerTargetGroups = $module.Params.computer_target_groups
$updateClassifications = $module.Params.update_classifications
$updateCategories = $module.Params.update_categories
$deadline = $module.Params.deadline
$state = $module.Params.state

# ErrorAction
$ErrorActionPreference = 'Stop'

# Get wsus config
try {
    $wsus = Get-WsusServer
}
catch {
    $module.FailJson("Failed to get WSUS configuration", $Error[0])
}

# Check Approval rule existing
try {
    $approvalRule = $wsus.GetInstallApprovalRules() | Where-Object { $_.Name -eq $name }
}
catch {
    $module.FailJson("Failed to get approval rules", $Error[0])
}

if (($null -ne $approvalRule) -and ($state -eq "absent")) {
    try {
        $wsus.DeleteInstallApprovalRule($approvalRule.Id)
        $module.Result.changed = $true
        $module.ExitJson()
    }
    catch {
        $module.FailJson("Failed to remove WSUS approval rule $name", $Error[0])
    }
}
elseif (($null -eq $approvalRule) -and ($state -ne "absent")) {
    try {
        $approvalRule = $wsus.CreateInstallApprovalRule($name)
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to create WSUS approval rule $name", $Error[0])
    }
}

# Ensure computer target groups
if ($computerTargetGroups) {

    # Check if all groups exists
    $invalidComputerGroups = $computerTargetGroups | Where-Object {
        $_ -notin $wsus.GetComputerTargetGroups().Name
    }
    if ($invalidComputerGroups) {
        $module.FailJson("Invalid Computer target groups: $invalidComputerGroups")
    }

    # Build wanted computer target group collection
    try {
        $wantedComputerGroups = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -in $computerTargetGroups }
        $wantedComputerTargetGroupCollection = New-Object Microsoft.UpdateServices.Administration.ComputerTargetGroupCollection
        $wantedComputerTargetGroupCollection.AddRange($wantedComputerGroups)
    }
    catch {
        $module.FailJson("Failed to build new computer target group collection.", $Error[0])
    }

    # Compare if target groups must be set
    if (Compare-Object -ReferenceObject $approvalRule.GetComputerTargetGroups() -DifferenceObject $wantedComputerTargetGroupCollection) {
        try {
            $approvalRule.SetComputerTargetGroups($wantedComputerTargetGroupCollection)
            $approvalRule.Save()
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to set computer target group collection to approval rule.", $Error[0])
        }
    }
}

if ($updateClassifications) {

    # Check if all update classifications exists
    $invalidUpdateClassifications = $updateClassifications | Where-Object {
        $_ -notin $wsus.GetUpdateClassifications().Title
    }
    if ($invalidUpdateClassifications) {
        $module.FailJson("Invalid update classifications: $invalidUpdateClassifications")
    }

    # Build wanted update classifications collection
    try {
        $wantedUpdateClassifications = $wsus.GetUpdateClassifications() | Where-Object { $_.Title -in $updateClassifications }
        $wantedUpdateClassificationCollection = New-Object Microsoft.UpdateServices.Administration.UpdateClassificationCollection
        $wantedUpdateClassificationCollection.AddRange($wantedUpdateClassifications)
    }
    catch {
        $module.FailJson("Failed to build update classification collection.", $Error[0])
    }

    # Compare if update classification collection must be set
    if (Compare-Object -ReferenceObject $approvalRule.GetUpdateClassifications() -DifferenceObject $wantedUpdateClassificationCollection) {
        try {
            $approvalRule.SetUpdateClassifications($wantedUpdateClassificationCollection)
            $approvalRule.Save()
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to set update classification collection to approval rule.", $Error[0])
        }
    }
}

if ($updateCategories) {

    # Check if all update categories exists
    $invalidUpdateCategories = $updateCategories | Where-Object {
        $_ -notin $wsus.GetUpdateCategories().Title
    }
    if ($invalidUpdateCategories) {
        $module.FailJson("Invalid update categories: $invalidUpdateCategories")
    }

    # Build wanted update category collection
    try {
        $wantedUpdateCategories = $wsus.GetUpdateCategories() | Where-Object { $_.Title -in $updateCategories }
        $wantedUpdateCategoryCollection = New-Object Microsoft.UpdateServices.Administration.UpdateCategoryCollection
        $wantedUpdateCategoryCollection.AddRange($wantedUpdateCategories)
    }
    catch {
        $module.FailJson("Failed to build update category collection.", $Error[0])
    }

    # Compare if update category collection must be set
    if (Compare-Object -ReferenceObject $approvalRule.GetCategories() -DifferenceObject $wantedUpdateCategoryCollection) {
        try {
            $approvalRule.SetCategories($wantedUpdateCategoryCollection)
            $approvalRule.Save()
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to set update category collection to approval rule.", $Error[0])
        }
    }
}

if ($deadline) {
    # Check if format is correct
    if ($deadline -notmatch "^\d{1,2}\-\d{1,2}:\d{1,2}$") {
        $module.FailJson("Deadline format must be dd-hh:mm (days-hours:minutes).")
    }

    # Parse strings to days and minutes after midnight
    try {
        [Int16]$dayOffset = $deadline.split('-')[0]
        [int16]$hours = $deadline.split('-')[1].split(':')[0]
        [int16]$minutes = $deadline.split('-')[1].split(':')[1]
        [int16]$minutesAfterMidnight = $hours * 60 + $minutes
    }
    catch {
        $module.FailJson("Failed to parse string for deadline.", $Error[0])
    }

    if ($null -eq $approvalRule.deadline) {
        # Create new deadline object
        try {
            $newDeadline = New-Object Microsoft.UpdateServices.Administration.AutomaticUpdateApprovalDeadline
            $newDeadline.DayOffset = $dayOffset
            $newDeadline.MinutesAfterMidnight = $minutesAfterMidnight
        }
        catch {
            $module.FailJson("Failed to create new deadline object.", $Error[0])
        }

        try {
            $approvalRule.deadline = $newDeadline
            $approvalRule.Save()
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to set new deadline object to rule.", $Error[0])
        }
    }
    else {
        # DayOffset
        if ($approvalRule.deadline.DayOffset -ne $dayOffset) {
            try {
                $approvalRule.deadline.DayOffset = $dayOffset
                $approvalRule.Save()
                $module.Result.changed = $true
            }
            catch {
                $module.FailJson("Failed to set deadline DayOffset to $dayOffset.", $Error[0])
            }
        }

        # MinutesAfterMidnight
        if ($approvalRule.deadline.MinutesAfterMidnight -ne $minutesAfterMidnight) {
            try {
                $approvalRule.deadline.MinutesAfterMidnight = $minutesAfterMidnight
                $approvalRule.Save()
                $module.Result.changed = $true
            }
            catch {
                $module.FailJson("Failed to set deadline MinutesAfterMidnight to $minutesAfterMidnight.", $Error[0])
            }
        }
    }
}

if ($approvalRule.Enabled -and ($state -eq "disabled")) {
    try {
        $approvalRule.Enabled = $false
        $approvalRule.Save()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to disable approval rule.", $Error[0])
    }
}
elseif ((-not $approvalRule.Enabled) -and ($state -ne "disabled")) {
    try {
        $approvalRule.Enabled = $true
        $approvalRule.Save()
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to enable approval rule.", $Error[0])
    }
}

$module.ExitJson()