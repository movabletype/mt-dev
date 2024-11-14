#!/bin/bash

mkdir -p certs
touch index.txt
echo 1000 > serial

openssl genrsa -out certs/ca-key.pem 2048
openssl req -new -x509 -nodes -days 3650 -key certs/ca-key.pem -out certs/ca-cert.pem \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=MyOrganization/CN=MyCA"

openssl genrsa -out certs/server-key.pem 2048
openssl req -new -key certs/server-key.pem -out certs/server-req.pem \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=MyOrganization/CN=db"
openssl x509 -req -in certs/server-req.pem -days 3650 \
    -CA certs/ca-cert.pem -CAkey certs/ca-key.pem -CAcreateserial \
    -out certs/server-cert.pem

openssl genrsa -out certs/client-key.pem 2048
openssl req -new -key certs/client-key.pem -out certs/client-req.pem \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=MyOrganization/CN=mysqlclient"
openssl x509 -req -in certs/client-req.pem -days 3650 \
    -CA certs/ca-cert.pem -CAkey certs/ca-key.pem -CAcreateserial \
    -out certs/client-cert.pem
