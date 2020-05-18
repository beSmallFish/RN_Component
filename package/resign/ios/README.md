# IOS 重签名

##重签要素
    
    1.描述文件 XX.mobileprovision
    2.授权文件 XXX_entitlements.plist
    3.证书名称 -> 本地钥匙串 -> "Apple Development XXXX"
    4.ipa文件


##重签过程

    1.解压ipa -> Payload -> appName
    2.RN资源替换（optional）-> 从服务器拉 还是 使用本地文件
    3.删除签名文件 _CodeSignature
    4.替换emmbed.provision -> 指定的mobileprovision
    5.重签Frameworks
    6.重签PlugIns   
    7.对整个app重签 -> 生成新的_CodeSignature
    8.重签成功(resign_code=200) -> 输出ipa -> appName_TM.ipa
    9.自动安装ipa(可选)
    
##示例

    #普通重签
    ./resign.sh $ori_ipa $is_dev 
    
     #普RN重签 bundle_zip -> RN资源包
    ./resign.sh $ori_ipa $is_dev $bundle_zip 
    
    
      
    
        
    
    
    
    
    
    
        
        
        
