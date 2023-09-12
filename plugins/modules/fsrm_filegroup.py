#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_fsrm_filegroup
short_description: Add or modify file groups
description:
- Add or modify file groups for the File Server Resource Manager.
options:
  state:
    description:
    - Set to C(present) to ensure the file group is present.
    - Set to C(absent) to ensure the file group is removed.
    type: str
    choices: [ absent, present ]
  name:
    description:
    - The name of the file group.
    type: str
    required: yes
  description:
    description:
    - The description for the file group.
    type: str
  include_pattern:
    description:
    - A list of patterns that will be included to the file group.
    type: list
    elements: str
    required: yes
  exclude_pattern:
    description:
    - A list of patterns that will be excluded from the file group.
    type: list
    elements: str
author:
- Dustin Strobel (@d-strobel)
'''

EXAMPLES = r'''
- name: Ensure file group is present with some included patterns
  d_strobel.windows_fsrm.win_fsrm_filegroup:
    name: test_group
    description: Managed by Ansible
    include_pattern:
      - ".aaa"
      - ".bbb"
    state: present
- name: Remove file group test_group
  d_strobel.windows_fsrm.win_fsrm_filegroup:
    name: test_group
    state: absent
- name: Ensure file group is present with included and excluded patterns
  d_strobel.windows_fsrm.win_fsrm_filegroup:
    name: test_group
    include_pattern:
      - ".aaa"
      - ".bbb"
    exclude_pattern:
      - ".ccc"
      - ".ddd"
    state: present
'''