#!/bin/bash

for file in ./src/"day$1"/*.txt; do
    gpg --batch --passphrase "$GPG_PASSPHRASE_INPUTS" --symmetric --cipher-algo AES256 "$file"
done
