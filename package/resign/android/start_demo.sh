#!/bin/sh

#别名
KEY_ALIAS=alias
ALIAS_PASSWORD=XXX
STORE_PASSWORD=XXX

app_name=appName
input_file='./appName.apk'
keystore_path='./appName.keystore'
keystore_password=$STORE_PASSWORD
key_password=$ALIAS_PASSWORD

./resign.sh $app_name $input_file $keystore_path $keystore_password $key_password
