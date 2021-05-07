#!/bin/bash
printf '_443._tcp.%s. IN TLSA 1 1 1 %s\n' {{domain}} $(openssl x509 -in /etc/letsencrypt/live/{{domain}}/cert.pem -noout -pubkey |
        openssl pkey -pubin -outform DER |
        openssl dgst -sha256 -binary |
        hexdump -ve '/1 "%02x"')
