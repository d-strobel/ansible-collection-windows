#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: wsus_install_approval_rule
short_description: Modify an update install approval rule
description:
- Modify an update install approval rule
options:
  name:
    description:
    - Specify the name of the approval rule.
    type: str
    required: true
  computer_target_groups:
    description:
    - Define a list of computer target groups.
    - The groups will always be set when something differs with the current state.
    type: list
    elements: str
  update_classifications:
    description:
    - Define a list of update classifications.
    - The classifications will always be set when something differs with the current state.
    type: list
    elements: str
  update_categories:
    aliases: [ update_products ]
    description:
    - Define a list of update products.
    - The categories will always be set when something differs with the current state.
    type: list
    elements: str
  deadline:
    description:
    - Set a deadline for the updates to be approved.
    type: str
  state:
    description:
    - Set to C(present) to ensure the settings are present.
    - Set to C(absent) to ensure the settings are removed.
    - Set to C(disabled) to disable the rule but apply all settings.
    type: str
    default: present
    choices: [ absent, present, disabled ]

author:
- Dustin Strobel (@d-strobel)
'''
