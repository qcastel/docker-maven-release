# Docker maven release

The docker image pre-setup with git, maven and gpg and a script to trigger a release by a bot

# Script
Script name: release.sh


## Environment variables

The script is expecting some environment variables:


- GPG_ENABLED: enable GPG signing
- GPG_KEY_ID: GPG signing KID
- GPG_KEY: GPG private key  base64 encoded.

- MAVEN_LOCAL_REPO_PATH: The maven local repository path
- MAVEN_REPO_SERVER_ID: Maven server repository id to push the artefacts to
- MAVEN_REPO_SERVER_USERNAME: Maven server repository username
- MAVEN_REPO_SERVER_PASSWORD: Maven server repository password
- MAVEN_ARGS: The maven arguments for the release

- GIT_RELEASE_BOT_NAME: The git user name for commiting the release
- GIT_RELEASE_BOT_EMAIL: The git user email for commiting the release

- GITREPO_ACCESS_TOKEN: GIT repo access token to push release commits

- CI_COMMIT_SHA: The commit SHA that triggered the workflow.
- CI_COMMIT_REF_NAME: The branch or tag ref that triggered the workflow.

- DOCKER_REGISTRY_CREDENTIAL: the docker registry credential in JSON format
- DOCKER_REGISTRY_URL: the docker registry url