#!/usr/bin/env bash

#获取API环境
env_file=`grep env Env.js`
env_split_1=`echo ${env_file%\'*}`
api_env=`echo ${env_split_1##*\'}`

#echo api----$api_env

cd ../android

function package(){
    #chmond 777 app/build/
    #android 编译生成目录
    rm -rf app/build/

    #编译打包
    #可自定gradle函数 自定义包名/显示版本号/
    ./gradlew assemble$build


    #复制apk文件 到 apk/Release apk/Debug 目录
    #格式 apk/Release/worker_release_dev_20190614142010.apk

    mkdir -p apk/$build
    chmod 777 apk/
    #大写转换成小写
    build_lowercase=$(echo $build | tr '[A-Z]' '[a-z]')
    #orgin_apk_path=app/build/outputs/apk/$build_lowercase
    orgin_apk_path=app/build/outputs/apk/${build_lowercase}
    orgin_apk_file=`ls $orgin_apk_path | grep .apk`
    orgin_apk_name=${orgin_apk_file%%.*}
    timestamp=`date '+%Y%m%d%H%M%S'`
    target_apk_path=apk/$build/${orgin_apk_name}_${build}_${api_env}_${timestamp}.apk
    echo copy to $target_apk_path
    cp app/build/outputs/apk/${build_lowercase}/${orgin_apk_name}.apk $target_apk_path

}

build=Release
if [ "$1" = "debug" ]; then
   build=Debug
   package
elif [ "$1" = "both" ]; then
   build=Debug
   package
   build=Release
   package
else
   build=Release
   package
fi




