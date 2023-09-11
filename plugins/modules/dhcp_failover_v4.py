#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: dhcp_failover_v4
short_description: Add or remove an IPv4 failover.
description:
- Add or remove an IPv4 failover.
options:
  name:
    description:
    - Specify the name of the dhcp failover.
    type: str
    required: true
  partner_server:
    description:
    - Specify the name of the failover partner server.
    type: str
    required: true
  scopes:
    description:
    - Specify a list of scopes to the failover.
    type: list
    elements: str
    required: true
  shared_secret:
    description:
    - Specify a shared secret for the failover relationship.
    type: str
    required: false
  shared_secret_update:
    description:
    - Define how the shared secret should be updated.
    type: str
    required: false
    choices: [ always, never ]
  mode:
    description:
    - Define the mode for the failover relationship.
    type: str
    required: false
    default: loadbalance
    choices: [ loadbalance, hotstandby ]
  server_role:
    description:
    - Define the server_role for the specified server.
    type: str
    required: false
    default: active
    choices: [ active, standby ]
  loadbalance_percent:
    description:
    - Specify the percentage of DHCP client requests which should be served by the local DHCP server service.
    type: int
    required: false
    default: 50
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
