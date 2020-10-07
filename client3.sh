#!/bin/bash

export VAULT_ADDR=http://127.0.0.1:8196
while true; do
  vault write transit/encrypt/test plaintext=abcd; sleep 0.1
done