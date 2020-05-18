#!/bin/sh

##resign_code
## 100-初始值 101-ipa未找到 102-profile未找到 199-重签失败 200-重签成功
## resign_code=200

if [ $# -lt 1 ]; then
    echo ""
    echo "resign.sh Usage:"
    echo "\t required: ./resign.sh APP_NAME.ipa true"
    echo "\t the second params is optional feature which allow you set get-task-allow to true"

    exit 0
fi

source resign.config
resign_code=100
bundle_zip=$3

echo "read config.plist"

TARGET_IPA_PACKAGE_NAME=$1                                                         
TM_IPA_PACKAGE_NAME="${TARGET_IPA_PACKAGE_NAME%.*}_TM.ipa"                         # resigned ipa name
PAYLOAD_DIR="Payload"
APP_DIR=""
PROVISION_FILE=$NEW_MOBILEPROVISION
CODESIGN_KEY=$CODESIGN_IDENTITIES
ENTITLEMENTS_FILE=$ENTITLEMENTS
echo -e "$2"
if [[ $2 == 'true' ]]; then
  echo "resign with development type"
    PROVISION_FILE=$NEW_MOBILEPROVISION_DEV
    CODESIGN_KEY=$CODESIGN_IDENTITIES_DEV
    ENTITLEMENTS_FILE=$ENTITLEMENTS_DEV
fi

echo XXX $CODESIGN_KEY $CODESIGN_IDENTITIES_DEV $ENTITLEMENTS_FILE

OLD_MOBILEPROVISION="embedded.mobileprovision"
DEVELOPER=`xcode-select -print-path`
TARGET_APP_FRAMEWORKS_PATH=""

SDK_DIR="${DEVELOPER}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
echo -e "SDK_DIR*$SDK_DIR"

if [[ $1 == 'Payload' ]]; then
  echo " start package Payload"
else
  if [ ! -e $TARGET_IPA_PACKAGE_NAME ]; then
    echo "ipa file ($TARGET_IPA_PACKAGE_NAME) not exist"
    resign_code=101
    echo resign_code=$resign_code
    exit 0
  fi
fi


if [ ! -e $PROVISION_FILE ]; then
    echo "provision file ($PROVISION_FILE) not exist"
    resign_code=102
    echo resign_code=$resign_code
    exit 0
fi

if [ -e $TM_IPA_PACKAGE_NAME ]; then
    echo "rm $TM_IPA_PACKAGE_NAME"
    rm $TM_IPA_PACKAGE_NAME
fi

if [[ $1 == 'Payload' ]]; then
  echo " start package Payload - 1"
else
  if [ -d $PAYLOAD_DIR ]; then
    rm -rf $PAYLOAD_DIR
  fi

  echo ""
  echo "1. unzip $TARGET_IPA_PACKAGE_NAME"
  unzip -o $TARGET_IPA_PACKAGE_NAME > /dev/null

  if [ ! -d $PAYLOAD_DIR ]; then
      echo "unzip $TARGET_IPA_PACKAGE_NAME fail"
  fi
fi

#可能会有空格 导致 ls "1 2 3" 目录错误
echo XXXX $PAYLOAD_DIR
TMP_DIR=`ls $PAYLOAD_DIR/`
for DIR in "$TMP_DIR"
do
    if [ -d "$PAYLOAD_DIR/$DIR" ]; then
        APP_DIR="$PAYLOAD_DIR/$DIR"
        echo "APP DIR : $APP_DIR"
        break
    fi
done

#RN相关
if [ -n "$bundle_zip" ]; then
    #Payload/b_app.app/
    if [[ -f "$bundle_zip" ]]; then
        #本地有
        echo "use local ${bundle_zip}"
    else
        #本地无 后端下载
        echo "download from ${BUNDLE_DOWNLOAD}/${bundle_zip} "
        #wget --unlink  ${BUNDLE_DOWNLOAD}/${bundle_zip}
        curl ${BUNDLE_DOWNLOAD}/${bundle_zip} --output ./${bundle_zip}
    fi

    echo "1.2 RN更新 替换jsbundle & assets" ${bundle_zip} "$APP_DIR"

    #mkdir "bundle"
    #chmod 777 ./${bundle_zip}
    #解压资源包
    #rm -rf "$APP_DIR" /assets

    tar zxf ./${bundle_zip} --strip-components 1 -C "$APP_DIR"/

    #文件替换
    #cp -rf ./bundle/mian.bundle "$APP_DIR"/
    #rm -rf "$APP_DIR"/assets
    #\cp -rf ./bundle/ "$APP_DIR"/

    #修改版本号
fi

#if [ -d "$APP_DIR"/_CodeSignature ]; then
    echo ""
    echo "2. rm $APP_DIR/_CodeSignature"
    rm -rf "$APP_DIR"/_CodeSignature

    echo ""
    echo "4. cp $SDK_DIR/ResourceRules.plist $APP_DIR/"
    cp $SDK_DIR/ResourceRules.plist $APP_DIR/
    echo ""

    #merge ENTITLEMENTS FILE
    if [ -f "$APP_DIR/embedded.mobileprovision" ]; then

#        ori_plist=$ENTITLEMENTS_FILE
#        target_plist=$APP_DIR/target_entitlements.plist
#
#        security cms -D -i $APP_DIR/embedded.mobileprovision > $APP_DIR/tmp_profile.plist
#        /usr/libexec/PlistBuddy -x -c 'Print :Entitlements' $APP_DIR/tmp_profile.plist > $target_plist
#
#        echo "4-1. merge entitlements  ori_plist:$ori_plist, target_plist:$target_plist"
#
#        application=`/usr/libexec/PlistBuddy -c "Print :application-identifier" $ori_plist`
#        teamIdentifier=`/usr/libexec/PlistBuddy -c 'Print :com.apple.developer.team-identifier' $ori_plist`
#        keychain0=`/usr/libexec/PlistBuddy -c 'Print :keychain-access-groups:0' $ori_plist`
#        /usr/libexec/PlistBuddy -c "Set :application-identifier $application" $target_plist
#        /usr/libexec/PlistBuddy -c "Set :com.apple.developer.team-identifier $teamIdentifier" $target_plist
#        /usr/libexec/PlistBuddy -c "Set :keychain-access-groups:0 $keychain0" $target_plist
#
#        rm -rf $APP_DIR/tmp_profile.plist
#
#        ENTITLEMENTS_FILE=$target_plist
        echo ""

        #ori_plist=$ENTITLEMENTS_FILE
#        target_plist=$APP_DIR/target_entitlements.plist
#        security cms -D -i $APP_DIR/embedded.mobileprovision > $APP_DIR/tmp_profile.plist
#        /usr/libexec/PlistBuddy -x -c 'Print :Entitlements' $APP_DIR/tmp_profile.plist > $target_plist
#        ENTITLEMENTS_FILE=$target_plist
    fi


    echo "5. cp $PROVISION_FILE $APP_DIR/$OLD_MOBILEPROVISION"
    cp $PROVISION_FILE "$APP_DIR/$OLD_MOBILEPROVISION"
    echo ""

    echo "6. codesign....."
    #codesign frameworks
    TARGET_APP_FRAMEWORKS_PATH="$APP_DIR/Frameworks"
    if [[ -d "$TARGET_APP_FRAMEWORKS_PATH" ]]; then
        for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*; do
            FILENAME=$(basename $FRAMEWORK)
            /usr/bin/codesign -f -s "$CODESIGN_KEY" "$FRAMEWORK"
        done
    fi
    #codesign plugins
    TARGET_APP_PLUGINS_PATH="$APP_DIR/PlugIns"
    if [[ -d "$TARGET_APP_PLUGINS_PATH" ]]; then
        for PLUGIN in "$TARGET_APP_PLUGINS_PATH/"*; do
            echo "PLUGIN($PLUGIN)"
            FILENAME=$(basename $PLUGIN)
            echo "FILENAME($FILENAME)"
            /usr/bin/codesign -f -s "$CODESIGN_KEY" "$PLUGIN"
        done
    fi

    echo 权限文件如下: $ENTITLEMENTS_FILE, 证书: "$CODESIGN_KEY",  APP_DIR:"$APP_DIR"
    cat $ENTITLEMENTS_FILE

     /usr/bin/codesign -f -s "$CODESIGN_KEY" --entitlements $ENTITLEMENTS_FILE  "$APP_DIR"
    # expect expect.sh "$CODESIGN_KEY" $ENTITLEMENTS_FILE $APP_DIR
    if [ -d "$APP_DIR"/_CodeSignature ]; then

        echo "7. zip -r $TM_IPA_PACKAGE_NAME $APP_DIR/"
        zip -o -r "$TM_IPA_PACKAGE_NAME" "$APP_DIR"/ > /dev/null

        #rm -rf "$PAYLOAD_DIR"
        #rm -rf "$APP_DIR"

        echo " @@@@@@@ resign success !!!  @@@@@@@ "
        resign_code=200
        echo resign_code=$resign_code

        if [[ $AUTO_INSTALL_IPA == 'true' ]]; then
           ios-deploy -b $TM_IPA_PACKAGE_NAME
           echo " @@@@@@@ 自动安装 !!!  @@@@@@@ "
        fi
        exit 0
    fi
#fi

echo "resign fail !!"
resign_code=199
echo resign_code=$resign_code