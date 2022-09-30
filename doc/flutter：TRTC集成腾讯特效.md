SDK集成指引

1. ### 美颜资源下载与集成

   根据您购买的套餐下载[腾讯特效](https://cloud.tencent.com/document/product/616/65876)对应的资源文件以及SDK。

   添加文件到自己的工程中：

   #### Android：

   - 在app 模块下找到build.gradle文件，添加您对应套餐的maven引用地址，例如您选择的是S1-04套餐，则添加如下：

   ```groovy
    dependencies {
          implementation 'com.tencent.mediacloud:TencentEffect_S1-04:latest.release'
       }
   ```
   
   **各套餐对应的maven地址可参考官网https://cloud.tencent.com/document/product/616/65891**
   
   - 在app 模块下找到src/main/assets文件夹，如果没有则创建，检查下载的SDK包中是否有 MotionRes 文件夹，如果有则将此文件夹拷贝到 `../src/main/assets` 目录下。
   
   - 在app模块下找到AndroidManifest.xml文件，在application表填内添加如下标签
   
   ```xml
     <uses-native-library
               android:name="libOpenCL.so"
               android:required="true" />
   ```
   
   添加后如下图：
   
   ![](https://qcloudimg.tencent-cloud.cn/raw/adca155b8fa60600465bdfc6e78ebb2b.png)
   
   
   
   #### iOS ：
   
   - 添加美颜资源到您的工程
   
   ​      添加后如下图：（你的资源种类跟下图不完全一致）
   
   ![](https://qcloudimg.tencent-cloud.cn/raw/e5cb4984aa2bfa14fd4f837acf465cfa.png)
   
   
   
   
   
   - 在demo中把demo/lib/producer里面的4个类：BeautyDataManager、BeautyPropertyProducer、BeautyPropertyProducerAndroid和BeautyPropertyProducerIOS复制添加到自己的flutter工程中，这4个类是用来配置美颜资源，把美颜类型展示在美颜面板中。
   
   
   
2. ### 引用flutter版本SDK

   在工程的pubspec.yaml文件中添加如下引用：

   ```json
     tencent_effect_flutter:
       git:
         url: https://github.com/TencentCloud/tencenteffect-sdk-flutter
   ```

3. ### 与TRTC关联

   #### Android：

   在应用的application类的oncreate方法（或FlutterActivity的onCreate方法）中添加如下代码

   ```jav
    TRTCCloudPlugin.register(new XmagicProcesserFactory());
   ```
   
   #### IOS:

   在应用的AppDelegate类中的didFinishLaunchingWithOptions方法里面中添加如下代码：

   ```objective-c
   XmagicProcesserFactory *instance = [[XmagicProcesserFactory alloc] init];
   [TencentTRTCCloud registerWithCustomBeautyProcesserFactory:instance];
   ```
   
   添加后如下图：
   
   ![](https://qcloudimg.tencent-cloud.cn/raw/3f2de0a60696f18daedde2228d65076a.png)
   
   
   
4. ### 调用资源初始化接口

   ```dart
      String dir =  await BeautyDataManager.getInstance().getResDir();
       TXLog.printlog('文件路径为：$dir');
       TencentEffectApi.getApi()?.initXmagic(dir,(reslut) {
         _isInitResource = reslut;
         callBack.call(reslut);
         if (!reslut) {
           Fluttertoast.showToast(msg: "初始化资源失败");
         }
       }); TencentEffectApi.getApi()?.initXmagic((reslut) {
         if (!reslut) {
           Fluttertoast.showToast(msg: "初始化资源失败");
         }
       });
   ```

5. ### 进行美颜授权

   ```dart
   TencentEffectApi.getApi()?.setLicense(licenseKey, licenseUrl,
               (errorCode, msg) {
             TXLog.printlog("打印鉴权结果 errorCode = $errorCode   msg = $msg");
             if (errorCode == 0) {
                //鉴权成功
             }
           });
   ```

6. ### 开启美颜

   ```dart
   ///开启美颜操作
     var enableCustomVideo = await trtcCloud.enableCustomVideoProcess(open);
   ```
   
   

7. ### 设置美颜属性

   ```dart
        TencentEffectApi.getApi()?.updateProperty(_xmagicProperty!);
    ///_xmagicProperty 可通过 BeautyDataManager.getInstance().getAllPannelData();获取所有的属性，需要使用美颜属性的时候可通过updateProperty方法设置属性。
   ```

8. ### 其他

   暂停美颜音效：

   ```dart
     TencentEffectApi.getApi()?.onPause();  
   ```

   恢复美颜音效：

   ```dart
    TencentEffectApi.getApi()?.onResume();
   ```

   监听美颜事件

   ```dart
   TencentEffectApi.getApi()
           ?.setOnCreateXmagicApiErrorListener((errorMsg, code) {
             TXLog.printlog("创建美颜对象出现错误 errorMsg = $errorMsg , code = $code");
       });   ///需要在创建美颜之前进行设置
   ```

   设置人脸、手势、身体检测状态回调

   ```dart
    TencentEffectApi.getApi()?.setAIDataListener(XmagicAIDataListenerImp());
   ```

   设置动效提示语回调函数

   ```dart
   TencentEffectApi.getApi()?.setTipsListener(XmagicTipsListenerImp());
   ```

   设置人脸点位信息等数据回调（S1-05 和 S1-06 套餐才会有回调）

   ```dart
   TencentEffectApi.getApi()?.setYTDataListener((data) {
         TXLog.printlog("setYTDataListener  $data");
       });
   ```

   移除所有回调：

   在页面销毁的时候需要移除掉所有的回调：

   ```dart
     TencentEffectApi.getApi()?.setOnCreateXmagicApiErrorListener(null);
     TencentEffectApi.getApi()?.setAIDataListener(null);
     TencentEffectApi.getApi()?.setYTDataListener(null);
     TencentEffectApi.getApi()?.setTipsListener(null);
   ```

   接口详细可参考接口文档，其他可参考demo工程。

9. ### 如何添加和删除美颜面板上的美颜数据

   在BeautyDataManager、BeautyPropertyProducer、BeautyPropertyProducerAndroid和BeautyPropertyProducerIOS这4个类中，你可以自主操作美颜面板数据的配置。

   添加美颜资源：

   把你的资源文件按照步骤一中的方法添加到对应的资源文件夹里面。

   例如：你需要添加2D动效的资源，你应该把资源放在工程的android/xmagic/src.mian/assets/MotionRes/2dMotionRes目录下

   <img src="https://qcloudimg.tencent-cloud.cn/raw/7e91b97099e3d337de31c4893686759b.png" style="zoom:50%;" />

并且把资源添加到工程的ios/Runner/xmagic/2dMotionRes.bundle目录下

<img src="https://qcloudimg.tencent-cloud.cn/raw/8c806cb1c77d9c49b787ab17f77a2f0d.png" style="zoom:50%;" />

删除美颜资源：

对于某些License没有授权美颜和美体的部分功能，美颜面板上不需要展示这部分功能，需要在美颜面板数据的配置中删除这部分功能的配置。

例如，删除口红特效：

分别在BeautyPropertyProducerAndroid类和BeautyPropertyProducerIOS类中的getBeautyData方法中删除以下代码

<img src="https://qcloudimg.tencent-cloud.cn/raw/730abb4688d9f9675cf1bef679b0b2c1.png" style="zoom:50%;" />

