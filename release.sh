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

if [ -d "${M2_HOME_FOLDER}" ]; then
     echo "INFO - M2 folder '${M2_HOME_FOLDER}' not empty. We therefore will beneficy from the CI cache"; 
else 
     echo "WARN - No M2 folder '${M2_HOME_FOLDER}' found. We therefore won't beneficy from the CI cache"; 
fi

# Filter the branch to execute the release on
readonly local branch=${CI_COMMIT_REF_NAME##*/}
echo "Current branch: ${branch}"
echo "Release branch name: $RELEASE_BRANCH_NAME"
if [[ -n "$RELEASE_BRANCH_NAME" && ! "${branch}" = "$RELEASE_BRANCH_NAME" ]]; then
     echo "Skipping for ${branch} branch"
     exit 0
else 
     echo "We are on the release branch"
fi 

#Configure the default env variables
if [[ -z "${SSH_ROOT_FOLDER}" ]]; then
  SSH_ROOT_FOLDER=~/.ssh
fi
echo "Using SSH folder ${SSH_ROOT_FOLDER}"

if [[ -z "${M2_HOME_FOLDER}" ]]; then
  M2_HOME_FOLDER=/root/.m2
fi
echo "Using M2 repository folder ${M2_HOME_FOLDER}"

if [ -z "$(ls -A ${M2_HOME_FOLDER})" ]; then
  echo "${M2_HOME_FOLDER} is empty, this means we didn't hit a potential M2 cache :("
fi

if [[ -z "${GPG_ENABLED}" ]]; then
  echo "No GPG_ENABLED env setup -> GPG is disabled by default."
  export GPG_ENABLED=false
fi

echo "SKIP_GIT_SANITY_CHECK='${SKIP_GIT_SANITY_CHECK}'"

if [[ "$SKIP_GIT_SANITY_CHECK" == "false" ]]; then
  # Making sure we are on top of the branch
  echo "Git checkout branch ${CI_COMMIT_REF_NAME##*/}"
  git checkout ${CI_COMMIT_REF_NAME##*/}
  echo "Git reset hard to ${CI_COMMIT_SHA}"
  git reset --hard ${CI_COMMIT_SHA}
else 
  echo "Skipping git sanity check"
fi

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
     gpg --batch --import ./private.key
     rm ./private.key
     echo "List of keys:"
     gpg --list-secret-keys --keyid-format LONG
else
  echo "GPG signing is not enabled"
fi

#Setup SSH key
if [[ -n "${SSH_PRIVATE_KEY}" ]]; then
  echo "Add SSH key"
  add-ssh-key.sh
else
  echo "No SSH key defined"
fi

# Change the current folder to point to the maven project folder
if [[ -n "$MAVEN_PROJECT_FOLDER" ]]; then
  echo "Move to folder $MAVEN_PROJECT_FOLDER"
  cd $MAVEN_PROJECT_FOLDER
fi


APP_VERSION=`xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' pom.xml`
#verify we are not on a release tag
if [[ "$APP_VERSION" == *0 ]]; then 
     echo "Release is not a snapshot, move to next patch version and to snapshot"
     mvn  build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}-SNAPSHOT
     git commit -am "Prepare version for next release"
fi


# Setup next version
if [[ -n "$MAVEN_DEVELOPMENT_VERSION_NUMBER" ]]; then
      MAVEN_OPTION="$MAVEN_OPTION -DdevelopmentVersion=${MAVEN_DEVELOPMENT_VERSION_NUMBER}"
else 
  if [[ "$VERSION_MINOR" == "true" ]]; then
      MAVEN_OPTION="$MAVEN_OPTION -DdevelopmentVersion=\${parsedVersion.majorVersion}.\${parsedVersion.nextMinorVersion}.0-SNAPSHOT"
  elif [[ "$VERSION_MAJOR" == "true" ]]; then
      MAVEN_OPTION="$MAVEN_OPTION -DdevelopmentVersion=\${parsedVersion.nextMajorVersion}.0.0-SNAPSHOT"
  fi
fi


# Setup release version
if [[ -n "$MAVEN_RELEASE_VERSION_NUMBER" ]]; then
      MAVEN_OPTION="$MAVEN_OPTION -DreleaseVersion=${MAVEN_RELEASE_VERSION_NUMBER}"
fi


# Set access-token for gitrepo
if [[ -n "$GITREPO_ACCESS_TOKEN" && -z "${SSH_PRIVATE_KEY}" ]]; then
    echo "Git repo access token defined and no SSH setup. We then use the git repo access token via maven release to commit in the repo."
    MAVEN_OPTION="$MAVEN_OPTION -Dusername=$GITREPO_ACCESS_TOKEN"
else
  echo "Not using access token authentication, as no access token (via env GITREPO_ACCESS_TOKEN) defined or because an SSH key is defined and setup (via env SSH_PRIVATE_KEY)"
fi


# Do the release
echo "Do mvn release:prepare with options $MAVEN_OPTION and arguments $MAVEN_ARGS"
mvn $MAVEN_OPTION $MAVEN_REPO_LOCAL build-helper:parse-version release:prepare -B -Darguments="$MAVEN_ARGS"


# do release if prepare did not fail
if [[ ("$?" -eq 0) && ($SKIP_PERFORM == "false") ]]; then
  echo "Do mvn release:perform with options $MAVEN_OPTION and arguments $MAVEN_ARGS"
  mvn $MAVEN_OPTION $MAVEN_REPO_LOCAL build-helper:parse-version release:perform -B -Darguments="$MAVEN_ARGS"
fi

# rollback release if prepare or perform failed
if [[ "$?" -ne 0 ]] ; then
  echo "Rolling back release after failure"
  mvn $MAVEN_OPTION $MAVEN_REPO_LOCAL release:rollback -B -Darguments="$MAVEN_ARGS"
fi
