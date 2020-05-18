# Android的各种疑难杂症

## apk第一次安装或者覆盖安装 -> 启动 -> 每次切后台 -> 都会重新启动 -> 直至强杀app, 第二次启动   

        原因：打开app的操作不符合标准规范？（厂商问题）-> 每次点击appIcon 都重新加载Activity -> 栈内有多个MainActivity
        方案：
            android方案答案有很多，但RN需要特殊处理下。示例如下：

        MainActivity.java  
        @Override
        protected ReactActivityDelegate createReactActivityDelegate() {
            return new ReactActivityDelegate(this, getMainComponentName()) {
                @Override
                protected void loadApp(String appKey) {
                    if (!isTaskRoot()
                            && getIntent().hasCategory(Intent.CATEGORY_LAUNCHER)
                            && getIntent().getAction() != null
                            && getIntent().getAction().equals(Intent.ACTION_MAIN)) {
    
                        Log.i(TAG, "loadApp appKey: " + appKey);
    
                        finish();
                        return;
                    }
                    Log.i(TAG, "loadApp-2 appKey: " + appKey);
                    super.loadApp(appKey);
                }
            };
        }
        
        
        
        
        
       
    
    
                 
        
        
        
        
