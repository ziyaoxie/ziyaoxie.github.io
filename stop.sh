#!/usr/bin/env bash
# @Time : 2023/9/5 16:32
# @Author : ziyaoxie
# @File : stop.sh

PID_FILE=jekyll.pid

if [ -f ${PID_FILE} ]; then
  PID=$(cat ${PID_FILE})
  kill -9 "${PID}"
fi
