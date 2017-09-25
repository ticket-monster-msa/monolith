#!/usr/bin/env bash
mvn clean install -Pmysql,kubernetes -DskipITs=true fabric8:build