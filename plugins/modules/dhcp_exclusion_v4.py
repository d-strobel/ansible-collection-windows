#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: dhcp_exclusion_v4
short_description: Add or remove an IPv4 exclusion range.
description:
- Add or remove an IPv4 exclusion range.
options:
  scope:
    description:
    - Specify the scope, where the range is located.
    type: str
    required: true
  start_range:
    description:
    - Define the first ip-address of the exclusion range.
    type: str
    required: true
  end_range:
    description:
    - Define the last ip-address of the exclusion range.
    type: str
    required: true
  state:
    description:
    - Set to C(present) to ensure the exclusion range is present.
    - Set to C(absent) to ensure the exclusion range is removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
