# 调试Native时，只编译Native代码

###遇到的问题？
    
    1.在调试android native代码时，改动后重新运行 验证。电脑巨卡，可能得10min左右的时间。非常浪费时间
    2.ios也有同样的问题
    
###如何解决？    
    
    1.调试的时候，禁止jsbundle打包。只保留native代码的编译.
    
### android方案

     1.在app/build.gradle文件中，发现RN打包的脚本放在 react.gradle  (apply from: "../../node_modules/react-native/react.gradle")
     2.进入该文件 看到核心的 bundle task, 如下
     
     def currentBundleTask = tasks.create(
                 name: "bundle${targetName}JsAndAssets",
                 type: Exec) {
                 group = "react"
                 description = "bundle JS and assets for ${targetName}."
     
                 // Create dirs if they are not there (e.g. the "clean" task just ran)
                 doFirst {
                     jsBundleDir.deleteDir()
                     jsBundleDir.mkdirs()
                     resourcesDir.deleteDir()
                     resourcesDir.mkdirs()
                 }
     
                 // Set up inputs and outputs so gradle can cache the result
                 inputs.files fileTree(dir: reactRoot, excludes: inputExcludes)
                 outputs.dir(jsBundleDir)
                 outputs.dir(resourcesDir)
     
                 // Set up the call to the react-native cli
                 workingDir(reactRoot)
     
                 // Set up dev mode
                 def devEnabled = !(config."devDisabledIn${targetName}"
                     || targetName.toLowerCase().contains("release"))
     
                 def extraArgs = extraPackagerArgs;
     
                 if (bundleConfig) {
                     extraArgs = extraArgs.clone()
                     extraArgs.add("--config");
                     extraArgs.add(bundleConfig);
                 }
     
                 if (Os.isFamily(Os.FAMILY_WINDOWS)) {
                     commandLine("cmd", "/c", *nodeExecutableAndArgs, cliPath, bundleCommand, "--platform", "android", "--dev", "${devEnabled}",
                         "--reset-cache", "--entry-file", entryFile, "--bundle-output", jsBundleFile, "--assets-dest", resourcesDir, *extraArgs)
                 } else {
                     commandLine(*nodeExecutableAndArgs, cliPath, bundleCommand, "--platform", "android", "--dev", "${devEnabled}",
                         "--reset-cache", "--entry-file", entryFile, "--bundle-output", jsBundleFile, "--assets-dest", resourcesDir, *extraArgs)
                 }
     
                 enabled config."bundleIn${targetName}" ||
                     config."bundleIn${variant.buildType.name.capitalize()}" ?:
                     targetName.toLowerCase().contains("release")
             }
             
             ...
             
        3. 直接修改 enabled config."bundleIn${targetName}".... 这段代码 -> enabled false   禁用bundle task
        4. 上面有个doFirst方法(第8行) -> 注释deleteDir（） -> 不删除已经打包的资源文件 -> 方便下次编译 直接复用 -> 注释如下   
            doFirst {
               //  jsBundleDir.deleteDir()
                 jsBundleDir.mkdirs()
               //  resourcesDir.deleteDir()
                 resourcesDir.mkdirs()
             }
        5.运行 ./gradlew assembleRelease   -> 从10min左右的打包时间 -> 变成60s左右了 收工
        


###ios方案
        1.分析得知, ios打包运行的shell文件为 ->  node_modules/react-native/scripts/react-native-xcode.sh
        2.进入该文件，发现只要设置SKIP_BUNDLING=true 即可不进行bundle打包
        3.进入xcode -> targets -> 项目 -> Build Phases -> Bundle React Native code and images -> Shell -> 输入框 新增 -> export SKIP_BUNDLING=true
        

