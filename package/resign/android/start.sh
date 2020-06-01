#!/bin/sh

#别名
KEY_ALIAS=yuyue_changguan
ALIAS_PASSWORD=wusdj78Djw
STORE_PASSWORD=wusdj78Djw
app_name=XX

input_file="./${app_name}.apk"
keystore_path="/Users/taisam/app/keystore/yuyue_changguan.keystore"
keystore_password=$STORE_PASSWORD
key_password=$ALIAS_PASSWORD

#./resign.sh $app_name $input_file $keystore_path $keystore_password $key_password
./resign.sh $app_name $input_file $keystore_path $keystore_password $key_password