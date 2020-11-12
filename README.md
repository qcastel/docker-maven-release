# Docker maven release

The docker image pre-setup with git, maven and gpg and a script to trigger a release by a bot

# features supported
- GPG signing
- SSH git repo authentication
- Committing with a bot user
- incrementing Major, Minor or patch version
- Rolling back release if mvn prepared failed.
- custom release branch name
- timestamp on logs to facilitate troubleshooting maven performance issue.

# Script
Script name: release.sh


## Environment variables

The script is expecting some environment variables:


- GPG_ENABLED: enable GPG signing
- GPG_KEY_ID: GPG signing KID
- GPG_KEY: GPG private key base64 encoded.

- SSH_PRIVATE_KEY: SSH private key base64 encoded.
- SSH_ROOT_FOLDER: by default `${SSH_ROOT_FOLDER}`
- SSH_EXTRA_KNOWN_HOST: Add an extra hostname you need to get added to .ssh/known_hosts

- MAVEN_LOCAL_REPO_PATH: The maven local repository path
- MAVEN_REPO_SERVER_ID: Maven server repository id to push the artefacts to
- MAVEN_REPO_SERVER_USERNAME: Maven server repository username
- MAVEN_REPO_SERVER_PASSWORD: Maven server repository password
- MAVEN_PROJECT_FOLDER: the folder on which to execute maven
- MAVEN_ARGS: The maven arguments for the release
- MAVEN_OPTION: the maven options for the release

- GIT_RELEASE_BOT_NAME: The git user name for commiting the release
- GIT_RELEASE_BOT_EMAIL: The git user email for commiting the release

- SKIP_PERFORM: "false" to skip the maven perform

- GITREPO_ACCESS_TOKEN: GIT repo access token to push release commits

- CI_COMMIT_SHA: The commit SHA that triggered the workflow.
- CI_COMMIT_REF_NAME: The branch or tag ref ®that triggered the workflow.

- VERSION_MAJOR: "true" to increment the major version
- VERSION_MINOR: "true" to increment the minor version

- RELEASE_BRANCH_NAME: if defined, filter the branches to trigger a release on.
