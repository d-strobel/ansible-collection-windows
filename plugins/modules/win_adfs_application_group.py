#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel), Yasmin Hinel (@seasxlticecream)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_adfs_application_group
short_description: Add or modify application groups
description:
- Add or modify application groups for the Active Directory Federation Services.
options:
  state:
    description:
    - Set to C(present) to ensure the application group is present.
    - Set to C(absent) to ensure the application group is removed.
    - Set to C(disabled) to ensure the application group is present but disabled.
    type: str
    default: present
    choices: [ absent, present, disabled ]
  group_identifier:
    description:
    - The identifier of the application group.
    type: str
    required: yes
  name:
    description:
    - The name of the application group.
    type: str
  description:
    description:
    - The description for the application group.
    type: str
author:
- Dustin Strobel (@d-strobel)
- Yasmin Hinel (@seasxlticecream)
'''

EXAMPLES = r'''
- name: Ensure application group is present
  d_strobel.windows_adfs.win_adfs_application_group:
    group_identifier: test_group
    state: present
- name: Remove application group test_group
  d_strobel.windows_adfs.win_adfs_application_group:
    group_identifier: test_group
    state: absent
- name: Ensure application group is present with description and different name
  d_strobel.windows_adfs.win_adfs_application_group:
    group_identifier: test_group
    name: Test Group
    description: Managed by Ansible
    state: present
- name: Ensure application is present but disabled
  d_strobel.windows_adfs.win_adfs_application_group:
    group_identifier: test_group
    state: disabled
'''