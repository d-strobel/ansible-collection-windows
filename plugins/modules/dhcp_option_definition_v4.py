#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: dhcp_option_definition_v4
short_description: Add, remove or change an IPv4 option definition.
description:
- Add, remove or change an IPv4 option definition.
options:
  name:
    description:
    - Specify the name of the option.
    type: str
    required: true
  option_id:
    description:
    - The identifier of the option.
    type: str
    required: true
  vendor_class:
    description:
    - Specify if the option belongs to a vendor class.
    type: str
    required: false
  type:
    description:
    - Define the value type for the option.
    type: str
    required: true
    choices: [ byte, word, dword, dworddword, ipv4address, string, binarydata, encapsulateddata ]
  description:
    description:
    - Specify a description.
    type: str
    required: false
  multi_valued:
    description:
    - Set to C(true) if the option can have multiple values.
    - Set to C(false) if the option can only have one value (default).
    type: bool
    required: false
    default: false
  default_value:
    description:
    - Specify a default value for the option.
    type: str
    required: false
  state:
    description:
    - Set to C(present) to ensure the failover is present.
    - Set to C(absent) to ensure the failover is removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
