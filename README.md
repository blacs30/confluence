# docker-confluence

This is a Docker-Image for Atlassian Confluence based on [Alpine Linux](http://alpinelinux.org/), which is kept as small as possible.

## Features

* Small image size
* Setting application context path
* Setting JVM xms and xmx values
* Setting proxy parameters in server.xml to run it behind a reverse proxy (TOMCAT_PROXY_* ENV)

## Variables

* TOMCAT_CONTEXT_PATH: default context path for confluence is "/"

Using with HTTP reverse proxy, not necessary with AJP:

* TOMCAT_PROXY_NAME: domain of confluence instance
* TOMCAT_PROXY_PORT: e.g. 443
* TOMCAT_PROXY_SCHEME: e.g. "https"
* TOMCAT_PROXY_SECURE: e.g. "true"

JVM memory management:

* JVM_MEMORY_MIN
* JVM_MEMORY_MAX

JVM truststore certificate, the public cert is expected in ${CONFLUENCE_HOME}/public.crt:

* SSL_SERVER_ALIAS: e.g. confluence.example.com

## Ports
* 8009 (Confluence AJP)
* 8090 (Confluence HTTP)
* 8091 (Synchrony HTTP)

## Build container
Specify the application version in the build command:

```bash
docker build --build-arg VERSION=x.x.x .
```

## Getting started

Run Confluence standalone and navigate to `http://[dockerhost]:8090` to finish configuration:

```bash
docker run -tid -p 8090:8090 -p 8091:8091 blacs30/confluence:latest
```

Run Confluence standalone with customised jvm settings and navigate to `http://[dockerhost]:8090` to finish configuration:

```bash
docker run -tid -p 8090:8090 -p 8091:8091 -e JVM_MEMORY_MIN=2g -e JVM_MEMORY_MAX=4g blacs30/confluence:latest
```

Specify persistent volume for Confluence data directory:

```bash
docker run -tid -p 8090:8090 -p 8091:8091 -v confluence_data:/var/opt/atlassian/application-data/confluence blacs30/confluence:latest
```

Run Confluence behind a reverse (SSL) proxy and navigate to `https://wiki.yourdomain.com`:

```bash
docker run -d -e TOMCAT_PROXY_NAME=wiki.yourdomain.com -e TOMCAT_PROXY_PORT=443 -e TOMCAT_PROXY_SCHEME=https blacs30/confluence:latest
```

Run Confluence behind a reverse (SSL) proxy with customised jvm settings and navigate to `https://wiki.yourdomain.com`:

```bash
docker run -d -e TOMCAT_PROXY_NAME=wiki.yourdomain.com -e TOMCAT_PROXY_PORT=443 -e TOMCAT_PROXY_SCHEME=https -e JVM_MEMORY_MIN=2g -e JVM_MEMORY_MAX=4g blacs30/confluence:latest
```
