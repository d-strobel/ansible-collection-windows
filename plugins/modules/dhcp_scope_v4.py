#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: dhcp_scope_v4
short_description: Add or remove a IPv4 dhcp scope.
description:
- Add or remove a IPv4 dhcp scope.
options:
  name:
    description:
    - Specify the name of the dhcp scope.
    type: str
    required: false
  scope:
    description:
    - Define the scope for the dhcp range. This is the subnet of the dhcp range.
    type: str
    required: true
  start_range:
    description:
    - Define the first ip-address of the dhcp range.
    type: str
    required: true
  end_range:
    description:
    - Define the last ip-address of the dhcp range.
    type: str
    required: true
  subnet_mask:
    description:
    - Define the subnet mask of the dhcp range.
    type: str
    required: true
  description:
    description:
    - Define a desciption to the scope.
    type: str
    required: false
  type:
    description:
    - Specifies the type of clients to be serviced by the scope.
    type: str
    default: dhcp
    choices: [ dhcp, bootp, both ]
  state:
    description:
    - Set to C(present) to ensure the scope is present.
    - Set to C(absent) to ensure the scope is removed.
    - Set to C(inactive) to ensure the scope is present but inactive.
    type: str
    default: present
    choices: [ absent, present, inactive ]

author:
- Dustin Strobel (@d-strobel)
'''
