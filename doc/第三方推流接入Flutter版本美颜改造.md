### 背景：

由于flutter端的gl环境与原生端的环境进行了隔离，所以在接入美颜的时候不能在flutter端直接调用美颜的方法。

### 方案：

在原生端实现美颜处理，也就是三方推流端在原生侧直接调用美颜的原生端提供的方法。

总体流程如下：

<img src="https://qcloudimg.tencent-cloud.cn/raw/73bbc3c15e95db29a270fc4e1927a026.png" style="zoom:80%;" />

1. 美颜端抽象了一层接口，并在美颜测实现了接口
2. 在应用启动时将此接口注册到 三方推流端，这样三方推流端就可以通过此接口进行创建、使用、销毁美颜实例。
3. 三方推流端再将创建、和销毁美颜的能力暴露给自己的flutter端供客户使用。
4. 美颜属性的设置可通过美颜提供的flutter SDK 能力进行处理。

### 举例说明（TRTC）：

美颜端定义的接口：

```java
public interface ITXCustomBeautyProcesserFactory {

    /**
     * 创建美颜实例
     * @return
     */
    ITXCustomBeautyProcesser createCustomBeautyProcesser();

    /**
     * 销毁美颜实例（需要在GL线程调用）
     */
    void destroyCustomBeautyProcesser();
}
public interface ITXCustomBeautyProcesser {

   //获取美颜支持的视频帧的像素格式。美颜支持的是：OpenGL 2D 纹理。
    TXCustomBeautyPixelFormat getSupportedPixelFormat();
    //获取美颜支持的视频数据包装格式。美颜支持的是：V2TXLiveBufferTypeTexture	直接操作纹理 ID，性能最好，画质损失最少。
    TXCustomBeautyBufferType getSupportedBufferType();
   //在GL线程调用（srcFrame中需要包含RGBA纹理，以及width，height）,美颜处理之后会将处理后的纹理对象放置在dstFrame中的    texture.textureId中。
    void onProcessVideoFrame(TXCustomBeautyVideoFrame srcFrame, TXCustomBeautyVideoFrame dstFrame);
}
```

1. TRTC提供一个注册的方法，在应用启动的时候，客户将美颜测的ITXCustomBeautyProcesserFactory接口的实现类`com.tencent.effect.tencent_effect_flutter.XmagicProcesserFactory`注册进TRTC中（在原生端进行）。

   ![](https://qcloudimg.tencent-cloud.cn/raw/1022d47f36e4a6109cff7dca71771e29.png)

2. 在`Flutter`层，提供`Future<V2TXLiveCode> enableCustomVideoProcess(bool enable)`接口进行开启或关闭自定义美颜接口。

2. TRTC原生端实现开关美颜方法。![](https://qcloudimg.tencent-cloud.cn/raw/cf1b93949c4abfbfbad29d02f32740db.png)

   ![](https://qcloudimg.tencent-cloud.cn/raw/319e2f1f8e656e3505908ffb48226ab6.png)

### 美颜提供的抽象层依赖：

```groovy
///
implementation 'com.tencent.liteav:custom-video-processor:latest.release'
```

 

