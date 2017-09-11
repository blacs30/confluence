##############################################################################
# Dockerfile to build Atlassian Confluence container images
# Based on frolvlad/alpine-oraclejdk8:cleaned
##############################################################################

FROM frolvlad/alpine-oraclejdk8:cleaned
MAINTAINER Blacs30 <gitlab@lisowski-development.com>

# permissions
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

ARG VERSION

# Setup useful environment variables
ENV CONFLUENCE_INST=/opt/confluence \
  CONFLUENCE_HOME=/var/opt/confluence \
  SYSTEM_USER=confluence \
  SYSTEM_GROUP=confluence \
  SYSTEM_HOME=/home/confluence \
  MYSQL_DRIVER_VERSION=5.1.38 \
  POSTGRESQL_DRIVER_VERSION=9.4.1207 \
  DEBIAN_FRONTEND=noninteractive

# Install Atlassian Confluence and helper tools and setup initial home
# directory structure.
RUN set -x \
  && apk update \
  && apk add \
  bash \
  tar \
  xmlstarlet \
  wget \
  ca-certificates \
  --update-cache \
  --allow-untrusted \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
  --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
  && update-ca-certificates    \
  && mkdir -p ${CONFLUENCE_INST} \
  && mkdir -p ${CONFLUENCE_HOME} \
  && mkdir -p ${SYSTEM_HOME} \
  && addgroup -S ${SYSTEM_GROUP} \
  && adduser -S -D -G ${SYSTEM_GROUP} -h ${SYSTEM_HOME} -s /bin/sh ${SYSTEM_USER} \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${SYSTEM_HOME} \
  && wget -O /tmp/atlassian-confluence-${VERSION}.tar.gz https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-${VERSION}.tar.gz \
  && tar xfz /tmp/atlassian-confluence-${VERSION}.tar.gz --strip-components=1 -C ${CONFLUENCE_INST} \
  && rm /tmp/atlassian-confluence-${VERSION}.tar.gz \
  && chown -R ${SYSTEM_USER}:${SYSTEM_GROUP} ${CONFLUENCE_INST} \
  && touch -d "@0" "${CONFLUENCE_INST}/conf/server.xml" \
  && touch -d "@0" "${CONFLUENCE_INST}/bin/setenv.sh" \
  && touch -d "@0" "${CONFLUENCE_INST}/confluence/WEB-INF/classes/confluence-init.properties" \
  # Install database drivers
  && rm -f ${CONFLUENCE_INST}/lib/mysql-connector-java*.jar \
  && wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
  && tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz -C /tmp \
  && cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar ${CONFLUENCE_INST}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar                                \
  && rm -f ${CONFLUENCE_INST}/lib/postgresql-*.jar                                                                \
  && wget -O ${CONFLUENCE_INST}/lib/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar \
  # Install atlassian ssl tool
  # Clean caches and tmps
  && rm -rf /var/cache/apk/*                   \
  && rm -rf /tmp/*                                   \
  && rm -rf /var/log/*


ADD files/service /usr/local/bin/service
ADD files/entrypoint /usr/local/bin/entrypoint

EXPOSE 8009 8090 8091

VOLUME ${CONFLUENCE_HOME}

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/local/bin/service"]

