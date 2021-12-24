FROM alpine:3

RUN apk --update --no-cache add bash maven git openssh gnupg libxml2-utils vim openjdk8 jq
RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk --update add openjdk14 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk --update add openjdk15 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk --update add openjdk16 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk --update add openjdk17 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

COPY ./add-ssh-key.sh /usr/local/bin
COPY ./setup-maven-servers.sh /usr/local/bin
COPY ./release.sh /usr/local/bin
COPY ./settings.xml /usr/share/java/maven-3/conf/
COPY ./settings-server-template.xml /usr/share/java/maven-3/conf/
COPY ./simplelogger.properties /usr/share/java/maven-3/conf/logging/simplelogger.properties

ARG SETTINGS_SERVER_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-server-template.xml"
ENV SETTINGS_SERVER_TEMPLATE_FILE=$SETTINGS_SERVER_TEMPLATE_FILE

RUN mkdir /root/.m2
