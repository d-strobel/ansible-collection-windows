#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: dhcp_class_v4
short_description: Add, remove or change a dhcp class.
description:
- Add, remove or change a dhcp class.
options:
  name:
    description:
    - Specify the name of the class.
    type: str
    required: true
  data:
    description:
    - The data of the class.
    type: str
    required: false
  description:
    description:
    - Define a desciption of the class.
    type: str
    required: false
  type:
    description:
    - Specifies the type of class.
    type: str
    required: true
    choices: [ user, vendor ]
  state:
    description:
    - Set to C(present) to ensure the class is present.
    - Set to C(absent) to ensure the class is removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
