#!/bin/bash
[ -z "$1" ] && echo "empty args" && exit

function assert() {
    v=$?
    if [ "$v" != "0" ]; then
        echo "fail"
        exit
    fi
}
docker build . -t mutating:${1}
assert $?
docker tag mutating:${1} harbor.develop.com/ops/mutating:v${1}
assert $?
docker push harbor-dev.tec-develop.com/oam/mutating:v${1}
assert $?
