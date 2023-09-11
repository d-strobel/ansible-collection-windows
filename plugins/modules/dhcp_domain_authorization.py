#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: dhcp_domain_authorization
short_description: Add or remove a dhcp server to a domain controller.
description:
- Add or remove a dhcp server to a domain controller.
options:
  dns_name:
    description:
    - Specify the dns_name of the dhcp server.
    type: str
    required: true
  ip_address:
    description:
    - Specify the ip address of the dhcp server.
    type: str
    required: false
  state:
    description:
    - Set to C(present) to ensure the dhcp server is authorized.
    - Set to C(absent) to ensure the dhcp server is deauthorized.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
