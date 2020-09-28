#!/usr/bin/env bash
set -e

# avoid the release loop by checking if the latest commit is a release commit
readonly local last_release_commit_hash=$(git log --author="$GIT_RELEASE_BOT_NAME" --pretty=format:"%H" -1)
echo "Last $GIT_RELEASE_BOT_NAME commit: ${last_release_commit_hash}"
echo "Current commit: ${CI_COMMIT_SHA}"
if [[ "${last_release_commit_hash}" = "${CI_COMMIT_SHA}" ]]; then
     echo "Skipping for $GIT_RELEASE_BOT_NAME commit"
     exit 0
fi

# Filter the branch to execute the release on
readonly local branch=${CI_COMMIT_REF_NAME##*/}
echo "Current branch: ${branch}"
if [[ -n "$RELEASE_BRANCH_NAME" && ! "${branch}" = "$RELEASE_BRANCH_NAME" ]]; then
     echo "Skipping for ${branch} branch"
     exit 0
fi

# Making sure we are on top of the branch
echo "Git checkout branch ${CI_COMMIT_REF_NAME##*/}"
git checkout ${CI_COMMIT_REF_NAME##*/}
echo "Git reset hard to ${CI_COMMIT_SHA}"
git reset --hard ${CI_COMMIT_SHA}

# This script will do a release of the artifact according to http://maven.apache.org/maven-release/maven-release-plugin/
echo "Setup git user name to '$GIT_RELEASE_BOT_NAME'"
git config --global user.name "$GIT_RELEASE_BOT_NAME";
echo "Setup git user email to '$GIT_RELEASE_BOT_EMAIL'"
git config --global user.email "$GIT_RELEASE_BOT_EMAIL";

# Setup GPG
echo "GPG_ENABLED '$GPG_ENABLED'"
if [[ $GPG_ENABLED == "true" ]]; then
     echo "Enable GPG signing in git config"
     git config --global commit.gpgsign true
     echo "Using the GPG key ID $GPG_KEY_ID"
     git config --global user.signingkey $GPG_KEY_ID
     echo "GPG_KEY_ID = $GPG_KEY_ID"
     echo "Import the GPG key"
     echo  "$GPG_KEY" | base64 -d > private.key
     gpg --import ./private.key
     rm ./private.key
else
  echo "GPG signing is not enabled"
fi

#Setup SSH key
echo "Add SSH key"
add-ssh-key.sh 

# Setup maven local repo
if [[ -n "$MAVEN_LOCAL_REPO_PATH" ]]; then
     MAVEN_REPO_LOCAL="$-Dmaven.repo.local=$MAVEN_LOCAL_REPO_PATH"
fi

# Setup next version
if [[ -n "$VERSION_MINOR" ]]; then
     RELEASE_PREPARE_OPTS="$RELEASE_PREPARE_OPTS -DdevelopmentVersion=\${parsedVersion.majorVersion}.\${parsedVersion.nextMinorVersion}.0-SNAPSHOT"
fi

if [[ -n "$VERSION_MAJOR" ]]; then
     RELEASE_PREPARE_OPTS="$RELEASE_PREPARE_OPTS -DdevelopmentVersion=\${parsedVersion.nextMajorVersion}.0.0-SNAPSHOT"
fi

# Do the release
echo "Do mvn release:prepare with options $RELEASE_PREPARE_OPTS and arguments $MAVEN_ARGS"
mvn $MAVEN_REPO_LOCAL $RELEASE_PREPARE_OPTS build-helper:parse-version release:prepare -B -Darguments="$MAVEN_ARGS"
echo "Do mvn release:perform with options $RELEASE_PREPARE_OPTS and arguments $MAVEN_ARGS"
mvn $MAVEN_REPO_LOCAL $RELEASE_PREPARE_OPTS build-helper:parse-version release:perform -B -Darguments="$MAVEN_ARGS"
