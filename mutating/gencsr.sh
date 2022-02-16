#!/bin/bash
mkdir -p tls
openssl genrsa -out tls/ca.key 2048
openssl req -x509 -new -nodes -key tls/ca.key -subj "/CN=mutating.kube-ops.svc" -days 10000 -out tls/ca.crt
openssl genrsa -out tls/tls.key 2048
openssl req -new -key tls/tls.key -out tls/tls.csr -config csr.conf
openssl x509 -req -in tls/tls.csr -CA tls/ca.crt -CAkey tls/ca.key -CAcreateserial -out tls/tls.crt -days 10000 -extensions v3_ext -extfile csr.conf
kubectl create secret tls pod-mutating --dry-run=client --cert=tls/tls.crt --key=tls/tls.key -o yaml > secret.yaml

# printf the caBundle for MutatingWebhookConfiguration
openssl base64 -A < tls/ca.crt
echo
