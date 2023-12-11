#!powershell

# Copyright: (c) 2023, Yasmin Hinel (@yahikii)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell Ansible.ModuleUtils.AddType



$spec = @{
    options             = @{
        name   = @{ type = "str"; required = $true }
        description = @{ type = "str" }
        actions     = @{ type = "dict"; options = @{
                arguments = @{ type = "str" }
                execute   = @{ type = "str" }
            }
            required_if = @(
                , @("actions", $true, @("arguments", "execute"))
            )
        }
        triggers    = @{ type = "dict"; options = @{
                start_time  = @{ type = "str" }
                day_of_week = @{ type = "str"; choices = "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
                frequency   = @{ type = "str"; choices = "once", "daily", "weekly"; default = "once" }
            }
            required_if = @(
                , @("triggers", $true, @("frequency", "start_time"))
                , @("frequency", "weekly", @("day_of_week"))
            )
        }
        username    = @{ type = "str" }
        password    = @{ type = "str"; no_log = $true }
        runlevel    = @{ type = "str"; choices = "limited", "highest" }
        state       = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }

    required_if         = @(
        , @("state", "present", @("username", "password", "actions"))
    )

    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

#Map variables
$taskName = $module.Params.name
$description = $module.Params.description
$actions = $module.Params.actions
$arguments = $module.Params.actions.arguments
$execute = $module.Params.actions.execute
$triggers = $module.Params.triggers
$startTime = $module.Params.triggers.start_time
$dayOfWeek = $module.Params.triggers.day_of_week
$frequency = $module.Params.triggers.frequency
$username = $module.Params.username
$password = $module.Params.password
$runLevel = $module.Params.runlevel
$state = $module.Params.state


# ErrorAction
$ErrorActionPreference = 'Stop'

if ($state -eq "present") {
    # New Task Action
    if ($actions) {
        try {
            $taskAction = New-ScheduledTaskAction `
                -Execute $execute `
                -Argument $arguments
        }
        catch {
            $module.FailJson("Failed to create scheduled task action", $Error[0])
        }
    }

    # New Task Trigger
    if ($triggers -and ($frequency -eq "once")) {
        try {
            $taskTrigger = New-ScheduledTaskTrigger -Once -At $startTime
        }
        catch {
            $module.FailJson("Failed to create scheduled task trigger", $Error[0])
        }
    }
    elseif ($triggers -and ($frequency -eq "daily")) {
        try {
            $taskTrigger = New-ScheduledTaskTrigger -Daily -At $startTime
        }
        catch {
            $module.FailJson("Failed to create scheduled task trigger", $Error[0])
        }
    }
    elseif ($triggers -and ($frequency -eq "weekly")) {
        try {
            $taskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $dayOfWeek -At $startTime
        }
        catch {
            $module.FailJson("Failed to create scheduled task trigger", $Error[0])
        }
    }
    elseif ($triggers -and ($frequency -eq "weekly") -and ($null -eq $dayOfWeek)) {
        $module.FailJson("Failed to create scheduled task trigger. Parameter day of week is required if frequency is weekly")
    }

    # Register Scheduled Task
    if ((-not $description) -and ($state -eq "present")) {
        try {
            Register-ScheduledTask `
                -TaskName $taskName `
                -Action $taskAction `
                -User $username `
                -Password $password
        }
        catch {
            $module.FailJson("Failed to create scheduled task", $Error[0])
        }

    }
    elseif ($description -and ($state -eq "present")) {
        try {
            Register-ScheduledTask `
                -TaskName $taskName `
                -Description $description `
                -Action $taskAction `
                -User $username `
                -Password $password
        }
        catch {
            $module.FailJson("Failed to create scheduled task", $Error[0])
        }
    }
    elseif ($runLevel -and ($state -eq "present")) {
        try {
            Register-ScheduledTask `
                -TaskName $taskName `
                -RunLevel $runLevel `
                -Action $taskAction `
                -User $username `
                -Password $password
        }
        catch {
            $module.FailJson("Failed to create scheduled task", $Error[0])
        }
    }
    elseif ($runLevel -and $description -and ($state -eq "present")) {
        try {
            Register-ScheduledTask `
                -TaskName $taskName `
                -Description $description `
                -RunLevel $runLevel `
                -Action $taskAction `
                -User $username `
                -Password $password
        }
        catch {
            $module.FailJson("Failed to create scheduled task", $Error[0])
        }
    }

    # Set Scheduled Task
    if ($triggers -and ($state -eq "present")) {
        try {
            Set-ScheduledTask `
                -TaskName $taskName `
                -Trigger $taskTrigger `
                -User $username `
                -Password $password
        }
        catch {
            $module.FailJson("Failed to update scheduled task", $Error[0])
        }
    }
    elseif ($triggers -and $actions -and ($state -eq "present")) {
        try {
            Set-ScheduledTask `
                -TaskName $taskName `
                -Trigger $taskTrigger `
                -Action $taskAction `
                -User $username `
                -Password $password
        }
        catch {
            $module.FailJson("Failed to update scheduled task", $Error[0])
        }
    }
}

# Unregister Scheduled Task
if ($state -eq "absent") {
    try {
        Unregister-ScheduledTask -Taskname $taskName -Confirm:$false
    }
    catch {
        $module.FailJson("Failed to delete scheduled task", $Error[0])
    }

}

$module.ExitJson()