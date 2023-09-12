#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel), Yasmin Hinel (@seasxlticecream)
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: win_adfs_native_client_application
short_description: Add or modify native client applications
description:
- Adds or modify a native client application for the Active Directory Federation Services.
- Change the name, description, redirect uri or logout uri to the native client application
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
    - The identifier of the native client application.
    type: str
    required: yes
  name:
    description:
    - The name of the native client application.
    type: str
  description:
    description:
    - The description for the native client application.
    type: str
  redirect_uri:
    description:
    - The redirect uri(s) for the native client application that is needed for the OAuth 2.0 client
    - If not being used in the task, it will paste an empty string automatically
    type: list
  logout_uri:
    description:
    - The logout uri for the native client application that is needed for the OAuth 2.0 client.
    type: str
author:
- Dustin Strobel (@d-strobel)
- Yasmin Hinel (@seasxlticecream)
'''

EXAMPLES = r'''
- name: Ensure native application group is present
  d_strobel.windows_adfs.win_adfs_native_client_application:
    group_identifier: test_group
    state: present
- name: Create a native application group
  d_strobel.windows_adfs.win_adfs_native_client_application:
    group_identifier: test_group
    name: Test Group
    description: Test description
    redirect_uri:
      - https://example.de
      - https://example.com
    logout_uri: https://example.com/logout
    state: present
- name: Remove native application group test_group
  d_strobel.windows_adfs.win_adfs_native_client_application:
    group_identifier: test_group
    state: absent
- name: Set the description of the native application group
  d_strobel.windows_adfs.win_adfs_native_client_application:
    group_identifier: test_group
    description: Managed by XXX
    state: present
- name: Set the redirect uri to the native application group
  d_strobel.windows_adfs.win_adfs_native_client_application:
    group_identifier: test_group
    redirect_uri:
      - https://example.de
      - https://example.com
    state: present
- name: Remove the logout uri and set a redirect uri to the native application group:
  d_strobel.windows_adfs.win_adfs_native_client_application:
    group_identifier: test_group
    redirect_uri:
      - https://example.de
      - https://example.com
    state: present
'''