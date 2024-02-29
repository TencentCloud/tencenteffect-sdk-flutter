import 'dart:io';

import 'package:tencent_effect_flutter_demo/manager/res_path_manager_android.dart';
import 'package:tencent_effect_flutter_demo/manager/res_path_manager_ios.dart';



abstract class ResPathManager {
  static const String TE_RES_DIR_NAME = "xmagic";

  ///在json文件中本地素材配置的前缀
  static const String JSON_RES_MARK_LUT = "light_material/lut/";
  static const String JSON_RES_MARK_MAKEUP = "MotionRes/makeupRes/";
  static const String JSON_RES_MARK_MOTION_2D = "MotionRes/2dMotionRes/";
  static const String JSON_RES_MARK_MOTION_3D = "MotionRes/3dMotionRes/";
  static const String JSON_RES_MARK_MOTION_GESTURE = "MotionRes/handMotionRes/";
  static const String JSON_RES_MARK_MOTION_GAN = "MotionRes/ganMotionRes/";
  static const String JSON_RES_MARK_SEG = "MotionRes/segmentMotionRes/";

  ///获取资源的存储路径，在美颜SDK初始化时调用
  ///Get the storage path of the resource, which is called when the Beauty SDK is initialized
  Future<String> getResPath();

  ///获取滤镜资源路径
  ///Get filter resource path
  Future<String> getLutDir();

  ///获取动效中的2D资源路径
  ///Get the 2D resource path in the animation
  Future<String> getMotion2dDir();

  ///获取动效中的3D资源路径
  ///Get the 3D resource path in the animation
  Future<String> getMotion3dDir();

  ///获取动效中的手势资源路径
  ///Get the gesture resource path in the animation
  Future<String> getMotionGestureDir();

  ///获取动效中的趣味资源路径
  ///Get interesting resource paths in motion effects
  Future<String> getMotionGanDir();

  ///获取美妆资源路径
  ///Get the Makeup resource path
  Future<String> getMakeUpDir();

  ///获取分割资源路径
  ///Get split resource path
  Future<String> getSegDir();


  static ResPathManager getResManager() {
    if (resPathManager == null) {
      if (Platform.isAndroid) {
        resPathManager = ResPathManagerAndroid();
      } else if (Platform.isIOS) {
        resPathManager = ResPathManagerIos();
      } else {}
      return resPathManager!;
    }else{
      return resPathManager!;
    }
  }

  static ResPathManager? resPathManager;

  ResPathManager._internal();
}
