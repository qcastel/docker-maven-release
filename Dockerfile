FROM alpine:3

RUN apk --update --no-cache add bash maven git openssh gnupg libxml2-utils vim openjdk8 jq
RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk --update add openjdk17 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk --update add openjdk21 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk --update add openjdk25 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

RUN apk add bash gettext
# Vaadin needs node
RUN apk add --update nodejs npm
RUN apk --no-cache add libc6-compat

COPY ./add-ssh-key.sh /usr/local/bin
COPY ./setup-maven-servers.sh /usr/local/bin
COPY ./release.sh /usr/local/bin
COPY ./settings-template.xml /usr/share/java/maven-3/conf/
COPY ./settings-server-template.xml /usr/share/java/maven-3/conf/
COPY ./simplelogger.properties /usr/share/java/maven-3/conf/logging/simplelogger.properties

ARG SETTINGS_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-template.xml"
ENV SETTINGS_TEMPLATE_FILE=$SETTINGS_TEMPLATE_FILE

ARG SETTINGS_SERVER_TEMPLATE_FILE="/usr/share/java/maven-3/conf/settings-server-template.xml"
ENV SETTINGS_SERVER_TEMPLATE_FILE=$SETTINGS_SERVER_TEMPLATE_FILE

ARG SETTINGS_FILE="/usr/share/java/maven-3/conf/settings.xml"
ENV SETTINGS_FILE=$SETTINGS_FILE

RUN mkdir /root/.m2
