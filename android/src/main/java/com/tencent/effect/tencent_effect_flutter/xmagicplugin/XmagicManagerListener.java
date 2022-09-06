package com.tencent.effect.tencent_effect_flutter.xmagicplugin;


/**
 * tencent_effect_flutter
 * Created by kevinxlhua on 2022/8/12.
 * Copyright (c) 2020年 Tencent. All rights reserved
 */


public interface XmagicManagerListener {

    /**
     * 异常信息回调方法
     * @param errorMsg 异常描述
     * @param code 错误码，对照表：
     * <li>-1：未知错误。Unknown error</li>
     * <li>-100：3D引擎资源初始化失败。Failed to initialize the 3D engine resources </li>
     * <li>-200：不支持GAN素材。The GAN material is not supported</li>
     * <li>-300：设备不支持此素材组件。The device does not support this material component</li>
     * <li>-400：模板json内容为空。The JSON content in the template is empty</li>
     * <li>-500：SDK版本过低。The SDK version is too low</li>
     // NOCA: InnerUsernameLeak(忽略原因)
     * <li>-600：不支持分割。Head keying is not supported</li>
     * <li>-700：不支持OpenGL。OpenGL is not supported</li>
     * <li>-800：不支持脚本。Script is not supported</li>
     * <li>5000：分割背景图片分辨率超过2160*3840。The resolution of the split background image exceeds 2160*3840</li>
     * <li>5001：分割背景图片所需内存不足。Insufficient memory required to split the background image</li>
     * <li>5002：分割背景视频解析失败。Split background video parsing failed</li>
     * <li>5003：分割背景视频超过200秒。Split background video over 200 seconds</li>
     * <li>5004：分割背景视频格式不支持。Split background video format is not supported</li>
     * <li>9000：应用内的部分文件丢失，初始化失败。Some files in the application are lost,initialization failed</li>
     */
    void onXmagicPropertyError(String errorMsg, int code);

    /**
     * 显示tips。Show the tip.
     * @param tips tips字符串。Tip's content
     * @param tipsIcon tips的icon。Tip's icon
     * @param type tips类别，0表示字符串和icon都展示，1表示是pag素材只展示icon。tips category,
     *            0 means that both strings and icons are displayed,
     *            1 means that only the icon is displayed for the pag material
     * @param duration tips显示时长, 毫秒。Tips display duration, milliseconds
     */
    void tipsNeedShow(String tips, String tipsIcon, int type, int duration);

    /***
     * 隐藏tips。Hide the tip.
     * @param tips tips字符串。Tip's content
     * @param tipsIcon tips的icon。Tip's icon
     * @param type tips类别，0表示字符串和icon都展示，1表示是pag素材只展示icon。
     *             tips category,
     *             0 means that both strings and icons are displayed,
     *             1 means that only the icon is displayed for the pag material
     */
    void tipsNeedHide(String tips, String tipsIcon, int type);

    void onFaceDataUpdated(String jsonData);
    void onHandDataUpdated(String jsonData);
    void onBodyDataUpdated(String jsonData);


    /**
     * 优图AI数据回调。Callback of Youtu AI data.
     * @param data String in JSON format.
     */
    void onYTDataUpdate(String data);
}
