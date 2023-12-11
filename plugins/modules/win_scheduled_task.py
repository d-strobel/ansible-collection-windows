#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Yasmin Hinel (@yahikii),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_scheduled_task
short_description: Register, Unregister scheduled task on a server.
description:
- Add or remove the scheduled task on a given server.
options:
  task_name:
    description:
    - Define the name of the task
    type: str
    required: true
  description:
    description:
    - Define the description of the task
    type: str
    required: false
  actions:
    description:
    - Define the action for the task
    - Param action is required if state is on present
    - Param arguments and execute are required if param actions is being used
    type: dict
    required: false
    options:
        arguments:
            description:
            - Define the argument for the task
            type: str
            required: true
        execute:
            description:
            - Define the execution for the task
            type: str
            required: true
   triggers:
    description:
        - Define the triggers for the task
        - Param start_time, day_of_week and frequency are required if param triggers is being used
        type: dict
        required: false
        options:
            start_time:
                description:
                - Define the start_time for the task
                - Needs to be written in 12-hour clock terms. e.g: 3PM, 6AM, 12AM,...
                type: str
                required: true
            day_of_week:
                description:
                - Define the day of the week for the task
                - Only required if frequency is weekly
                type: str
                required: true
                choices: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
            frequency:
                description:
                - Define the frequency for the task
                type: str
                required: true
                choices: [once, daily, weekly]
                default: once
  username:
    description:
    - Add the username that is being used to start the task
    type: str
    required: false
  password:
    description:
        - Add the password for the used useraccount
        type: str
        required: false
  runlevel:
    description:
        - Add the runlevel for the task
        type: str
        required: false
        options: [limited, highest]
  state:
    description:
    - Set to C(present) to ensure the exclusion range is present.
    - Set to C(absent) to ensure the exclusion range is removed.
    type: str
    default: present
    choices: [ activated, deactivated ]

author:
- Yasmin Hinel (@yahikii)
'''