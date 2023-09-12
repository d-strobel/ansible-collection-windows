#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel), Yasmin Hinel (@yahikii),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: rdl_company_info
short_description: Add or remove the company info of the wmi object.
description:
- Add or remove the company parameters of the wmi object of the remote desktop license server.
options:
  first_name:
    description:
    - Specify the first name.
    type: str
    required: false
  last_name:
    description:
    - Specify the last name.
    type: str
    required: false
  company:
    description:
    - Specify the company name.
    type: str
    required: false
  email:
    description:
    - Specify the email address.
    type: str
    required: false
  org_unit:
    description:
    - Specify the organization unit.
    type: str
    required: false
  address:
    description:
    - Specify the address of the company (street name + street number).
    type: str
    required: false
  postal_code:
    description:
    - Specify the postalcode.
    type: str
    required: false
  city:
    description:
    - Specify the name of the city.
    type: str
    required: false
  federal_state:
    description:
    - Specify the federal state of the company.
    type: str
    required: false
  state:
    description:
    - Set to C(present) to ensure the exclusion range is present.
    - Set to C(absent) to ensure the exclusion range is removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Yasmin Hinel (@yahikii)
'''