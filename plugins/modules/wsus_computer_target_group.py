#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: wsus_computer_target_group
short_description: Add or remove a computer group.
description:
- Add or remove a computer group.
options:
  name:
    description:
    - Specify the name of the computer group.
    type: str
    required: true
  state:
    description:
    - Set to C(present) to ensure the computer group is present.
    - Set to C(absent) to ensure the settings are removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
