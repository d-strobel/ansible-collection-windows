#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_fsrm_setting
short_description: Modify general settings
description:
- Modify the File Server Resource Manager general settings.
options:
  state:
    description:
    - Set to C(present) to ensure setting is set.
    - Set to C(absent) to ensure setting is removed.
    type: str
    choices: [ absent, present ]
  smtp_server:
    description:
    - The FQDN or IP-Address of the smtp server.
    type: str
  admin_email_address:
    description:
    - The default email address to use for notifications.
    type: str
  from_email_address:
    description:
    - The email address from which the server sends the notifications.
    type: str
author:
- Dustin Strobel (@d-strobel)
'''

EXAMPLES = r'''
- name: Set the smtp server and the admin email address
  d_strobel.windows_fsrm.win_fsrm_setting:
    smtp_server: smtp.example.intern
    admin_email_address: fsrm-monitoring@example.com
    state: present
- name: Remove the smtp server
  d_strobel.windows_fsrm.win_fsrm_setting:
    smtp_server: smtp.example.intern
    state: absent
- name: Set the admin and from email address
  d_strobel.windows_fsrm.win_fsrm_setting:
    admin_email_address: fsrm-monitoring@example.com
    from_email_address: fsrm@server.intern
    state: present
'''

RETURN = r'''
settings:
  description: returns all settings that can be set by the module.
  returned: always
  type: dict
'''