# BPOPS - An API for distributing OpenSSH Certificates
## Introduction
### Examples
Given a user named NNN in groups A, B and C on host NNNHost.
1. We give NNN some files in a zip file. These files contain
   authentication and authorization to connect to the auth
   authority to get certificates.
      1. A file user.txt containing the user's UID and some
         instructions.
      2. A file with status for the operation.
      3. Some files:
         - .ssh/config                                      - An empty config file
							      which just includes 
							      ssh_config.d/*.conf
         - .ssh/ssh_config.d/auth@authhost.auth_config.conf - A stanza for contacting auth.
         - .ssh/auth@authhost.auth_rsa-cert.pub             - Certificate for auth.
         - .ssh/auth@authhost.auth_rsa.pub                  - Public key for auth.
         - .ssh/auth@authhost.auth_rsa                      - Private key for auth.
   The certificate files are NNN specific. They authenticate NNN to
   authhost, which knows what operations NNN can perform there. For
   example, NNN may be able to fetch his or her own authentication
   information, but not change the authhost authentication database.
   The certificate is restricted to executing one single command.

   This operation can be done or redone et any time. The resulting files 
   will overwrite the existing files. This may be done if the authentication 
   certificate has expired, or if NNN's group membership has changed..
2. After extraction, the user executes:
   <ssh auth@authhome get_user_files --user NNN@NNNHost --groups A,B,C>
   If anything fails, say the auth@authhome credentials fail, the
   name NNN@NNNHost is not authorized or not a member of all the
   groups, then nothing happens. If all authentication and authorization
   succeeds, the result is a zip file with some files:
      - .ssh/ssh_config.d/NNN@A_config.conf - A stanza for group A access.
      - .ssh/ssh_config.d/NNN@B_config.conf - A stanza for group B access.
      - .ssh/ssh_config.d/NNN@C_config.conf - A stanza for group C access.
      - .ssh/NNN@A_rsa-cert.pub             - Certificate for group A.
      - .ssh/NNN@A_rsa.pub                  - Public key for group A.
      - .ssh/NNN@A_rsa                      - Private key for group A.
      - .ssh/NNN@B_rsa-cert.pub             - Certificate for group B.
      - .ssh/NNN@B_rsa.pub                  - Public key for group B.
      - .ssh/NNN@B_rsa                      - Private key for group B.
      - .ssh/NNN@C_rsa-cert.pub             - Certificate for group C.
      - .ssh/NNN@C_rsa.pub                  - Public key for group C.
      - .ssh/NNN@C_rsa                      - Private key for group C.
   It's also possible to use --groups all.
3. The user can now ssh to any group A, B or C host using:
   - ssh NNN@Ahost1
   - ssh NNN@Bhost1
   - ssh NNN@Bhost1
## Core API
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
