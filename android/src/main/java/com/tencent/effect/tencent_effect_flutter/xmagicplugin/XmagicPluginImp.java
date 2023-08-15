package com.tencent.effect.tencent_effect_flutter.xmagicplugin;


import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.ArrayMap;
import android.util.Log;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.tencent.effect.tencent_effect_flutter.utils.LogUtils;
import com.tencent.xmagic.XmagicProperty;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * tencent_effect_flutter
 * Created by kevinxlhua on 2022/8/12.
 * Copyright (c) 2020年 Tencent. All rights reserved
 */


public class XmagicPluginImp implements XmagicPlugin {

    private static String TAG = XmagicPluginImp.class.getName();

    private EventChannel.EventSink mEventSink;
    private Context applicationContext = null;
    private final Handler handler = new Handler(Looper.getMainLooper());

    private final Gson gson = new Gson();


    public XmagicPluginImp(FlutterPluginBinding flutterPluginBinding) {
        applicationContext = flutterPluginBinding.getApplicationContext();
        XmagicApiManager.getInstance().setApplicationContext(applicationContext);
        XmagicApiManager.getInstance().setManagerListener(new XmagicManagerListener() {
            @Override
            public void onXmagicPropertyError(String errorMsg, int code) {
                Map<String, Object> data = new ArrayMap<>();
                data.put("code", code);
                data.put("msg", errorMsg);
                sendMapData("onXmagicPropertyError", data);
            }

            @Override
            public void tipsNeedShow(String tips, String tipsIcon, int type, int duration) {
                Map<String, Object> data = new ArrayMap<>();
                data.put("tips", tips);
                data.put("tipsIcon", tipsIcon);
                data.put("type", type);
                data.put("duration", duration);
                sendMapData("tipsNeedShow", data);
            }

            @Override
            public void tipsNeedHide(String tips, String tipsIcon, int type) {
                Map<String, Object> data = new ArrayMap<>();
                data.put("tips", tips);
                data.put("tipsIcon", tipsIcon);
                data.put("type", type);
                sendMapData("tipsNeedHide", data);
            }

            @Override
            public void onFaceDataUpdated(String jsonData) {
                sendStringData("aidata_onFaceDataUpdated", jsonData);
            }

            @Override
            public void onHandDataUpdated(String jsonData) {
                sendStringData("aidata_onHandDataUpdated", jsonData);
            }

            @Override
            public void onBodyDataUpdated(String jsonData) {
                sendStringData("aidata_onBodyDataUpdated", jsonData);
            }

            @Override
            public void onYTDataUpdate(String data) {
                sendStringData("onYTDataUpdate", data);
            }
        });
    }


    @Override
    public void setEventSink(EventChannel.EventSink eventSink) {
        this.mEventSink = eventSink;
    }

    /**
     * 初始化资源文件，用于将美颜的资源从assets中复制到到安装目录下
     * Initialize the resource file for copying beauty resources from assets to the installation directory
     *
     * @param call
     * @param result
     */
    @Override
    public void initXmagic(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        LogUtils.d(TAG, "start init xmagic resource ");
        if (call.arguments instanceof Map) {
            Map<String, String> map = (Map<String, String>) call.arguments;
            String resPathDir = map.get("pathDir");
            LogUtils.d(TAG, "method initXmagic resPathDir = " + resPathDir);
            XmagicApiManager.getInstance().initModelResource(applicationContext,resPathDir, isCopySuccess -> {
                handler.post(() -> sendBoolData("initXmagic", isCopySuccess));
            });
            result.success(null);
            return;
        }
        resultParameterError(call.method, result);
    }

    /**
     * 进行美颜授权处理
     *Perform beauty authorization processing
     * @param call
     * @param result
     */
    @Override
    public void setLicense(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof Map) {
            Map<String, String> map = (Map<String, String>) call.arguments;
            String licenseKey = map.get("licenseKey");
            String licenseUrl = map.get("licenseUrl");
            XmagicApiManager.getInstance().setTELicense(applicationContext, licenseUrl, licenseKey,
                    (errorCode, msg) -> {
                        Map<String, Object> resultData = new ArrayMap<>();
                        resultData.put("code", errorCode);
                        resultData.put("msg", msg);
                        sendMapData("onLicenseCheckFinish", resultData);
                    });
            result.success(null);
            return;
        }
        resultParameterError(call.method, result);
    }

    /**
     * 设置美颜SDK的日志级别，用于调试使用
     *
     * @param call
     * @param result
     */
    @Override
    public void setXmagicLogLevel(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        boolean isSuccess = false;
        if (call.arguments instanceof Integer) {
            try {
                int logLevel = (int) call.arguments;
                XmagicApiManager.getInstance().setXmagicLogLevel(logLevel);
                isSuccess = true;
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (isSuccess) {
                    result.success(null);
                } else {
                    resultParameterError(call.method, result);
                }
            }
        } else {
            resultParameterError(call.method, result);
        }
    }





    /**
     * 恢复美颜效果
     *
     * @param call
     * @param result
     */
    @Override
    public void onResume(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        XmagicApiManager.getInstance().onResume();
        result.success(null);
    }

    /**
     * 暂停美颜效果
     *
     * @param call
     * @param result
     */
    @Override
    public void onPause(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        XmagicApiManager.getInstance().onPause();
        result.success(null);
    }





    /**
     * 设置美颜属性
     *
     * @param call
     * @param result
     */
    @Override
    public void updateProperty(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof String) {
            String propertyStr = (String) call.arguments;
            LogUtils.d(TAG, "updateProperty method parameter is " + propertyStr);
            if (!TextUtils.isEmpty(propertyStr)) {
                Type type = new TypeToken<XmagicProperty<XmagicProperty.XmagicPropertyValues>>() {
                }.getType();
                XmagicProperty<XmagicProperty.XmagicPropertyValues> property = gson.fromJson(propertyStr, type);
                if (property != null) {
                    XmagicApiManager.getInstance().updateProperty(property);
                    result.success(null);
                    return;
                }
            }
        }
        resultParameterError(call.method, result);
    }

    /**
     * 用于校验属性是否授权
     *
     * @param call
     * @param result
     */
    @Override
    public void isBeautyAuthorized(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof String) {
            String parameter = (String) call.arguments;
            Type type = new TypeToken<List<XmagicProperty<XmagicProperty.XmagicPropertyValues>>>() {
            }.getType();
            List<XmagicProperty<?>> data = gson.fromJson(parameter, type);
            XmagicApiManager.getInstance().isBeautyAuthorized(data);
            String resultStr = gson.toJson(data);
            LogUtils.d(TAG, "isBeautyAuthorized resultStr = " + resultStr);
            result.success(resultStr);
            return;
        }
        resultParameterError(call.method, result);
    }

    /**
     * 判断设备是否支持美颜
     *
     * @param call
     * @param result
     */
    @Override
    public void isSupportBeauty(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        result.success(XmagicApiManager.getInstance().isSupportBeauty());
    }

    /**
     * 返回当前设备支持的原子能力表
     *
     * @param call
     * @param result
     */
    @Override
    public void getDeviceAbilities(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Boolean> resultData = XmagicApiManager.getInstance().getDeviceAbilities();
        result.success(gson.toJson(resultData));
    }

    /**
     * 传入一个动效资源列表，返回每一个资源所使用到的 SDK 原子能力列表
     *
     * @param call
     * @param result
     */
    @Override
    public void getPropertyRequiredAbilities(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof String) {
            String parameter = (String) call.arguments;
            Type type = new TypeToken<List<XmagicProperty<?>>>() {
            }.getType();
            List<XmagicProperty<?>> data = gson.fromJson(parameter, type);
            Map<XmagicProperty<?>, ArrayList<String>> resultData = XmagicApiManager.getInstance()
                    .getPropertyRequiredAbilities(data);
//            Type type2 = new TypeToken<Map<XmagicProperty<?>, ArrayList<String>>>() {
//            }.getType();
            Map<String,ArrayList<String>> resultMap = new ArrayMap<>();

            for (XmagicProperty<?> key: resultData.keySet()) {
                 resultMap.put(gson.toJson(key),resultData.get(key));
            }

            result.success(gson.toJson(resultMap));
            return;
        }
        resultParameterError(call.method, result);
    }

    /**
     * 将动效资源列表传入 SDK 中做检测，执行后 XmagicProperty.isSupport 字段标识该原子能力是否可用。
     * 根据 XmagicProperty.isSupport 可 UI 层控制单击限制，或者直接从资源列表删除。
     *
     * @param call
     * @param result
     */
    @Override
    public void isDeviceSupport(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof String) {
            String parameter = (String) call.arguments;
            Type type = new TypeToken<List<XmagicProperty<?>>>() {
            }.getType();
            List<XmagicProperty<?>> data = gson.fromJson(parameter, type);
            XmagicApiManager.getInstance().isDeviceSupport(data);
            String resultData = gson.toJson(data);
            result.success(resultData);
            return;
        }
        resultParameterError(call.method, result);
    }

    @Override
    public void enableEnhancedMode(@NonNull MethodCall call, @NonNull MethodChannel.Result result){
        XmagicApiManager.getInstance().enableEnhancedMode();
        result.success(true);
    }


    @Override
    public void setDowngradePerformance(@NonNull MethodCall call, @NonNull MethodChannel.Result result){
        XmagicApiManager.getInstance().setDowngradePerformance();
        result.success(true);
    }


    @Override
    public void setAudioMute(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof Boolean) {
            boolean isMute = (boolean) call.arguments;
            XmagicApiManager.getInstance().setAudioMute(isMute);
            result.success(true);
        }else {
            resultParameterError(call.method, result);
        }
    }

    @Override
    public void setFeatureEnableDisable(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        boolean isSuccess = false;
        if (call.arguments instanceof Map) {
            try {
                Map<String, Boolean> map = (Map<String, Boolean>) call.arguments;
                Set<String> keys = map.keySet();
                for (String key : keys) {
                    if (map.get(key) == null) {
                        LogUtils.e(TAG, "setFeatureEnableDisable  key = " + key + "  value is null");
                        break;
                    }
                    XmagicApiManager.getInstance().setFeatureEnableDisable(key, Boolean.TRUE.equals(map.get(key)));
                }
                isSuccess = true;
            } catch (Exception ignored) {
                ignored.printStackTrace();
            }
        }
        if (isSuccess) {
            result.success(true);
        } else {
            resultParameterError(call.method, result);
        }
    }

    @Override
    public void setImageOrientation(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        boolean isSuccess = false;
        if (call.arguments instanceof Integer) {
            try {
                int orientation = (int) call.arguments;
                XmagicApiManager.getInstance().setImageOrientation(orientation);
                isSuccess = true;
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (isSuccess) {
                    result.success(null);
                } else {
                    resultParameterError(call.method, result);
                }
            }
        } else {
            resultParameterError(call.method, result);
        }
    }

    @Override
    public void enableAIDataListener(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof Boolean) {
            boolean isMute = (boolean) call.arguments;
            XmagicApiManager.getInstance().enableAIDataListener(isMute);
            result.success(true);
        }else {
            resultParameterError(call.method, result);
        }
    }

    @Override
    public void enableYTDataListener(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof Boolean) {
            boolean isMute = (boolean) call.arguments;
            XmagicApiManager.getInstance().enableYTDataListener(isMute);
            result.success(true);
        }else {
            resultParameterError(call.method, result);
        }
    }

    @Override
    public void enableTipsListener(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.arguments instanceof Boolean) {
            boolean isMute = (boolean) call.arguments;
            XmagicApiManager.getInstance().enableTipsListener(isMute);
            result.success(true);
        }else {
            resultParameterError(call.method, result);
        }
    }


    private void sendBoolData(String methodName, boolean data) {
        Map<String, Object> result = new ArrayMap<>();
        result.put("methodName", methodName);
        result.put("data", data);
        if (mEventSink != null) {
            handler.post(() -> mEventSink.success(result));
        }
    }

    private void sendStringData(String methodName, String data) {
        Map<String, String> result = new ArrayMap<>();
        result.put("methodName", methodName);
        result.put("data", data);
        if (mEventSink != null) {
            handler.post(() -> mEventSink.success(result));
        }
    }

    private void sendMapData(String methodName, Map<String, Object> data) {
        Map<String, Object> result = new ArrayMap<>();
        result.put("methodName", methodName);
        result.put("data", data);
        if (mEventSink != null) {
            handler.post(() -> mEventSink.success(result));
        }
    }


    private void resultParameterError(String methodName, MethodChannel.Result result) {
        LogUtils.d(TAG, methodName + "method parameter invalid ");
        result.error(methodName + " method parameter invalid", "-1", null);
    }


}
