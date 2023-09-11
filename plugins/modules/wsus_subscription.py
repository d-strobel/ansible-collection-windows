#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: wsus_subscription
short_description: Modify the subscription.
description:
- Modify the subscription (synchronization) for the updates.
options:
  update_classifications:
    description:
    - Define a list of update classifications.
    type: list
    elements: str
  update_categories:
    aliases:
    - update_products
    description:
    - Define a list of update categories.
    type: list
    elements: str
  state:
    description:
    - Set to C(present) to ensure the defined settings is present.
    - Set to C(absent) to ensure the defined settings are removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
