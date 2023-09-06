#!/usr/bin/env bash
# @Time : 2023/9/5 16:32
# @Author : ziyaoxie
# @File : clean.sh

PID_FILE=jekyll.pid
LOG_FILE=jekyll.log
CACHE_DIR=.jekyll-cache
TEMP_DIR=_site

bundle exec jekyll clean

[ -f ${PID_FILE} ] && rm ${PID_FILE}
[ -f ${LOG_FILE} ] && rm ${LOG_FILE}
[ -d ${CACHE_DIR} ] && rm -r ${CACHE_DIR}
[ -d ${TEMP_DIR} ] && rm -r ${TEMP_DIR}
