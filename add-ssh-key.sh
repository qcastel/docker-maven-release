#!/usr/bin/env bash
set -e
eval $(ssh-agent -s)

echo "Do a SSH add with the key under env 'SSH_PRIVATE_KEY'"
mkdir -p ${SSH_ROOT_FOLDER}/
echo "$SSH_PRIVATE_KEY" | base64 -d > ${SSH_ROOT_FOLDER}/id_rsa
chmod 600 ${SSH_ROOT_FOLDER}/id_rsa


echo "Set StrictHostKeyChecking no"
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ${SSH_ROOT_FOLDER}/config

ssh-keyscan -t rsa github.com >> ${SSH_ROOT_FOLDER}/known_hosts
ssh-keyscan -t rsa gitlab.com >> ${SSH_ROOT_FOLDER}/known_hosts
ssh-keyscan -t rsa bitbucket.org >> ${SSH_ROOT_FOLDER}/known_hosts

if [[ ! -z "${SSH_EXTRA_KNOWN_HOST}" ]]; then
  echo "Whitelist  ${SSH_EXTRA_KNOWN_HOST} in ${SSH_ROOT_FOLDER}/known_hosts"
  ssh-keyscan -t rsa ${SSH_EXTRA_KNOWN_HOST} >> ${SSH_ROOT_FOLDER}/known_hosts
fi