# RN 自动打包

入口 				./package.sh 
android打包 			./android.sh
ios打包 				./ios.sh
App接口环境,被其他文件引用		Env.js	
蒲公英上传				pgy_upload.sh

参数 
echo -e " -b ===>> 选择构建版本 ===>> release/debug/both"
echo -e " -s ===>> 选择系统 ===>> ios/android/both"
echo -e " -e ===>> 选择Api环境 ===>> dev/release/test"
echo -e " -u ===>> 上传到 ===>> pgy/appstore/"
echo -e " -h ===>> 帮助 ===>> 查看已有参数"

eg:
ios打Release包 ./ios.sh or ./package.sh -s ios

ios android同时打包 ./package.sh -s both

ios android同时打包，且指定dev环境 ./package.sh -s both -e dev

ios android同时打包，且指定dev环境 上传蒲公英 ./package.sh -s both -e dev -u pay

ios android同时打Release和Debug包，且指定dev环境 上传蒲公英 ./package.sh -s both -e dev -u pay -b both
注：蒲公英上传 -b为both时(只上传Release包)
----- appId相同 release会覆盖debug包, 且debug包不应该为外部使用.只上传Release包 -----------



最终输出
ios目录：ios/ipa/
andriod目录： android/apk/
文件名： appName_(Debug/Release)_(API环境)_时间戳_.(ipa / apk)
WorkerApp_Release_dev_20190616121212.ipa

