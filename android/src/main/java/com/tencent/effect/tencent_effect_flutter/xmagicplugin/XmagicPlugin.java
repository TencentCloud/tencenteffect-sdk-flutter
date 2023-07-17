package com.tencent.effect.tencent_effect_flutter.xmagicplugin;

import androidx.annotation.NonNull;


import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * tencent_effect_flutter
 * Created by kevinxlhua on 2022/8/12.
 * Copyright (c) 2020年 Tencent. All rights reserved
 */


public interface XmagicPlugin {


    void setEventSink(EventChannel.EventSink eventSink);


    void initXmagic(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void setLicense(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void setXmagicLogLevel(@NonNull MethodCall call, @NonNull MethodChannel.Result result);


    void onResume(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void onPause(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void updateProperty(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void isBeautyAuthorized(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void isSupportBeauty(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void getDeviceAbilities(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void getPropertyRequiredAbilities(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void isDeviceSupport(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void enableEnhancedMode(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

    void setDowngradePerformance(@NonNull MethodCall call, @NonNull MethodChannel.Result result);

}
