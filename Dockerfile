FROM maven:3.6.1-jdk-13-alpine

RUN apk update && apk add git openssh gnupg

COPY ./add-ssh-key.sh /usr/local/bin
COPY ./release.sh /usr/local/bin
COPY ./settings.xml /usr/share/maven/conf
