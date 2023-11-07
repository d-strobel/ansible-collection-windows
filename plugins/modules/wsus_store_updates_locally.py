#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2023, Dustin Strobel (@d-strobel), Yasmin Hinel (@yahikii), Pascal Breuning (@raumdonut)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: wsus_store_updates_locally
short_description: Modify the wsus updatefile location.
description:
- Modify the location of the wsus updatefile location.
options:
  update_location:
    description:
    - Set the updatefile location.
    type: str
    default: local
    choices: [ local, microsoft_update ]
  state:
    description:
    - Set to C(present) to ensure the defined settings is present.
    - Set to C(absent) to ensure the defined settings are removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Pascal Breuning (@raumdonut)
'''