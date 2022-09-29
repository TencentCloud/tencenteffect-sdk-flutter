import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tencent_effect_flutter/model/beauty_constant.dart';
import 'package:tencent_effect_flutter/model/xmagic_property.dart';
import 'package:tencent_effect_flutter/utils/Logs.dart';

import '../languages/AppLocalizations.dart';
import 'beauty_data_manager.dart';

/// 用于构造美颜属性数据
///construct beauty attribute data
abstract class BeautyPropertyProducer {
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
  Future<String> getMotionhandDir();

  ///获取动效中的趣味资源路径
  ///Get interesting resource paths in motion effects
  Future<String> getMotionganDir();

  ///获取美妆资源路径
  ///Get the Makeup resource path
  Future<String> getMakeUpDir();

  ///获取分割资源路径
  ///Get split resource path
  Future<String> getSegDir();

  ///获取美颜面板的所有数据
  ///Get all the data of the beauty panel
  Future<Map<String, List<XmagicUIProperty>>> getAllDatas(
      BuildContext context) async {
    Map<String, List<XmagicUIProperty>> resultData = {};
    List<XmagicUIProperty> beautyLists = await getBeautyData(context);
    if (beautyLists.isNotEmpty) {
      resultData[Category.BEAUTY] = beautyLists;
    }

    List<XmagicUIProperty> beautyBodyLists = await getBeautyBodyData(context);
    if (beautyBodyLists.isNotEmpty) {
      resultData[Category.BODY_BEAUTY] = beautyBodyLists;
    }

    List<XmagicUIProperty>? lutLists = await getLutData(context);
    if (lutLists != null && lutLists.isNotEmpty) {
      resultData[Category.LUT] = lutLists;
    }

    List<XmagicUIProperty>? motionLists = await getMotionData(context);
    if (motionLists != null && motionLists.isNotEmpty) {
      resultData[Category.MOTION] = motionLists;
    }

    List<XmagicUIProperty>? makeupLists = await getMakeupData(context);
    if (makeupLists != null && makeupLists.isNotEmpty) {
      resultData[Category.MAKEUP] = makeupLists;
    }

    List<XmagicUIProperty>? segLists = await getSegmentMotionData(context);
    if (segLists != null && segLists.isNotEmpty) {
      resultData[Category.SEGMENTATION] = segLists;
    }

    return resultData;
  }

  ///获取美颜数据
  ///Get beauty data
  Future<List<XmagicUIProperty>> getBeautyData(BuildContext context);

  ///获取美体数据
  ///Get body data
  Future<List<XmagicUIProperty>> getBeautyBodyData(BuildContext context) async {
    List<XmagicUIProperty>? beautyBodyList = [];
    beautyBodyList.add(XmagicUIProperty(
        uiCategory: Category.BODY_BEAUTY,
        displayName: AppLocalizations.of(context)!.autohtinBodyStrengthLabel,
        thumbDrawableName: "body_autohtin_body_strength",
        effKey: BeautyConstant.BODY_AUTOTHIN_BODY_STRENGTH,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyBodyList.add(XmagicUIProperty(
        uiCategory: Category.BODY_BEAUTY,
        displayName: AppLocalizations.of(context)!.bodyLegStretchLabel,
        thumbDrawableName: "body_leg_stretch",
        effKey: BeautyConstant.BODY_LEG_STRETCH,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyBodyList.add(XmagicUIProperty(
        uiCategory: Category.BODY_BEAUTY,
        displayName: AppLocalizations.of(context)!.bodySlimLegStrengthLabel,
        thumbDrawableName: "body_slim_leg_strength",
        effKey: BeautyConstant.BODY_SLIM_LEG_STRENGTH,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyBodyList.add(XmagicUIProperty(
        uiCategory: Category.BODY_BEAUTY,
        displayName: AppLocalizations.of(context)!.bodyWaishStrengthLabel,
        thumbDrawableName: "body_waish_strength",
        effKey: BeautyConstant.BODY_WAIST_STRENGTH,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyBodyList.add(XmagicUIProperty(
        uiCategory: Category.BODY_BEAUTY,
        displayName:
            AppLocalizations.of(context)!.bodyThinShoulderStrengthLabel,
        thumbDrawableName: "body_thin_shoulder_strength",
        effKey: BeautyConstant.BODY_THIN_SHOULDER_STRENGTH,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyBodyList.add(XmagicUIProperty(
        uiCategory: Category.BODY_BEAUTY,
        displayName: AppLocalizations.of(context)!.bodySlimHeadStrengthLabel,
        thumbDrawableName: "body_slim_head_strength",
        effKey: BeautyConstant.BODY_SLIM_HEAD_STRENGTH,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));

    return beautyBodyList;
  }

  ///获取滤镜数据
  ///Get filter data
  Future<List<XmagicUIProperty>?> getLutData(BuildContext context) async {
    String lutDir = await getLutDir();
    TXLog.printlog('lut resource dir is  $lutDir');
    if (!await Directory(lutDir).exists()) {
      return null;
    }
    List<FileSystemEntity> stream = Directory(lutDir).listSync();
    List<String> fileNames = [];
    for (var element in stream) {
      FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
      if (type == FileSystemEntityType.file) {
        fileNames.add(getFileName(element.path));
      }
    }
    if (fileNames.isEmpty) {
      return null;
    }
    List<XmagicUIProperty> lutDatas = [];
    lutDatas.add(XmagicUIProperty(
        uiCategory: Category.LUT,
        displayName: AppLocalizations.of(context)!.noneLabel,
        id: XmagicProperty.ID_NONE,
        resPath: "",
        thumbDrawableName: "naught"));
    Map lutMaps = BeautyDataManager.getMaterialDataByStr(
        AppLocalizations.of(context)!.luts);
    for (var filename in fileNames) {
      if (await exists(lutDir + filename)) {
        lutDatas.add(XmagicUIProperty(
            uiCategory: Category.LUT,
            displayName: lutMaps[filename],
            id: filename,
            resPath: lutDir + filename,
            thumbDrawableName: BeautyDataManager.lutDataMap[filename],
            effValue: XmagicPropertyValues(0, 100, 60, 0, 1)));
      }
    }
    return lutDatas;
  }

  ///获取动效数据
  ///Get motion data
  Future<List<XmagicUIProperty>?> getMotionData(BuildContext context) async {
    List<XmagicUIProperty> motionDatas = [];
    if ((await _get2dMotionData(context)).displayName != null) {
      motionDatas.add(await _get2dMotionData(context));
    }
    if ((await _get3dMotionData(context)).displayName != null) {
      motionDatas.add(await _get3dMotionData(context));
    }
    if ((await _getHandMotionData(context)).displayName != null) {
      motionDatas.add(await _getHandMotionData(context));
    }
    if ((await _getGanMotionData(context)).displayName != null) {
      motionDatas.add(await _getGanMotionData(context));
    }
    if (motionDatas.isEmpty) {
      return null;
    }
    XmagicUIProperty uiProperty = XmagicUIProperty(
      uiCategory: Category.MOTION,
      displayName: AppLocalizations.of(context)!.noneLabel,
      id: XmagicProperty.ID_NONE,
      thumbDrawableName: 'naught',
      resPath: await _getNoneItemResPath(),
    );
    motionDatas.insert(0, uiProperty);
    return motionDatas;
  }

  ///获取2dMotion数据
  ///Get 2dMotion data
  Future<XmagicUIProperty> _get2dMotionData(BuildContext context) async {
    XmagicUIProperty motion2dData = XmagicUIProperty();
    List<XmagicUIProperty> motion2dDatas = [];
    String motion2dDir = await getMotion2dDir();
    List<FileSystemEntity> stream = Directory(motion2dDir).listSync();
    List<String> fileNames = [];
    for (var element in stream) {
      FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
      if (type == FileSystemEntityType.directory) {
        fileNames.add(getFileName(element.path));
      }
    }
    if (fileNames.isEmpty) {
      return motion2dData;
    }
    Map map = BeautyDataManager.getMaterialDataByStr(
        AppLocalizations.of(context)!.motions);
    for (var filename in fileNames) {
      if (await exists(motion2dDir + filename)) {
        XmagicUIProperty uiProperty = XmagicUIProperty(
            uiCategory: Category.MOTION,
            displayName: map[filename],
            id: filename,
            resPath: _getPropertyResPath(motion2dDir, filename),
            rootDisplayName: AppLocalizations.of(context)!.motion2dLabel,
            thumbImagePath: await _getThumbImagePath(motion2dDir, filename));
        motion2dDatas.add(uiProperty);
      }
    }
    motion2dData = XmagicUIProperty(
        uiCategory: Category.MOTION,
        displayName: AppLocalizations.of(context)!.motion2dLabel,
        thumbDrawableName: 'motion_2d',
        xmagicUIPropertyList: motion2dDatas);
    return motion2dData;
  }

  ///获取3dMotion数据
  ///Get 3dMotion data
  Future<XmagicUIProperty> _get3dMotionData(BuildContext context) async {
    XmagicUIProperty motion3dData = XmagicUIProperty();
    List<XmagicUIProperty> motion3dDatas = [];
    String motion3dDir = await getMotion3dDir();
    List<FileSystemEntity> stream = Directory(motion3dDir).listSync();
    List<String> fileNames = [];
    for (var element in stream) {
      FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
      if (type == FileSystemEntityType.directory) {
        fileNames.add(getFileName(element.path));
      }
    }
    if (fileNames.isEmpty) {
      return motion3dData;
    }
    Map map = BeautyDataManager.getMaterialDataByStr(
        AppLocalizations.of(context)!.motions);
    for (var filename in fileNames) {
      if (await exists(motion3dDir + filename)) {
        XmagicUIProperty uiProperty = XmagicUIProperty(
            uiCategory: Category.MOTION,
            displayName: map[filename],
            id: filename,
            resPath: _getPropertyResPath(motion3dDir, filename),
            rootDisplayName: AppLocalizations.of(context)!.motion3dLabel,
            thumbImagePath: await _getThumbImagePath(motion3dDir, filename));
        motion3dDatas.add(uiProperty);
      }
    }
    motion3dData = XmagicUIProperty(
        uiCategory: Category.MOTION,
        displayName: AppLocalizations.of(context)!.motion3dLabel,
        thumbDrawableName: 'motion_3d',
        xmagicUIPropertyList: motion3dDatas);
    return motion3dData;
  }

  ///获取手势数据
  ///Get gesture data
  Future<XmagicUIProperty> _getHandMotionData(BuildContext context) async {
    XmagicUIProperty motionHandData = XmagicUIProperty();
    List<XmagicUIProperty> motionHandDatas = [];
    String handMotionDir = await getMotionhandDir();
    List<FileSystemEntity> stream = Directory(handMotionDir).listSync();
    List<String> fileNames = [];
    for (var element in stream) {
      FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
      if (type == FileSystemEntityType.directory) {
        fileNames.add(getFileName(element.path));
      }
    }
    if (fileNames.isEmpty) {
      return motionHandData;
    }
    Map map = BeautyDataManager.getMaterialDataByStr(
        AppLocalizations.of(context)!.motions);
    for (var filename in fileNames) {
      if (await exists(handMotionDir + filename)) {
        XmagicUIProperty uiProperty = XmagicUIProperty(
            uiCategory: Category.MOTION,
            displayName: map[filename],
            id: filename,
            resPath: _getPropertyResPath(handMotionDir, filename),
            rootDisplayName: AppLocalizations.of(context)!.motionhandLabel,
            thumbImagePath: await _getThumbImagePath(handMotionDir, filename));
        motionHandDatas.add(uiProperty);
      }
    }
    motionHandData = XmagicUIProperty(
        uiCategory: Category.MOTION,
        displayName: AppLocalizations.of(context)!.motionhandLabel,
        thumbDrawableName: 'motion_hand',
        xmagicUIPropertyList: motionHandDatas);
    return motionHandData;
  }

  ///获取趣味数据
  ///Get GanMotion data
  Future<XmagicUIProperty> _getGanMotionData(BuildContext context) async {
    XmagicUIProperty motionHandData = XmagicUIProperty();
    List<XmagicUIProperty> motionGanDatas = [];
    String ganMotionDir = await getMotionganDir();
    List<FileSystemEntity> stream = Directory(ganMotionDir).listSync();
    List<String> fileNames = [];
    for (var element in stream) {
      FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
      if (type == FileSystemEntityType.directory) {
        fileNames.add(getFileName(element.path));
      }
    }
    if (fileNames.isEmpty) {
      return motionHandData;
    }
    Map map = BeautyDataManager.getMaterialDataByStr(
        AppLocalizations.of(context)!.motions);
    for (var filename in fileNames) {
      if (await exists(ganMotionDir + filename)) {
        XmagicUIProperty uiProperty = XmagicUIProperty(
            uiCategory: Category.MOTION,
            displayName: map[filename],
            id: filename,
            resPath: _getPropertyResPath(ganMotionDir, filename),
            rootDisplayName: AppLocalizations.of(context)!.motionganLabel,
            thumbImagePath: await _getThumbImagePath(ganMotionDir, filename));
        motionGanDatas.add(uiProperty);
      }
    }
    motionHandData = XmagicUIProperty(
        uiCategory: Category.MOTION,
        displayName: AppLocalizations.of(context)!.motionganLabel,
        thumbDrawableName: 'motion_gan',
        xmagicUIPropertyList: motionGanDatas);
    return motionHandData;
  }

  ///获取美妆数据
  ///Get makeup data
  Future<List<XmagicUIProperty>?> getMakeupData(BuildContext context) async {
    List<XmagicUIProperty> makeupDatas = [];
    String makeupDir = await getMakeUpDir();
    List<FileSystemEntity> stream = Directory(makeupDir).listSync();
    List<String> fileNames = [];
    for (var element in stream) {
      FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
      if (type == FileSystemEntityType.directory) {
        fileNames.add(getFileName(element.path));
      }
    }
    if (fileNames.isEmpty) {
      return null;
    }
    makeupDatas.add(XmagicUIProperty(
        uiCategory: Category.MAKEUP,
        displayName: AppLocalizations.of(context)!.noneLabel,
        id: XmagicProperty.ID_NONE,
        resPath: await _getNoneItemResPath(),
        thumbDrawableName: "naught"));
    Map map = BeautyDataManager.getMaterialDataByStr(
        AppLocalizations.of(context)!.makeups);
    for (var filename in fileNames) {
      if (await exists(makeupDir + filename)) {
        XmagicUIProperty uiProperty = XmagicUIProperty(
            uiCategory: Category.MAKEUP,
            displayName: map[filename],
            id: filename,
            resPath: _getPropertyResPath(makeupDir, filename),
            thumbImagePath: await _getThumbImagePath(makeupDir, filename),
            effKey: BeautyConstant.MAKEUP_EFF_KEY,
            effValue: XmagicPropertyValues(0, 100, 60, 0, 1));
        makeupDatas.add(uiProperty);
      }
    }
    return makeupDatas;
  }

  ///获取分割数据
  ///Get SegmentMotion data
  Future<List<XmagicUIProperty>?> getSegmentMotionData(
      BuildContext context) async {
    List<XmagicUIProperty> segmentMotionDatas = [];
    String segmentMotionDir = await getSegDir();
    List<FileSystemEntity> stream = Directory(segmentMotionDir).listSync();
    List<String> fileNames = [];
    for (var element in stream) {
      FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
      if (type == FileSystemEntityType.directory) {
        fileNames.add(getFileName(element.path));
      }
    }
    if (fileNames.isEmpty) {
      return null;
    }
    segmentMotionDatas.add(XmagicUIProperty(
        uiCategory: Category.SEGMENTATION,
        displayName: AppLocalizations.of(context)!.noneLabel,
        id: XmagicProperty.ID_NONE,
        resPath: await _getNoneItemResPath(),
        thumbDrawableName: "naught"));
    Map map = BeautyDataManager.getMaterialDataByStr(
        AppLocalizations.of(context)!.segmentations);
    for (var filename in fileNames) {
      if (await exists(segmentMotionDir + filename)) {
        XmagicUIProperty uiProperty;
        if (filename == 'video_empty_segmentation') {
          uiProperty = XmagicUIProperty(
              effKey: filename,
              uiCategory: Category.SEGMENTATION,
              displayName:
                  AppLocalizations.of(context)!.segmentationCustomLabel,
              resPath: _getPropertyResPath(segmentMotionDir, filename),
              id: filename,
              thumbDrawableName: 'segmentation_formulate');
          segmentMotionDatas.insert(1, uiProperty);
        } else {
          uiProperty = XmagicUIProperty(
              uiCategory: Category.SEGMENTATION,
              displayName: map[filename],
              resPath: _getPropertyResPath(segmentMotionDir, filename),
              id: filename,
              thumbImagePath:
                  await _getThumbImagePath(segmentMotionDir, filename));
          segmentMotionDatas.add(uiProperty);
        }
      }
    }
    return segmentMotionDatas;
  }

  Future<String> _getThumbImagePath(String dirName, String id) async {
    return "$dirName$id${Platform.pathSeparator}template.png";
  }

  String _getPropertyResPath(String dirName, String id) {
    if (Platform.isAndroid) {
      return dirName + id;
    } else if (Platform.isIOS) {
      return dirName;
    }
    return "";
  }

  Future<String?> _getNoneItemResPath() async {
    if (Platform.isAndroid) {
      return "${await getResPath()}${Platform.pathSeparator}light_assets${Platform.pathSeparator}template.json";
    } else {
      return null;
    }
  }

  static String getFileName(String path) {
    List<String> items = path.split(Platform.pathSeparator);
    return items.last;
  }

  static Future<bool> exists(String path) async {
    FileSystemEntityType type = FileSystemEntity.typeSync(path);
    switch (type) {
      case FileSystemEntityType.file:
        return await File(path).exists();
      case FileSystemEntityType.directory:
        return await Directory(path).exists();
      default:
        return false;
    }
  }
}
