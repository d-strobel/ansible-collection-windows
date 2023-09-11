#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2022, Dustin Strobel (@d-strobel),
# GNU General Public License v3.0+ (see LICENSE or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: wsus_email_notification_setting
short_description: Modify email notification settings
description:
- Modify smtp and email notification settings
options:
  smtp_host:
    description:
    - Set the smtp hostname to use for email notifications.
    type: str
  smtp_port:
    description:
    - Set the smtp port of the smtp host to use for email notifications.
    - You cannot absent this option. Port 25 will always be the default.
    type: int
    default: 25
  smtp_username:
    description:
    - Set the smtp username for authentication to the smtp host.
    - Reuired when smtp_authentication_required is true.
    type: str
  smtp_password:
    description:
    - Set the smtp password for authentication to the smtp host.
    - Reuired when smtp_authentication_required is true.
    type: str
  smtp_password_update:
    description:
    - Define how the password is updated.
    - Set to C(on_create) to set the password only on the first run.
    - Set to C(always) to set the password every time your playbook runs.
    type: str
    default: on_create
    choices: [ always, on_create ]
  smtp_authentication_required:
    description:
    - Define if the smtp host requires an authentication.
    type: bool
    default: false
  email_language:
    description:
    - Define language of the email.
    type: str
    default: en
  sender_display_name:
    description:
    - Define the display name of the email sender.
    type: str
  sender_email_address:
    description:
    - Define the email address of the sender.
    type: str
  send_sync_notification:
    description:
    - Define if sync notifications should be sent.
    type: bool
  sync_notification_recipients:
    description:
    - A list of recipients for sync notifications.
    - If you want to remove all recipients you must change send_sync_notification to false.
    type: list
    elements: str
  send_status_notification:
    description:
    - Define if status notifications should be sent.
    type: bool
  status_notification_recipients:
    description:
    - A list of recipients for status notifications.
    - If you want to remove all recipients you must change send_status_notification to false.
    type: list
    elements: str
  status_notification_frequency:
    description:
    - Define how often the status notifcation should be sent.
    type: str
    default: daily
    choices: [ daily, weekly ]
  status_notification_time:
    description:
    - Define the time of day where the status notifcation should be sent.
    - The parameter must be in the format hh:mm:ss (hour:minutes:seconds).
    - The time is in Coordinated Universal Time (UTC).
    type: str
  state:
    description:
    - Set to C(present) to ensure the settings are present.
    - Set to C(absent) to ensure the settings are removed.
    type: str
    default: present
    choices: [ absent, present ]

author:
- Dustin Strobel (@d-strobel)
'''
