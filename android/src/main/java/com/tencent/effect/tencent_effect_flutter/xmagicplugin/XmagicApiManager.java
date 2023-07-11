package com.tencent.effect.tencent_effect_flutter.xmagicplugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.effect.tencent_effect_flutter.res.XmagicResParser;
import com.tencent.effect.tencent_effect_flutter.utils.LogUtils;
import com.tencent.xmagic.XmagicApi;
import com.tencent.xmagic.XmagicApi.XmagicAIDataListener;
import com.tencent.xmagic.XmagicApi.XmagicTipsListener;
import com.tencent.xmagic.XmagicProperty;
import com.tencent.xmagic.bean.TEBodyData;
import com.tencent.xmagic.bean.TEFaceData;
import com.tencent.xmagic.bean.TEHandData;
import com.tencent.xmagic.telicense.TELicenseCheck;
import com.tencent.xmagic.telicense.TELicenseCheck.TELicenseCheckListener;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import com.tencent.xmagic.XmagicConstant;


/**
 * tencent_effect_flutter
 * Created by kevinxlhua on 2022/8/12.
 * Copyright (c) 2020年 Tencent. All rights reserved
 */

public class XmagicApiManager implements SensorEventListener {

    private static final String TAG = "XMagicWrapper";

    private XmagicApi xmagicApi;
    //判断当前手机旋转方向，用于手机在不同的旋转角度下都能正常的识别人脸
    private SensorManager mSensorManager;
    private Sensor mAccelerometer;
    private Context mApplicationContext = null;
    private XmagicManagerListener managerListener;

    private int currentStreamType = XmagicApi.PROCESS_TYPE_CAMERA_STREAM;


    static class ClassHolder {
        static final XmagicApiManager INSTANCE = new XmagicApiManager();
    }

    public static XmagicApiManager getInstance() {
        return ClassHolder.INSTANCE;
    }


    /**
     * 复制美颜所需的资源文件
     *
     * @param context
     * @return
     */
    public void initModelResource(Context context,String pathDir, InitModelResourceCallBack callBack) {
        if(TextUtils.isEmpty(pathDir)){
            if (callBack != null) {
                callBack.onResult(false);
            }
            return;
        }
        if(!new File(pathDir).exists()){
            new File(pathDir).mkdirs();
        }
        XmagicResParser.setResPath(pathDir);
        new Thread(() -> {
            boolean result = XmagicResParser.copyRes(context.getApplicationContext());
            new Handler(Looper.getMainLooper()).post(() -> {
                if (callBack != null) {
                    callBack.onResult(result);
                }
            });
        }).start();
    }


    public void setTELicense(Context context, String url, String key, TELicenseCheckListener licenseCheckListener) {
        TELicenseCheck.getInstance().setTELicense(context, url, key, (errorCode, msg) -> {
            LogUtils.d(TAG, "onLicenseCheckFinish: errorCode=" + errorCode + ",msg=" + msg);
            if (licenseCheckListener != null) {
                licenseCheckListener.onLicenseCheckFinish(errorCode, msg);
            }
        });
    }

    public void createXmagicApi() {
        xmagicApi = new XmagicApi(mApplicationContext, XmagicResParser.getResPath(), (s, i) -> {
            if (managerListener != null) {
                managerListener.onXmagicPropertyError(s, i);
            }
        });
        mSensorManager = (SensorManager) mApplicationContext.getSystemService(Context.SENSOR_SERVICE);
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        xmagicApi.setAIDataListener(new XmagicAIDataListener() {
            @Override
            public void onFaceDataUpdated(List<TEFaceData> list) {
                if (list == null) {
                    return;
                }
                if (managerListener != null) {
                    managerListener.onFaceDataUpdated(new Gson().toJson(list));
                }
            }

            @Override
            public void onHandDataUpdated(List<TEHandData> list) {
                if (list == null) {
                    return;
                }
                if (managerListener != null) {
                    managerListener.onHandDataUpdated(new Gson().toJson(list));
                }
            }

            @Override
            public void onBodyDataUpdated(List<TEBodyData> list) {
                if (list == null) {
                    return;
                }
                if (managerListener != null) {
                    managerListener.onBodyDataUpdated(new Gson().toJson(list));
                }
            }

            @Override
            public void onAIDataUpdated(String s) {
                if (managerListener != null) {
                    managerListener.onYTDataUpdate(s);
                }
            }
        });
        xmagicApi.setTipsListener(new XmagicTipsListener() {
            @Override
            public void tipsNeedShow(String tips, String tipsIcon, int type, int duration) {
                if (managerListener != null) {
                    managerListener.tipsNeedShow(tips, tipsIcon, type, duration);
                }
            }

            @Override
            public void tipsNeedHide(String tips, String tipsIcon, int type) {
                if (managerListener != null) {
                    managerListener.tipsNeedHide(tips, tipsIcon, type);
                }
            }
        });

        XmagicProperty.XmagicPropertyValues values = new XmagicProperty.XmagicPropertyValues(0, 100, 1, 0, 1);
        String effKey = XmagicConstant.BeautyConstant.BEAUTY_WHITEN;
        xmagicApi.updateProperty(new XmagicProperty<>(XmagicProperty.Category.BEAUTY, null, null, effKey, values));
    }

    public void setXMagicStreamType(int type) {
        if (xmagicApi != null) {
            xmagicApi.setXmagicStreamType(type);
        }
    }

    public void setXmagicLogLevel(int level) {
        if (xmagicApi != null) {
            xmagicApi.setXmagicLogLevel(level);
        }
    }

    public void onResume() {
        if (xmagicApi != null) {
            xmagicApi.onResume();
            if (mSensorManager != null) {
                mSensorManager.registerListener(this, mAccelerometer, SensorManager.SENSOR_DELAY_NORMAL);
            }
        }
    }

    public void onPause() {
        if (xmagicApi != null) {
            xmagicApi.onPause();
            if (mSensorManager != null) {
                mSensorManager.unregisterListener(this);
            }
        }
    }

    public void onDestroy() {
        if (xmagicApi != null) {
            currentStreamType = XmagicApi.PROCESS_TYPE_CAMERA_STREAM;
            xmagicApi.onDestroy();
            xmagicApi = null;
        }
    }

    public void updateProperty(XmagicProperty<XmagicProperty.XmagicPropertyValues> xmagicProperty) {
        if (xmagicApi != null) {
            xmagicApi.updateProperty(xmagicProperty);
        }
    }

    public int process(int textureId, int width, int height) {
        if (xmagicApi == null) {
            return textureId;
        }
        if (currentStreamType != XmagicApi.PROCESS_TYPE_CAMERA_STREAM) {
            currentStreamType = XmagicApi.PROCESS_TYPE_CAMERA_STREAM;
            setXMagicStreamType(currentStreamType);
        }
        return xmagicApi.process(textureId, width, height);
    }

    public Bitmap process(Bitmap bitmap){
        if (xmagicApi == null || bitmap == null ) {
            return bitmap;
        }
        if (currentStreamType != XmagicApi.PROCESS_TYPE_PICTURE_DATA) {
            currentStreamType = XmagicApi.PROCESS_TYPE_PICTURE_DATA;
            setXMagicStreamType(currentStreamType);
        }
        //TODO 此处需要优化  true不能写死，后期要进行修改
        return xmagicApi.process(bitmap, true);
    }





    /**
     * 判断此属性是否已经鉴权
     *
     * @param properties
     */
    public void isBeautyAuthorized(List<XmagicProperty<?>> properties) {
        if (xmagicApi == null) {
            LogUtils.e(TAG, "isBeautyAuthorized  xmagicApi == null ");
            return;
        }
        xmagicApi.isBeautyAuthorized(properties);

    }

    /**
     * 判断此设备是否支持美颜
     *
     * @return
     */
    public boolean isSupportBeauty() {
        if (xmagicApi == null) {
            return true;
        }
        return xmagicApi.isSupportBeauty();
    }

    /**
     * 将动效资源列表传入 SDK 中做检测，执行后 XmagicProperty.isSupport 字段标识该原子能力是否可用。
     * 根据 XmagicProperty.isSupport 可 UI 层控制单击限制，或者直接从资源列表删除
     *
     * @param assetsList
     */
    public void isDeviceSupport(List<XmagicProperty<?>> assetsList) {
        if (xmagicApi == null) {
            return;
        }
        xmagicApi.isDeviceSupport(assetsList);
    }

    /**
     * 传入一个动效资源列表，返回每一个资源所使用到的 SDK 原子能力列表
     *
     * @param assets 动效资源列表
     * @return
     */
    public Map<XmagicProperty<?>, ArrayList<String>> getPropertyRequiredAbilities(List<XmagicProperty<?>> assets) {
        if (xmagicApi == null) {
            return null;
        }
        return xmagicApi.getPropertyRequiredAbilities(assets);
    }

    /**
     * 返回当前设备支持的原子能力
     *
     * @return
     */
    public Map<String, Boolean> getDeviceAbilities() {
        if (xmagicApi == null) {
            return null;
        }
        return xmagicApi.getDeviceAbilities();
    }


    @Override
    public void onSensorChanged(SensorEvent event) {
        if (xmagicApi != null) {
            xmagicApi.sensorChanged(event, mAccelerometer);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }


    public void setmApplicationContext(Context context) {
        mApplicationContext = context;
    }

    /**
     * 判断xmagicAPI对象是否为空
     *
     * @return
     */
    public boolean xmagicApiIsNull() {
        return xmagicApi == null;
    }

    public void setManagerListener(XmagicManagerListener managerListener) {
        this.managerListener = managerListener;
    }

    public int getCurrentStreamType() {
        return currentStreamType;
    }


    public void enableEnhancedMode() {
        if (xmagicApi != null) {
            xmagicApi.enableEnhancedMode();
        }
    }

    interface InitModelResourceCallBack {
        void onResult(boolean isCopySuccess);
    }


}
