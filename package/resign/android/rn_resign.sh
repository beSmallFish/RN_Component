#!/bin/sh

source resign.config

echo 1. start init

#./resign.sh 'yuyue-sport' './yuyue-sport.apk‘ 'keystore_path' 'keystore_password' 'key_password'
cur_path=`pwd`

input_file=$cur_path/$1
rn_bundle=$2

timestamp=`date '+%Y%m%d%H%M%S'`
output_file="${input_file%.*}_${timestamp}_signed.apk"

echo $cur_path
echo apk:$input_file  output_file:$output_file  sdk_path:$SDK_PATH  keystore_path:$KEYSTORE_PATH

if [[ $rn_bundle == 'true' ]]; then
  RN_BUNDLE_ENABLE=true
fi

##输入文件不存在
if [ ! -e $input_file ]; then
   echo "apk file ($input_file) not exist"
   exit 0
fi

##bundle 不存在
if [[ $RN_BUNDLE_ENABLE == 'true' ]] && [ ! -d $BUNDLE_IN_PATH ]; then
   echo "bundle file ($BUNDLE_IN_PATH) not exist"
   exit 0
fi


#cd tmp/assets/

#echo berfore modify:
#cat index.android.bundle | grep {env:

#cd tmp/
#cat AndroidManifest.xml | grep android:versionCode
#cat AndroidManifest.xml | grep android:versionName=
#cat AndroidManifest.xml | grep platformBuildVersionCode
#cat AndroidManifest.xml | grep platformBuildVersionName


if [[ $RN_BUNDLE_ENABLE == 'true' ]]; then

  rm -rf ${BUNDLE_OUT_PATH}

  unzip -o -q $input_file -d ${BUNDLE_OUT_PATH}

  #修改环境
  #sed -i '' "s/\({env:\)\('.*'\)/\1'${env}'/g" index.android.bundle

  #cat index.android.bundle | grep {env:

  #cd ..

  echo 2. copy bundle resource to apk

  echo 旧的bundle:
  ls -l ${BUNDLE_OUT_PATH}/assets/ | grep index
  echo 新的bundle
  ls -l ${BUNDLE_IN_PATH}/ | grep index

  cp -rf ${BUNDLE_IN_PATH}/drawable-hdpi/ ${BUNDLE_OUT_PATH}/res/drawable-hdpi-v4/
  cp -rf ${BUNDLE_IN_PATH}/drawable-mdpi/ ${BUNDLE_OUT_PATH}/res/drawable-mdpi-v4/
  cp -rf ${BUNDLE_IN_PATH}/drawable-xhdpi/ ${BUNDLE_OUT_PATH}/res/drawable-xhdpi-v4/
  cp -rf ${BUNDLE_IN_PATH}/drawable-xxhdpi/ ${BUNDLE_OUT_PATH}/res/drawable-xxhdpi-v4/
  cp -rf ${BUNDLE_IN_PATH}/drawable-xxxhdpi/ ${BUNDLE_OUT_PATH}/res/drawable-xxxhdpi-v4/
  cp -rf ${BUNDLE_IN_PATH}/raw/ ${BUNDLE_OUT_PATH}/res/raw/

  rm -rf ${BUNDLE_OUT_PATH}/assets/index.android.bundle
  cp -rf ${BUNDLE_IN_PATH}/index.android.bundle ${BUNDLE_OUT_PATH}/assets/index.android.bundle

  echo 3. repackage to ${output_file}

  #zip -oqr ${output_file} ${BUNDLE_OUT_PATH}/

  cd ${BUNDLE_OUT_PATH}/
  #echo currentPath: `pwd`
  zip -oqr ${output_file} .
  cd ..

  input_file=${output_file}
 # unzip -oq ${output_file} -d _test
 # ls -l _test/assets/ | grep index
fi

#jarsigner -verbose -keystore ../android/app/my-release-key.keystore -storepass 123456 -signedjar android_sign.apk $input_file my-key-alias

#echo `pwd`
#echo $cur_path
#echo $SDK_PATH


if [[ $RESIGN_ENABLE == 'true' ]]; then

  #./zipalign -v -p -f 4 $cur_path/t1.apk $cur_path/t2.apk

  cd $SDK_PATH

  #java -jar apksigner.jar sign  --ks key.jks  --ks-key-alias releasekey  --ks-pass pass:pp123456  --key-pass pass:pp123456  --out output.apk  input.apk

  #echo $cur_path/../android/app/my-release-key.keystoress

  echo 4. start resign

  echo $input_file $output_file

  java -jar apksigner.jar sign \
   --min-sdk-version 16 \
   --ks ${KEYSTORE_PATH} \
   --ks-pass pass:${STORE_PASSWORD} \
   --key-pass pass:${ALIAS_PASSWORD} \
   --out $output_file $input_file

  echo 5. resign success

  if [[ $RESIGN_VERIFY == 'true' ]]; then
    echo 5.1 enable resign verify
    #rm -rf tmp/META-INF/CERT.*ss
    #rm -rf tmp/META-INF/MANIFEST.MF

    java -jar apksigner.jar verify -v --print-certs $output_file
  fi
fi

if [[ $BUNDLE_OUT_PATH_DELETE == 'true' ]]; then
    echo 6. enable delete ${BUNDLE_OUT_PATH}
    rm -rf ${cur_path}/${BUNDLE_OUT_PATH}
fi


if [[ $AUTO_INSTALL_APK == 'true' ]]; then
   echo 7. enable auto intall
   #echo 7. start install $output_file
   echo " @@@@@@@ 自动安装 !!!  @@@@@@@ " $output_file

   source ~/.bash_profile
   adb install $output_file
fi




