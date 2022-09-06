import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_effect_flutter/model/beauty_constant.dart';
import 'package:tencent_effect_flutter/model/xmagic_property.dart';
import 'package:tencent_effect_flutter_demo/languages/AppLocalizations.dart';
import 'package:tencent_effect_flutter_demo/producer/beauty_property_producer.dart';

class BeautyPropertyProducerAndroid extends BeautyPropertyProducer {
  @override
  Future<List<XmagicUIProperty>> getBeautyData(BuildContext context) async {
    String effDirs =
        "${await getResPath()}${Platform.pathSeparator}light_assets${Platform.pathSeparator}images${Platform.pathSeparator}beauty${Platform.pathSeparator}";

    String resPaths =
        "${Platform.pathSeparator}images${Platform.pathSeparator}beauty${Platform.pathSeparator}";
    Map<String, String> effs = {};
    List<FileSystemEntity> stream = Directory(effDirs).listSync();
    if (stream.isNotEmpty) {
      for (var element in stream) {
        FileSystemEntityType type = FileSystemEntity.typeSync(element.path);
        if (type == FileSystemEntityType.file) {
          effs[BeautyPropertyProducer.getFileName(element.path)] = element.path;
        }
      }
    }

    XmagicUIProperty xmagicUIProperty = XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyWhitenLabel,
        thumbDrawableName: "beauty_whiten",
        effKey: BeautyConstant.BEAUTY_WHITEN,
        effValue: XmagicPropertyValues(0, 100, 30, 0, 1));
    List<XmagicUIProperty> beautyList = [];
    beautyList.add(xmagicUIProperty);
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautySmoothLabel,
        thumbDrawableName: "beauty_smooth",
        effKey: BeautyConstant.BEAUTY_SMOOTH,
        effValue: XmagicPropertyValues(0, 100, 50, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyRuddyLabel,
        thumbDrawableName: "beauty_ruddy",
        effKey: BeautyConstant.BEAUTY_ROSY,
        effValue: XmagicPropertyValues(0, 100, 20, 0, 2)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.imageContrastLabel,
        thumbDrawableName: "image_contrast",
        effKey: BeautyConstant.BEAUTY_CONTRAST,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.imageSaturationLabel,
        thumbDrawableName: "image_saturation",
        effKey: BeautyConstant.BEAUTY_SATURATION,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.imageSharpenLabel,
        thumbDrawableName: "image_sharpen",
        effKey: BeautyConstant.BEAUTY_CLEAR,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 2)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyEnlargeeyeLabel,
        thumbDrawableName: "beauty_enlarge_eye",
        effKey: BeautyConstant.BEAUTY_ENLARGE_EYE,
        effValue: XmagicPropertyValues(0, 100, 20, 0, 1)));

    String? thinFaceLabel =
        AppLocalizations.of(context)!.beautyThinFaceLabel;
    XmagicUIProperty thinFace = XmagicUIProperty(
        displayName: thinFaceLabel,
        thumbDrawableName: "beauty_thin_face",
        uiCategory: Category.BEAUTY);
    beautyList.add(thinFace);
    List<XmagicUIProperty> slList = [];
    slList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyThinFace1Label,
        id: BeautyConstant.BEAUTY_FACE_NATURE_ID,
        resPath: null,
        thumbDrawableName: "beauty_thin_face1",
        effKey: BeautyConstant.BEAUTY_FACE_NATURE,
        effValue: XmagicPropertyValues(0, 100, 30, 0, 1),
        rootDisplayName: thinFaceLabel));
    slList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyThinFace2Label,
        id: BeautyConstant.BEAUTY_FACE_FEMALE_GOD_ID,
        thumbDrawableName: "beauty_thin_face2",
        effKey: BeautyConstant.BEAUTY_FACE_GODNESS,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1),
        rootDisplayName: thinFaceLabel));
    slList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyThinFace3Label,
        id: BeautyConstant.BEAUTY_FACE_MALE_GOD_ID,
        thumbDrawableName: "beauty_thin_face3",
        effKey: BeautyConstant.BEAUTY_FACE_MALE_GOD,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1),
        rootDisplayName: thinFaceLabel));
    thinFace.xmagicUIPropertyList = slList;

    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyVFaceLabel,
        thumbDrawableName: "beauty_v_face",
        effKey: BeautyConstant.BEAUTY_FACE_V,
        effValue: XmagicPropertyValues(0, 100, 30, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyNarrowFaceLabel,
        thumbDrawableName: "beauty_narrow_face",
        effKey: BeautyConstant.BEAUTY_FACE_THIN,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyShortFaceLabel,
        thumbDrawableName: "beauty_short_face",
        effKey: BeautyConstant.BEAUTY_FACE_SHORT,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyBasicFaceLabel,
        thumbDrawableName: "beauty_basic_face",
        effKey: BeautyConstant.BEAUTY_FACE_BASIC,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));

    Map<String, String?> lipsResPathNames = {};
    lipsResPathNames["lips_fuguhong.png"] =
        AppLocalizations.of(context)!.beautyLips1Label;
    lipsResPathNames["lips_mitaose.png"] =
        AppLocalizations.of(context)!.beautyLips2Label;
    lipsResPathNames["lips_shanhuju.png"] =
        AppLocalizations.of(context)!.beautyLips3Label;
    lipsResPathNames["lips_wenroufen.png"] =
        AppLocalizations.of(context)!.beautyLips4Label;
    lipsResPathNames["lips_huolicheng.png"] =
        AppLocalizations.of(context)!.beautyLips5Label;
    List<XmagicUIProperty> itemLipsPropertys = [];
    for (String ids in lipsResPathNames.keys) {
      itemLipsPropertys.add(XmagicUIProperty(
          uiCategory: Category.BEAUTY,
          displayName: lipsResPathNames[ids]!,
          id: BeautyConstant.BEAUTY_LIPS_LIPS_MASK_ID,
          resPath: resPaths + ids,
          thumbDrawableName: "beauty_lips",
          effKey: BeautyConstant.BEAUTY_MOUTH_LIPSTICK,
          effValue: XmagicPropertyValues(0, 100, 50, 0, 1),
          rootDisplayName: AppLocalizations.of(context)!.beautyLipsLabel));
    }
    XmagicUIProperty itemLips = XmagicUIProperty(
        displayName: AppLocalizations.of(context)!.beautyLipsLabel,
        thumbDrawableName: "beauty_lips",
        uiCategory: Category.BEAUTY);
    itemLips.xmagicUIPropertyList = itemLipsPropertys;
    beautyList.add(itemLips);

    Map<String, String?> redcheeksResPathNames = {};
    redcheeksResPathNames["saihong_jianyue.png"] =
        AppLocalizations.of(context)!.beautyRedcheeks1Label;
    redcheeksResPathNames["saihong_shengxia.png"] =
        AppLocalizations.of(context)!.beautyRedcheeks2Label;
    redcheeksResPathNames["saihong_haixiu.png"] =
        AppLocalizations.of(context)!.beautyRedcheeks3Label;
    redcheeksResPathNames["saihong_chengshu.png"] =
        AppLocalizations.of(context)!.beautyRedcheeks4Label;
    redcheeksResPathNames["saihong_queban.png"] =
        AppLocalizations.of(context)!.beautyRedcheeks5Label;

    List<XmagicUIProperty> itemRedcheekPropertys = [];
    for (String ids in redcheeksResPathNames.keys) {
      itemRedcheekPropertys.add(XmagicUIProperty(
          uiCategory: Category.BEAUTY,
          displayName: redcheeksResPathNames[ids]!,
          id: BeautyConstant.BEAUTY_MAKEUP_MULTIPLY_MULTIPLY_MASK_ID,
          resPath: resPaths + ids,
          thumbDrawableName: "beauty_redcheeks",
          effKey: BeautyConstant.BEAUTY_FACE_RED_CHEEK,
          effValue: XmagicPropertyValues(0, 100, 50, 0, 1),
          rootDisplayName:
              AppLocalizations.of(context)!.beautyRedcheeksLabel));
    }
    XmagicUIProperty itemRedcheeks = XmagicUIProperty(
        displayName: AppLocalizations.of(context)!.beautyRedcheeksLabel,
        thumbDrawableName: "beauty_redcheeks",
        uiCategory: Category.BEAUTY);
    itemRedcheeks.xmagicUIPropertyList = itemRedcheekPropertys;
    beautyList.add(itemRedcheeks);

    Map<String, String?> litisResPathNames = {};
    litisResPathNames["liti_ziran.png"] =
        AppLocalizations.of(context)!.beautyLiti1Label;
    litisResPathNames["liti_junlang.png"] =
        AppLocalizations.of(context)!.beautyLiti2Label;
    litisResPathNames["liti_guangmang.png"] =
        AppLocalizations.of(context)!.beautyLiti3Label;
    litisResPathNames["liti_qingxin.png"] =
        AppLocalizations.of(context)!.beautyLiti4Label;

    List<XmagicUIProperty> liTiItems = [];
    for (String ids in litisResPathNames.keys) {
      liTiItems.add(XmagicUIProperty(
          uiCategory: Category.BEAUTY,
          displayName: litisResPathNames[ids]!,
          id: BeautyConstant.BEAUTY_SOFTLIGHT_SOFTLIGHT_MASK_ID,
          resPath: resPaths + ids,
          thumbDrawableName: "beauty_liti",
          effKey: BeautyConstant.BEAUTY_FACE_SOFTLIGHT,
          effValue: XmagicPropertyValues(0, 100, 50, 0, 1),
          rootDisplayName: AppLocalizations.of(context)!.beautyLitiLabel));
    }
    XmagicUIProperty itemLitis = XmagicUIProperty(
        displayName: AppLocalizations.of(context)!.beautyLitiLabel,
        thumbDrawableName: "beauty_liti",
        uiCategory: Category.BEAUTY);
    itemLitis.xmagicUIPropertyList = liTiItems;
    beautyList.add(itemLitis);

    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyThinCheekLabel,
        thumbDrawableName: "beauty_thin_cheek",
        effKey: BeautyConstant.BEAUTY_FACE_THIN_CHEEKBONE,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyChinLabel,
        thumbDrawableName: "beauty_chin",
        effKey: BeautyConstant.BEAUTY_FACE_THIN_CHIN,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyForeheadLabel,
        thumbDrawableName: "beauty_forehead",
        effKey: BeautyConstant.BEAUTY_FACE_FOREHEAD,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyEyeLightenLabel,
        thumbDrawableName: "beauty_eye_lighten",
        effKey: BeautyConstant.BEAUTY_EYE_LIGHTEN,
        effValue: XmagicPropertyValues(0, 100, 30, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyEyeDistanceLabel,
        thumbDrawableName: "beauty_eye_distance",
        effKey: BeautyConstant.BEAUTY_EYE_DISTANCE,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyEyeAngleLabel,
        thumbDrawableName: "beauty_eye_angle",
        effKey: BeautyConstant.BEAUTY_EYE_ANGLE,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyThinNoseLabel,
        thumbDrawableName: "beauty_thin_nose",
        effKey: BeautyConstant.BEAUTY_NOSE_THIN,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyNoseWingLabel,
        thumbDrawableName: "beauty_nose_wing",
        effKey: BeautyConstant.BEAUTY_NOSE_WING,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyNosePositionLabel,
        thumbDrawableName: "beauty_nose_position",
        effKey: BeautyConstant.BEAUTY_NOSE_HEIGHT,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyToothBeautyLabel,
        thumbDrawableName: "beauty_tooth_beauty",
        effKey: BeautyConstant.BEAUTY_TOOTH_WHITEN,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyRemovePounchLabel,
        thumbDrawableName: "beauty_remove_pounch",
        effKey: BeautyConstant.BEAUTY_FACE_REMOVE_WRINKLE,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyWrinkleSmoothLabel,
        thumbDrawableName: "beauty_wrinkle_smooth",
        effKey: BeautyConstant.BEAUTY_FACE_REMOVE_LAW_LINE,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName:
            AppLocalizations.of(context)!.beautyRemoveEyePouchLabel,
        thumbDrawableName: "beauty_remove_eye_pouch",
        effKey: BeautyConstant.BEAUTY_FACE_REMOVE_EYE_BAGS,
        effValue: XmagicPropertyValues(0, 100, 0, 0, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautyLipShapeLabel,
        thumbDrawableName: "beauty_mouth_size",
        effKey: BeautyConstant.BEAUTY_MOUTH_SIZE,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));
    beautyList.add(XmagicUIProperty(
        uiCategory: Category.BEAUTY,
        displayName: AppLocalizations.of(context)!.beautylipHeightLabel,
        thumbDrawableName: "beauty_mouth_height",
        effKey: BeautyConstant.BEAUTY_MOUTH_HEIGHT,
        effValue: XmagicPropertyValues(-100, 100, 0, -1, 1)));

    return beautyList;
  }

  @override
  Future<String> getLutDir() async {
    return "${await getResPath()}${Platform.pathSeparator}light_material${Platform.pathSeparator}lut${Platform.pathSeparator}";
  }

  @override
  Future<String> getMakeUpDir() async {
    return "${await getResPath()}${Platform.pathSeparator}MotionRes${Platform.pathSeparator}makeupRes${Platform.pathSeparator}";
  }

  @override
  Future<String> getMotion2dDir() async {
    return "${await getResPath()}${Platform.pathSeparator}MotionRes${Platform.pathSeparator}2dMotionRes${Platform.pathSeparator}";
  }

  @override
  Future<String> getMotion3dDir() async {
    return "${await getResPath()}${Platform.pathSeparator}MotionRes${Platform.pathSeparator}3dMotionRes${Platform.pathSeparator}";
  }

  @override
  Future<String> getMotionganDir() async {
    return "${await getResPath()}${Platform.pathSeparator}MotionRes${Platform.pathSeparator}ganMotionRes${Platform.pathSeparator}";
  }

  @override
  Future<String> getMotionhandDir() async {
    return "${await getResPath()}${Platform.pathSeparator}MotionRes${Platform.pathSeparator}handMotionRes${Platform.pathSeparator}";
  }

  @override
  Future<String> getResPath() async {
    Directory directory = await getApplicationSupportDirectory();
    return directory.path + "${Platform.pathSeparator}xmagic";
  }

  @override
  Future<String> getSegDir() async {
    return "${await getResPath()}${Platform.pathSeparator}MotionRes${Platform.pathSeparator}segmentMotionRes${Platform.pathSeparator}";
  }
}
