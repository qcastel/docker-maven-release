MAVEN_SERVERS_XML='';
echo "Setup the maven server credentials for the settings.xml"

#For retro-compatilibity
if [[ -n "$MAVEN_REPO_SERVER_ID" ]]; then
  echo "WARNING: MAVEN_REPO_SERVER_ID is now deprecated, please use MAVEN_SERVERS instead."
  export MAVEN_REPO_SERVER_PRIVATE_KEY="${SSH_ROOT_FOLDER}/id_rsa"
  export MAVEN_REPO_SERVER_PASSPHRASE=${SSH_PASSPHRASE}
  MAVEN_SERVERS_XML=$(envsubst < $SETTINGS_SERVER_TEMPLATE_FILE)
fi

for row in $(echo "${MAVEN_SERVERS}" | jq -r '.[] | @base64'); do
    _jq() {
        echo "${row}" | base64 -d | jq -r "${1}"
    }
   export MAVEN_REPO_SERVER_ID=$(_jq '.id')
   export MAVEN_REPO_SERVER_USERNAME=$(_jq '.username')
   export MAVEN_REPO_SERVER_PASSWORD=$(_jq '.password')
   export MAVEN_REPO_SERVER_PRIVATE_KEY=$(_jq '.privateKey')

   echo "Setup the server $MAVEN_REPO_SERVER_ID"
   if [[ "$MAVEN_REPO_SERVER_PRIVATE_KEY" == "null" ]]; then
        export MAVEN_REPO_SERVER_PRIVATE_KEY="${SSH_ROOT_FOLDER}/id_rsa"
   fi
   export MAVEN_REPO_SERVER_PASSPHRASE=$(_jq '.passphrase')
   if [[ "$MAVEN_REPO_SERVER_PASSPHRASE" == "null" ]]; then
        export MAVEN_REPO_SERVER_PASSPHRASE=${SSH_PASSPHRASE}
   fi
   templateReplaced=$(envsubst < $SETTINGS_SERVER_TEMPLATE_FILE);
   MAVEN_SERVERS_XML="${MAVEN_SERVERS_XML}${templateReplaced}"

done

export MAVEN_SERVERS_XML="$MAVEN_SERVERS_XML"

echo "The following servers section that is going to be replace in the settings.xml:\n $MAVEN_SERVERS_XML"

echo "Replacing maven servers in template ${SETTINGS_SERVER_TEMPLATE_FILE} to ${SETTINGS_TEMPLATE_FILE}"
envsubst < ${SETTINGS_TEMPLATE_FILE} > ${SETTINGS_FILE}
cat ${SETTINGS_FILE}