#!/bin/bash

echo ${GPG_TRUST_OWNERS} | base64 --decode > trust-file
gpg --import-ownertrust < trust-file
echo ${GPG_PUBLIC_KEY} | base64 --decode | gpg --import
echo ${GPG_PRIVATE_KEY} | base64 --decode | gpg --import --batch
echo "use-agent" >> ${HOME}/.gnupg/gpg.conf
echo "pinentry-mode loopback" >> ${HOME}/.gnupg/gpg.conf
touch ${HOME}/.gnupg/gpg-agent.conf
echo "allow-loopback-pinentry" >> ${HOME}/.gnupg/gpg-agent.conf