#!/usr/bin/env bash

#获取Env.js的环境变量
env_file=`grep env Env.js`
env_split_1=`echo ${env_file%\'*}`
api_env=`echo ${env_split_1##*\'}`

cd ../ios
# 必须先创建目录
#chmod 777 build


function package(){

    archivePath=./build/archive.xcarchive
    ad_hoc_exportPath=./build/ipa-ad-hoc/$build
    # 获取目录名
    project_list=`ls | grep .xcodeproj`
    project_name=${project_list%%.*}

    mkdir -p build
    chmod 777 build
    mkdir -p $archivePath
    chmod 777 $archivePath
    rm -rf $archivePath build/ipa-*osl


    # 打包出app
    # xcode -> Product -> Archive
    xcodebuild clean
    xcodebuild archive \
      -project ./${project_name}.xcodeproj \
      -scheme ${project_name} \
      -configuration ${build} \
      -archivePath ${archivePath}

    # 测试ipa包 ad-hoc
    xcodebuild -exportArchive \
      -archivePath ${archivePath} \
      -exportPath ${ad_hoc_exportPath} \
      -exportOptionsPlist ./exportOptions/ad-hoc.plist \
      -allowProvisioningUpdates

    #复制ipa到指定文件夹 ios/ips/Release/worker_release_dev_20190614142010.ipa
    timestamp=`date '+%Y%m%d%H%M%S'`
    target_ipa_path=./ipa/${build}
    mkdir -p ${target_ipa_path}
    chmod 777 ${target_ipa_path}
    target_ipa_name=${project_name}_${build}_${api_env}_${timestamp}.ipa
    echo copy to ${target_ipa_path}/${target_ipa_name}
    cp ${ad_hoc_exportPath}/${project_name}.ipa ${target_ipa_path}/${target_ipa_name}
}

#debug or release or both
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






