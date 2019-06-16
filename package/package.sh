#!/usr/bin/env bash



system=
env=
uploadTo=
build=release
isNeedRun=true

#echo ----------- 系统:$system,  API环境:$env,  上传到:$uploadTo,  ------------------

chmod 777 ./*.sh


function package(){

    if [ "$system" = "ios" ]; then
       ./ios.sh $build
    elif [ "$system" = "android" ]; then
       ./android.sh $build
    elif [ "$system" = "both" ]; then
       ./android.sh $build
       ./ios.sh $build
    fi

}

#构建Env.js
function buildEnv(){
    if [ -z "$env" ]; then
        env_file=`grep env Env.js`
        env_split_1=`echo ${env_file%\'*}`
        env=`echo ${env_split_1##*\'}`
    fi
    echo "export default {env: '$env'}" > Env.js
}

function upload(){
    if [ -z "$uploadTo" ]; then
        return 0
        #echo "uploadTo is empty"
    fi

    if [ "$uploadTo" = "pgy" ]; then
        ./pgy_upload.sh $system $build
    elif [ "$uploadTo" = "appstore" ]; then
        #source ./appstore_upload.sh
        echo "upload to appStore"
    fi
}


while getopts :e:s:u:b:h OPTION; do
    case $OPTION in
        e) env=$OPTARG
        ;;
        s) system=$OPTARG
        ;;
        u) uploadTo=$OPTARG
        ;;
        b) build=$OPTARG
        ;;
        h)
          echo -e " -b ===>> 选择构建版本 ===>> release/debug"
          echo -e " -s ===>> 选择系统 ===>> ios/android/both"
          echo -e " -e ===>> 选择Api环境 ===>> dev/release/test"
          echo -e " -u ===>> 上传到 ===>> pgy/appstore/"
          echo -e " -h ===>> 帮助 ===>> 查看已有参数"
          isNeedRun=false
        ;;
        ?) echo "未知参数 -$OPTARG... -h 查看现有支持参数"
        ;;
    esac
done

if [ "$isNeedRun" = "true" ]; then
    buildEnv
    package
    upload
fi

