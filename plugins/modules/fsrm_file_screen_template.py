#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_fsrm_file_screen_template
short_description: Add or modify file screen templates
description:
- Add or modify file screen templates for the File Server Resource Manager.
options:
  state:
    description:
    - Set to C(present) to ensure the file screen template is present.
    - Set to C(absent) to ensure the file screen template is removed.
    type: str
    choices: [ absent, present ]
author:
- Dustin Strobel (@d-strobel)
'''

EXAMPLES = r'''
- name: Ensure simple file screen template is present
  d_strobel.windows_fsrm.win_fsrm_file_screen_template:
    name: test_template
    description: Managed by Ansible
    file_group:
      - test_group
    state: present
- name: Ensure simple file screen template is removed
  d_strobel.windows_fsrm.win_fsrm_file_screen_template:
    name: test_template
    description: Managed by Ansible
    file_group:
      - test_group
    state: present
'''