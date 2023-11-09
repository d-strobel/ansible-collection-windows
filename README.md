[![build](https://github.com/d-strobel/ansible-collection-windows/actions/workflows/release.yml/badge.svg)](https://github.com/d-strobel/ansible-collection-windows/actions/workflows/build.yml)
[![AGPL-3.0 Licensed](https://img.shields.io/github/license/d-strobel/ansible-collection-windows)](https://github.com/d-strobel/ansible-collection-windows/blob/main/LICENSE)

# Ansible Collection: d_strobel.windows

Collection of windows ansible modules.

## Modules

| Category | Module | Description |
|----------|--------|-------------|
| adfs | adfs_application_group | Add or modify application groups |
| adfs | adfs_native_client_application | Add or modify native client applications |
| dhcp | dhcp_class_v4 | Add, remove or change a dhcp class. |
| dhcp | dhcp_domain_authorization | Add or remove a dhcp server to a domain controller. |
| dhcp | dhcp_exclusion_v4 | Add or remove an IPv4 exclusion range. |
| dhcp | dhcp_failover_v4 | Add or remove an IPv4 failover. |
| dhcp | dhcp_option_definition_v4 | Add, remove or change an IPv4 option definition. |
| dhcp | dhcp_scope_v4 | Add or remove a IPv4 dhcp scope. |
| fsrm | fsrm_file_screen_template | Add or modify file screen templates |
| fsrm | fsrm_filegroup | Add or modify file groups |
| fsrm | fsrm_setting | Modify general settings |
| rdl | rdl_company_info | Add or remove the company info of the wmi object. |
| rdl | rdl_server_domain_status | Add or remove the server to the Remote Desktop license server group in a given domain. |
| rdl | rdl_server_status | Activate, deactivate or reactivate the remote desktop license server. |
| wsus | wsus_computer_target_group | Add or remove a computer group. |
| wsus | wsus_email_notification_setting | Modify email notification settings |
| wsus | wsus_install_approval_rule | Modify an update install approval rule |
| wsus | wsus_store_update_location | Modify update file storage location. Store them locally or on Microsoft Update |
| wsus | wsus_subscription | Modify the subscription. |

## Release

1. Edit the version number in the [galaxy.yml](galaxy.yml) file.
2. Run the github action "Release".
