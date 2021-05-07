EDMS
=========

Instance that holds a mayan-edms webservice.


Requirements
------------

Host should be setup via terraform as described in the root project.

Role Variables
--------------

* domain: A domain that you own and which A and AAAA dns records point to the server used. This is used for the nginx.conf template.
* volume_name: Digitalocean volume name that will hold the LUKS encrypted data.
* https: If https with a letsencrypt certificate should be configure in nginx.
* hsts: If HSTS should be activated. Only relevant if https=true. max-age is configured to be 2 years.
* hsts_preload: If HSTS preloading should be activated. Only relevant if https=true and hsts=true.
* expect_ct: If the Expect-CT header should be set to enforce. max-age is configured to be 2 years.

Dependencies
------------


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

MIT

Author Information
------------------

SelfEnergy
