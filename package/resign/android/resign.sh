#!/bin/sh

#./resign.sh 'yuyue-sport' './yuyue-sport.apk‘ 'keystore_path' 'keystore_password' 'key_password'
cur_path=`pwd`


app_name=$1
input_file="$cur_path/$2"
keystore_path="$cur_path/$3"
keystore_password=$4
key_password=$5

timestamp=`date '+%Y%m%d%H%M%S'`
output_file="$cur_path/${app_name}_${timestamp}_signed.apk"
sdk_path=~/Library/Android/sdk/build-tools/28.0.3/lib/


#$cur_path/../android/app/my-release-key.keystore \

echo apk:$input_file output_file:$output_file sdk_path:$sdk_path keystore_path:$keystore_path


#rm -rf tmp/

#unzip -o -q $input_file -d tmp/

#cd tmp/assets/

#echo berfore modify:
#cat index.android.bundle | grep {env:

#修改环境
#sed -i '' "s/\({env:\)\('.*'\)/\1'${env}'/g" index.android.bundle

#cat index.android.bundle | grep {env:

#cd ..

#zip -o -r -q ../update_file.apk .

#jarsigner -verbose -keystore ../android/app/my-release-key.keystore -storepass 123456 -signedjar android_sign.apk $input_file my-key-alias

#cd /Users/liuxiaopeng/Library/Android/sdk/build-tools/28.0.3/


echo `pwd`
echo $cur_path

#./zipalign -v -p -f 4 $cur_path/t1.apk $cur_path/t2.apk

cd $sdk_path

#java -jar apksigner.jar sign  --ks key.jks  --ks-key-alias releasekey  --ks-pass pass:pp123456  --key-pass pass:pp123456  --out output.apk  input.apk

#echo $cur_path/../android/app/my-release-key.keystoress


java -jar apksigner.jar sign \
 --min-sdk-version 16 \
 --ks ${keystore_path} \
 --ks-pass pass:$keystore_password \
 --key-pass pass:$key_password \
 --out $output_file $input_file

#rm -rf tmp/
#rm -rf $cur_path/update_file.apk



#rm -rf tmp/META-INF/CERT.*ss
#rm -rf tmp/META-INF/MANIFEST.MF

java -jar apksigner.jar verify -v --print-certs $output_file  



