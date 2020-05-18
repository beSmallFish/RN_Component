#!/usr/bin/env bash

#cd ../ios
cd .
echo ---------------- 上传蒲公英 -----------------

PGY_API_KEY=4c515cff705ee50ef456d75835987cdb
PGY_HOST=https://www.pgyer.com/apiv2/app/upload

projectName=app
system=$1
build=$2
iosSign=$3

if [ "$build" = "debug" ]; then
   build=Debug
elif [ "$build" = 'both' ]; then
    #debug包不上传 不对外使用
   build=Release
   echo ------------- appId相同 release会覆盖debug包, 且debug包不应该为外部使用.只上传Release包 ----------------
else
   build=Release
fi


#echo ${iosSign} $build


# 上传蒲公英 暂时使用编译路径下的文件（最新 唯一一个/ 自定义文件夹路径下 多个历史文件）
IPA=`ls ../ios/build/${iosSign}/$build/*.ipa`
build_lowercase=$(echo $build | tr '[A-Z]' '[a-z]')
APK=`ls ../android/app/build/outputs/apk/${build_lowercase}/*.apk`


function upload(){
    curl \
        --form "file=@$1" \
        --form "_api_key=$PGY_API_KEY" \
        --form "buildName=$projectName" \
        $PGY_HOST
}

if [ "$system" = "ios" ]; then
   upload $IPA
elif [ "$system" = "android" ]; then
   upload $APK
else
   upload $IPA
   echo -e '\n'
   upload $APK
fi

