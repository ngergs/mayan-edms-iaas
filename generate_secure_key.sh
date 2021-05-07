#!/bin/bash
KEY_FILE=ansible/roles/edms/files/secure_key
if [ -f "$KEY_FILE" ]; then
  echo "$KEY_FILE already exists. Needs to be manually removed to generate a new key."
else
  dd if=/dev/urandom of=$KEY_FILE  bs=1024 count=4
fi

ENV_FILE=ansible/roles/edms/files/env
if [ -f "$ENV_FILE" ]; then
  echo "$ENV_FILE already exists. Needs to be manually removed to generate a env file."
else
  REDIS_PASSWORD=$(pwgen 64)
  DATABASE_PASSWORD=$(pwgen 64)

  #define the template.
  tee $ENV_FILE << EOF > /dev/null
MAYAN_REDIS_PASSWORD=$REDIS_PASSWORD
MAYAN_DATABASE_DB=mayan
MAYAN_DATABASE_PASSWORD=$DATABASE_PASSWORD
MAYAN_DATABASE_USER=mayan
EOF
fi
