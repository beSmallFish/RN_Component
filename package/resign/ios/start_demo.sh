#!/bin/sh

#intput
ori_ipa=XXX.ipa  #原始的ipa包
is_dev=true      #DEV签名
bundle_zip=XXXX  #RN资源 1。不设置-不会替换； 2.本地有,使用本地的； 3.本地无，从服务器拉取 （服务器地址-> 在resign.config中设置）

./resign.sh $ori_ipa $is_dev $bundle_zip

#output 输出新的ipa
#日志打印 -> resign_code=200 -> 重签名成功
#ipa -> XXX_TM.ipa
#是否自动安装该XXX_TM.ipa（resign.config -> AUTO_INSTALL_IPA=true）
