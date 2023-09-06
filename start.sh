#!/usr/bin/env bash
# @Time : 2023/9/5 16:32
# @Author : ziyaoxie
# @File : start.sh

PID_FILE=jekyll.pid
LOG_FILE=jekyll.log
LOCAL_IP=$( ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}' )

bundle exec jekyll clean --trace
bundle exec jekyll build --trace
bundle exec jekyll serve --trace -H "${LOCAL_IP}" -P 4000 > ${LOG_FILE} 2>&1 &
echo $! > ${PID_FILE}
