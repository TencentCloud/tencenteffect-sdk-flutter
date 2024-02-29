import 'dart:io';


import 'package:tencent_effect_flutter_demo/model/te_json_decoder.dart';

import '../constant/te_constant.dart';

class TEUIProperty {
  String? displayName; //中文名称
  String? displayNameEn; //英文名称
  String? icon; //图标
  String? resourceUri; //如果此资源是本地集成，则在这里配置本地资源路径，如果是网络下载，那么这里配置资源的下载地址
  String? downloadPath; //对于网络下载的资源，在本地保存的文件夹路径

  List<TEUIProperty>? propertyList;
  TESDKParam? sdkParam;

  TEUIProperty? parentUIProperty;
  UICategory? uiCategory;
  TEMotionDLModel? dlModel;

  int uiState = 0;

  int getUiState() {
    return uiState;
  }

  void setUiState(int uiState) {
    this.uiState = uiState;
  }

  TEUIProperty(
      this.displayName,
      this.displayNameEn,
      this.icon,
      this.resourceUri,
      this.downloadPath,
      this.propertyList,
      this.sdkParam,
      this.uiState);

  bool isNoneItem() {
    return (sdkParam == null && propertyList == null);
  }

  TEUIProperty.fromJson(Map<String, dynamic> json) {
    displayName = json['displayName'];
    displayNameEn = json['displayNameEn'];
    icon = json['icon'];
    resourceUri = json['resourceUri'];
    downloadPath = json['downloadPath'];
    propertyList = TEJsonDecoder.decodeTEUIPropertyList(json['propertyList']);
    Map<String, dynamic>? tempSdkParam = json['sdkParam'];
    sdkParam = tempSdkParam != null ? TESDKParam.fromJson(tempSdkParam) : null;
    var tempState = json['uiState'];
    if (tempState != null) {
      uiState = tempState;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['displayName'] = displayName;
    data['displayNameEn'] = displayNameEn;
    data['icon'] = icon;
    data['resourceUri'] = resourceUri;
    data['downloadPath'] = downloadPath;
    data['propertyList'] = propertyList?.map((e) => e.toJson()).toList();
    data['sdkParam'] = sdkParam?.toJson();
    data['uiState'] = uiState;
    return data;
  }
}

class TESDKParam {
  //图片类型数据
  static const String EXTRA_INFO_BG_TYPE_IMG = "0";

  //视频类型数据
  static const String EXTRA_INFO_BG_TYPE_VIDEO = "1";

  //seg_type的值，如果是自定义分割就是用：EXTRA_INFO_SEG_TYPE_CUSTOM ，绿幕就使用 EXTRA_INFO_SEG_TYPE_GREEN
  static const String EXTRA_INFO_SEG_TYPE_GREEN = "green_background";
  static const String EXTRA_INFO_SEG_TYPE_CUSTOM = "custom_background";

  static const String EXTRA_INFO_KEY_BG_TYPE = "bgType";
  static const String EXTRA_INFO_KEY_BG_PATH = "bgPath";
  static const String EXTRA_INFO_KEY_SEG_TYPE = "segType";
  static const String EXTRA_INFO_KEY_KEY_COLOR = "keyColor";
  static const String EXTRA_INFO_KEY_MERGE_WITH_CURRENT_MOTION =
      "mergeWithCurrentMotion";
  static const String EXTRA_INFO_KEY_LUT_STRENGTH = "makeupLutStrength";

  String? effectName;
  int effectValue = 0;
  String? resourcePath;
  Map<String, String>? extraInfo;

  TESDKParam(
      {this.effectName,
      this.effectValue = 0,
      this.resourcePath,
      this.extraInfo});

  TESDKParam.fromJson(Map<String, dynamic> json) {
    effectName = json['effectName'];
    effectValue = json['effectValue'] ?? 0;
    resourcePath = json['resourcePath'];

    Map<String, dynamic>? tempExtraInfo = json['extraInfo'];
    if (tempExtraInfo != null) {
      extraInfo = tempExtraInfo.cast<String, String>();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['effectName'] = effectName;
    data['effectValue'] = effectValue;
    data['resourcePath'] = resourcePath;
    data['extraInfo'] = extraInfo;
    return data;
  }
}

enum UICategory {
  BEAUTY,
  BODY_BEAUTY,
  LUT,
  MOTION,
  MAKEUP,
  SEGMENTATION,
}

class UIState {
  static const int CHECKED_AND_IN_USE = 2; //正在生效，并且UI上是选中的     CHECKED_IN_USE
  static const int IN_USE = 1; //正在生效的美颜属性，但是UI上是没有选中的，   IN_USE
  static const int INIT = 0; //未选中状态
}

class TEMotionDLModel {
  String? localDir;
  String? fileName;
  String? url;

  String? getLocalDir() {
    return localDir;
  }

  void setLocalDir(String? _localDir) {
    if (_localDir == null) {
      return;
    }
    localDir = _localDir;
    if (localDir!.startsWith(Platform.pathSeparator, 0)) {
      localDir = localDir?.replaceFirst(Platform.pathSeparator, "");
    }
    if (localDir!.endsWith(Platform.pathSeparator)) {
      localDir = localDir?.substring(0, localDir!.length - 1);
    }
  }

  String? getFileName() {
    return fileName;
  }

  String? getFileNameNoZip() {
    if (fileName != null && fileName!.endsWith(".zip")) {
      return fileName!.substring(0, fileName!.length - ".zip".length);
    }
    return fileName;
  }

  void setFileName(String _fileName) {
    fileName = _fileName;
  }

  String? getUrl() {
    return url;
  }

  void setUrl(String _url) {
    url = _url;
  }

  TEMotionDLModel(String? _localDir, String? _fileName, String? _url) {
    setLocalDir(_localDir);
    fileName = _fileName;
    url = _url;
  }
}

class EffectValueType {
  final int min;
  final int max;

  const EffectValueType(this.min, this.max);

  static const RANGE_0_0 = EffectValueType(0, 0);
  static const RANGE_0_POS100 = EffectValueType(0, 100);
  static const RANGE_NEG100_POS100 = EffectValueType(-100, 100);

  int getMin() {
    return min;
  }

  int getMax() {
    return max;
  }

  /// 用于存储特效属性对应的取值变化的map
  static const Map<String, EffectValueType> VALUE_TYPE_MAP = {
    TEffectName.EFFECT_MOTION:
      EffectValueType.RANGE_0_0,
    TEffectName.EFFECT_SEGMENTATION:
    EffectValueType.RANGE_0_0,

    TEffectName.BEAUTY_CONTRAST:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_SATURATION:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_IMAGE_WARMTH:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_IMAGE_TINT:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYE_DISTANCE:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYE_ANGLE:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYE_WIDTH:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYE_HEIGHT:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYEBROW_ANGLE:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYEBROW_DISTANCE:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYEBROW_HEIGHT:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYEBROW_LENGTH:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYEBROW_THICKNESS:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_EYEBROW_RIDGE:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_NOSE_WING:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_NOSE_HEIGHT:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_NOSE_BRIDGE_WIDTH:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_NASION:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_MOUTH_SIZE:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_MOUTH_HEIGHT:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_MOUTH_WIDTH:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_MOUTH_POSITION:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_SMILE_FACE:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_FACE_THIN_CHIN:
    EffectValueType.RANGE_NEG100_POS100,
    TEffectName.BEAUTY_FACE_FOREHEAD:
    EffectValueType.RANGE_NEG100_POS100,

    TEffectName.BODY_ENLARGE_CHEST_STRENGTH:EffectValueType.RANGE_NEG100_POS100
    //胸部调整
  };

  static EffectValueType getEffectValueType(TESDKParam teParam) {
    EffectValueType? type = VALUE_TYPE_MAP[teParam.effectName];
    if (type != null) {
      return type;
    } else {
      return EffectValueType.RANGE_0_POS100;
    }
  }
}
