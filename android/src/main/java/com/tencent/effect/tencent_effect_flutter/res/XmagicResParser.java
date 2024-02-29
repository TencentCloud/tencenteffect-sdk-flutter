// NOCA:CopyrightChecker
package com.tencent.effect.tencent_effect_flutter.res;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.effect.tencent_effect_flutter.utils.LogUtils;
import com.tencent.xmagic.XmagicApi;
import com.tencent.xmagic.util.FileUtil;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;


/**
 * tencent_effect_flutter
 * Created by kevinxlhua on 2022/8/12.
 * Copyright (c) 2020年 Tencent. All rights reserved
 */


public class XmagicResParser {

    private static final String TAG = XmagicResParser.class.getSimpleName();

    /**
     * 约定以 "/" 结尾, 方便拼接
     * xmagic resource local path
     */
    private static String sResPath;


    /**
     * 直接使用此类的方法，需要注意使用顺序
     * 1. 调用setResPath（）设置存放资源的路径
     * 2. copyRes(Context context) 将asset中的资源文件复制到 第一步设置的路径下
     * 3. 调用parseRes()方法对资源进行分类处理
     * 4. 之后就可以使用XmagicPanelView和XmagicPanelDataManager.getInstance()类的方法
     *
     * Direct use of such methods, need to pay attention to the order of use
     * 1. Call setResPath() to set the path for storing resources
     * 2. copyRes(Context context) Copy the resource file in the asset to the path set in the first step
     * 3. Call the parseRes() method to classify the resources
     * 4. Then you can use the methods of XmagicPanelView and XmagicPanelDataManager.getInstance() classes
     */
    private XmagicResParser() {/*nothing*/}

    /**
     * 设置asset 资源存放的位置
     * set the asset path
     *
     * @param path
     */
    public static void setResPath(String path) {
        if (!path.endsWith(File.separator)) {
            path = path + File.separator;
        }
        sResPath = path;
    }

    public static String getResPath() {
        ensureResPathAlreadySet();
        return sResPath;
    }

    /**
     * 从 apk 的 assets 解压资源文件到指定路径, 需要先设置路径: {@link #setResPath(String)} <br>
     * 首次安装 App, 或 App 升级后调用一次即可.
     * copy xmagic resource from assets to local path
     */
    public static boolean copyRes(Context context) {
        ensureResPathAlreadySet();

        if (TextUtils.isEmpty(sResPath)) {
            throw new IllegalStateException("resource path not set, call XmagicResParser.setResPath() first.");
        }
        int addResult = XmagicApi.addAiModeFilesFromAssets(context, sResPath);
        LogUtils.e(TAG, "add ai model files result = " + addResult);
        String lutDirName = "lut";
        boolean result = FileUtil.copyAssets(context, lutDirName, sResPath + "light_material" + File.separator + lutDirName);
        String motionResDirName = "MotionRes";
        boolean result2 = FileUtil.copyAssets(context, motionResDirName, sResPath + motionResDirName);
        return result && result2;
    }


    private static void ensureResPathAlreadySet() {
        if (TextUtils.isEmpty(sResPath)) {
            throw new IllegalStateException("resource path not set, call XmagicResParser.setResPath() first.");
        }
    }




}
