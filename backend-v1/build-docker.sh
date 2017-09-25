#!/usr/bin/env bash
mvn clean install -Pmysql,kubernetes fabric8:build -Ddocker.image.name=ceposta/backend-mysql:v1