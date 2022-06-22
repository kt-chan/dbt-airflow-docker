#!/usr/bin/env bash
docker-compose build
docker-compose up spark-master -d
docker-compose up spark-worker-1 -d
docker-compose up spark-worker-2 -d
docker-compose up spark-thrift -d
docker-compose up jupyter-notebook -d

