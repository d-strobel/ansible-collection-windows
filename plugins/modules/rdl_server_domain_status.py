#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: rdl_server_domain_status
short_description: Add or remove the server to the Remote Desktop license server group in a given domain.
description:
- Add or remove the server to the Remote Desktop license server group in a given domain.
options:
  domain:
    description:
    - Define the domain name.
    type: str
    required: true
  state:
    description:
    - Set to C(present) to ensure the server is present in the Remote Desktop license server group.
    - Set to C(absent) to ensure the server is removed from the Remote Desktop license server group.
    type: str
    default: present
    choices: [ present, absent ]

author:
- Dustin Strobel (@d-strobel)
'''