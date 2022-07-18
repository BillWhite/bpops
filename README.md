# BPOPS - An API for distributing OpenSSH Certificates
## Introduction
## Core API
### Authentication
### Authorization
### Operations
#### Users, groups, principals
1.) add_user(email, host, user_name = email)
1.) delete_user(user_name, host)
1.) add_group(group_name)
1.) add_principal_to_group(principal, host, group_name)
1.) add_user_to_group(group_name, user_name, host)
1.) remove_principal_from_group(principal, host, group_name)
#### Hosts, groups
1.) add_host()
#### Fetching Certificates
1.) get_user_certificate(user_name, group_name) -> certificate
#### Maintenance
1.) create_signing_authority(authority_name)
#### Authentication
1.) authenticate(user, authscheme, token) -> token
1.) 
