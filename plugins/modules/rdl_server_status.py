#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Dustin Strobel (@d-strobel), Yasmin Hinel (@yahikii),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: rdl_server_status
short_description: Add or remove the company info of the wmi object.
description:
- Add or remove the company parameters of the wmi object of the remote desktop license server.
options:
  method:
    description:
    - Define the server activation/deactivation/reactivation method.
    type: str
    required: false
    choices: [ automatic, manual ]
  confirm_code:
    description:
    - Specify the product id/license server id.
    - This parameter is required when the method is set to manual.
    type: str
    required: false
  state:
    description:
    - Set to C(present) to ensure the exclusion range is present.
    - Set to C(absent) to ensure the exclusion range is removed.
    type: str
    default: present
    choices: [ activated, deactivated ]

author:
- Yasmin Hinel (@yahikii)
'''