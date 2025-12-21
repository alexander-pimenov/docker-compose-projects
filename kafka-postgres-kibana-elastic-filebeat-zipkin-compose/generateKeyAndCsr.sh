#!/bin/bash

export CERT_ENV_NAME="sigma-dev"

# 1. Generate csr

openssl req -new \
-newkey rsa:2048 -nodes \
-keyout "gen/mms.$CERT_ENV_NAME.key" \
-out "gen/mms.$CERT_ENV_NAME.csr" \
-config csr.$CERT_ENV_NAME.conf

# 2. Check csr

openssl req -text -noout -verify -in "gen/mms.$CERT_ENV_NAME.csr"
