// NOCA:CopyrightChecker
package com.tencent.effect.tencent_effect_flutter.res;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
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

        new File(sResPath, "light_assets").delete();
        new File(sResPath, "light_material").delete();
        new File(sResPath, "MotionRes").delete();

        for (String path : new String[]{"Light3DPlugin", "LightCore", "LightHandPlugin", "LightBodyPlugin",
                "LightSegmentPlugin"}) {
            boolean result = copyAssets(context, path, sResPath + "light_assets");
            if (!result) {
                Log.d(TAG, "copyRes: fail,path=" + path + ",new path=" + sResPath + "light_assets");
                return false;
            }
        }

        for (String path : new String[]{"lut"}) {
            boolean result = copyAssets(context, path, sResPath + "light_material" + File.separator + path);
            if (!result) {
                Log.d(TAG, "copyRes: fail,path=" + path + ",new path=" + sResPath + "light_material" + File.separator
                        + path);
                return false;
            }
        }

        for (String path : new String[]{"MotionRes"}) {
            boolean result = copyAssets(context, path, sResPath + path);
            if (!result) {
                Log.d(TAG, "copyRes: fail,path=" + path + ",new path=" + sResPath + path);
                return false;
            }
        }

        return true;
    }

    /**
     * 复制asset文件到指定目录
     *
     * @param oldPath asset下的路径
     * @param newPath SD卡下保存路径
     */
    private static boolean copyAssets(Context context, String oldPath, String newPath) {

        String [] fileNames;// 获取assets目录下的所有文件及目录名
        try {
            fileNames = context.getAssets().list(oldPath);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
        if (fileNames != null && fileNames.length > 0) {// 如果是目录
            Log.d(TAG, "copyAssets path: " + Arrays.toString(fileNames));
            File file = new File(newPath);
            file.mkdirs();// 如果文件夹不存在，则递归
            for (String fileName : fileNames) {
                boolean result = copyAssets(context, oldPath + "/" + fileName, newPath + "/" + fileName);
                if (!result) {
                    Log.d(TAG, "copyAssets: fail,oldPath=" + oldPath + "/" + fileName + ",newPath=" + newPath + "/"
                            + fileName);
                    return false;
                }
            }
            return true;
        } else {// oldPath是文件 或者 空文件夹
            InputStream is;
            try {
                is = context.getAssets().open(oldPath);
            } catch (IOException e) {
                e.printStackTrace();
                //如果oldPath不存在或者是空文件夹，这里会抛出异常。但这是正常情况（比如某些套餐没有MotionRes）
                //因此返回true
                return true;
            }
            FileOutputStream fos;
            try {
                fos = new FileOutputStream(new File(newPath));
                byte[] buffer = new byte[1024 * 1024];
                int byteCount = 0;
                while ((byteCount = is.read(buffer)) != -1) {// 循环从输入流读取
                    // buffer字节
                    fos.write(buffer, 0, byteCount);// 将读取的输入流写入到输出流
                }
                fos.flush();// 刷新缓冲区
            } catch (Exception e) {
                e.printStackTrace();
                //在文件copy过程中的异常，是真的异常，因此返回false
                return false;
            }

            try {
                is.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            try {
                fos.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            return true;
        }
    }

    private static void ensureResPathAlreadySet() {
        if (TextUtils.isEmpty(sResPath)) {
            throw new IllegalStateException("resource path not set, call XmagicResParser.setResPath() first.");
        }
    }




}
