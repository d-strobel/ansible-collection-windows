#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: dhcp_option_value_v4
short_description: Add, remove or change an IPv4 option value.
description:
- Add, remove or change an IPv4 option value.
options:
  option_id:
    description:
    - The identifier of the option.
    type: int
    required: true
  scope_id:
    description:
    - The identifier of the scope for which the value should be set.
    - Only one of C(scope_id) or C(reserved_ip) can be set.
    type: str
    required: false
  reserved_ip:
    description:
    - The reserverd ip fo which the value shoud be set.
    - Only one of C(scope_id) or C(reserved_ip) can be set.
    type: str
    required: false
  value:
    description:
    - The value to set.
    type: list
    elements: str
    required: true
  state:
    description:
    - Set to C(present) to ensure the value is set.
    - Set to C(absent) to ensure the value is removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
