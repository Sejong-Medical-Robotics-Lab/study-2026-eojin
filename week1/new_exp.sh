#!/bin/bash

mkdir -p ~/robot_study/experiments/$1/{data,logs,results}

echo "# 실험 노트: $1 ($(date +%F))" > ~/robot_study/experiments/$1/README.md

echo "실험 폴더 생성 완료: $1"
