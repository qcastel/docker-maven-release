FROM alpine:3

RUN apk --update --no-cache add bash maven git openssh gnupg libxml2-utils vim openjdk8 jq
RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN apk --update add openjdk14-jre --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk --update add openjdk15-jre --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

COPY ./add-ssh-key.sh /usr/local/bin
COPY ./release.sh /usr/local/bin
COPY ./settings.xml /usr/share/maven/conf
COPY ./simplelogger.properties /usr/share/java/maven-3/conf/logging/simplelogger.properties
RUN mkdir /root/.m2