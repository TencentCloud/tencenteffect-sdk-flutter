
import '../constant/te_constant.dart';
import '../manager/res_path_manager.dart';
import '../model/te_ui_property.dart';

class ProducerUtils {
  static const String HTTP_NAME = "http";
  static const String ZIP_NAME = ".zip";

  static final List<String> BEAUTY_WHITEN_EFFECT_NAMES = [
    TEffectName.BEAUTY_WHITEN,
    TEffectName.BEAUTY_WHITEN_2,
    TEffectName.BEAUTY_WHITEN_3,
  ];

  static final List<String> BEAUTY_FACE_EFFECT_NAMES = [
    TEffectName.BEAUTY_FACE_NATURE,
    TEffectName.BEAUTY_FACE_GODNESS,
    TEffectName.BEAUTY_FACE_MALE_GOD,
  ];

  /// 创建 dlModel 和 SDKParam 并赋值到 TEUIProperty上
  ///
  /// @param teuiProperty
  /// @param uiCategory
  static void createDlModelAndSDKParam(
      TEUIProperty uiProperty, UICategory uiCategory) {
    switch (uiCategory) {
      case UICategory.LUT:
      case UICategory.MAKEUP:
      case UICategory.MOTION:
      case UICategory.SEGMENTATION:
        if (uiProperty.resourceUri != null &&
            uiProperty.resourceUri!.isNotEmpty) {
          //根据此项判断是具体的属性item
          String? downloadPath = ProducerUtils._getDownloadPath(uiProperty);
          if (uiProperty.resourceUri!.startsWith(HTTP_NAME)) {
            uiProperty.dlModel = TEMotionDLModel(
                downloadPath,
                getFileNameByHttpUrl(uiProperty.resourceUri!),
                uiProperty.resourceUri);
          }
          uiProperty.sdkParam ??= TESDKParam();
          if (uiProperty.resourceUri!.startsWith(HTTP_NAME)) {
            // 需要根据http地址计算出 本地的地址信息
            String? fileName = uiProperty.resourceUri != null
                ? getFileNameByHttpUrl(uiProperty.resourceUri!)
                : null;
            if (fileName != null && fileName.endsWith(ZIP_NAME)) {
              fileName = uiProperty.dlModel != null
                  ? uiProperty.dlModel!.getFileNameNoZip()
                  : null;
            }
            uiProperty.sdkParam?.resourcePath = downloadPath! + fileName!;
          } else {
            uiProperty.sdkParam?.resourcePath = uiProperty.resourceUri;
          }
        }
        break;
      default:
        break;
    }
  }

  /// 获取 downloadPath 地址
  /// @param teuiProperty
  /// @return
  static String? _getDownloadPath(TEUIProperty? uiProperty) {
    if (uiProperty == null) {
      return null;
    }
    if (uiProperty.downloadPath != null &&
        uiProperty.downloadPath!.isNotEmpty) {
      return uiProperty.downloadPath;
    } else {
      return ProducerUtils._getDownloadPath(uiProperty.parentUIProperty);
    }
  }

  static String? getFileNameByHttpUrl(String httpUrl) {
    if (httpUrl.isEmpty || !httpUrl.startsWith("http")) {
      return null;
    }
    String fileName;
    Uri uri = Uri.parse(httpUrl);
    fileName = uri.pathSegments.last;
    return fileName;
  }

  /// 补全资源路径
  ///
  /// @param uiProperty
  /// @return
  static void completionResPath(TEUIProperty? uiProperty) async {
    if (uiProperty == null) {
      return;
    }
    if (uiProperty.uiCategory == UICategory.BEAUTY ||
        uiProperty.uiCategory == UICategory.BODY_BEAUTY) {
      return;
    }
    StringBuffer stringBuffer = StringBuffer();

    if (uiProperty.sdkParam != null &&
        uiProperty.sdkParam!.resourcePath != null) {
      if (uiProperty.sdkParam!.resourcePath!
          .startsWith(ResPathManager.JSON_RES_MARK_LUT)) {
        stringBuffer.write(await ResPathManager.getResManager().getLutDir());
      } else if (uiProperty.sdkParam!.resourcePath!
          .startsWith(ResPathManager.JSON_RES_MARK_MAKEUP)) {
        stringBuffer.write(await ResPathManager.getResManager().getMakeUpDir());
      } else if (uiProperty.sdkParam!.resourcePath!
          .startsWith(ResPathManager.JSON_RES_MARK_MOTION_2D)) {
        stringBuffer
            .write(await ResPathManager.getResManager().getMotion2dDir());
      } else if (uiProperty.sdkParam!.resourcePath!
          .startsWith(ResPathManager.JSON_RES_MARK_MOTION_3D)) {
        stringBuffer
            .write(await ResPathManager.getResManager().getMotion3dDir());
      } else if (uiProperty.sdkParam!.resourcePath!
          .startsWith(ResPathManager.JSON_RES_MARK_MOTION_GAN)) {
        stringBuffer
            .write(await ResPathManager.getResManager().getMotionGanDir());
      } else if (uiProperty.sdkParam!.resourcePath!
          .startsWith(ResPathManager.JSON_RES_MARK_MOTION_GESTURE)) {
        stringBuffer
            .write(await ResPathManager.getResManager().getMotionGestureDir());
      } else if (uiProperty.sdkParam!.resourcePath!
          .startsWith(ResPathManager.JSON_RES_MARK_SEG)) {
        stringBuffer.write(await ResPathManager.getResManager().getSegDir());
      }
      stringBuffer.write(_getFileName(uiProperty.sdkParam!.resourcePath!));
      uiProperty.sdkParam!.resourcePath = stringBuffer.toString();
    }
  }

  static String _getFileName(String path) {
    String fileName;
    Uri uri = Uri.parse(path);
    fileName = uri.pathSegments.last;
    return fileName;
  }

  /// 修改父item的状态
  ///
  /// @param current 当前的TEUIProperty
  static void changeParentUIState(TEUIProperty current, int uiState) {
    TEUIProperty? parent = current.parentUIProperty;
    if (parent != null) {
      parent.setUiState(uiState);
      ProducerUtils.changeParentUIState(parent, uiState);
    }
  }

  /// 找到第一个UIState为IN_USE 的，将状态修改为 CHECKED_AND_IN_USE
  ///
  /// @param allData
  /// @return
  static bool findFirstInUseItemAndMakeChecked(List<TEUIProperty>? allData) {
    if (allData == null) {
      return false;
    }
    for (TEUIProperty uiProperty in allData) {
      if (uiProperty.propertyList != null) {
        if (findFirstInUseItemAndMakeChecked(uiProperty.propertyList)) {
          return true;
        }
      } else if (uiProperty.sdkParam != null &&
          uiProperty.getUiState() == UIState.IN_USE) {
        uiProperty.setUiState(UIState.CHECKED_AND_IN_USE);
        ProducerUtils.changeParentUIState(
            uiProperty, UIState.CHECKED_AND_IN_USE);
        return true;
      }
    }
    return false;
  }

  static List<TESDKParam> getUsedProperties(List<TEUIProperty> uiProperties) {
    List<TESDKParam> usedProperties = [];
    _getUsedProperties(uiProperties, usedProperties);
    return usedProperties;
  }

  /// 获取列表中UIState 的值不为初始值并且teParam不为null的数据，
  ///
  /// @param uiProperties
  /// @param properties
  static void _getUsedProperties(
      List<TEUIProperty> uiProperties, List<TESDKParam> properties) {
    if (uiProperties.isNotEmpty) {
      for (TEUIProperty? uiProperty in uiProperties) {
        if (uiProperty == null) {
          continue;
        }
        if (uiProperty.getUiState() != UIState.INIT &&
            uiProperty.sdkParam != null) {
          properties.add(uiProperty.sdkParam!);
        }
        if (uiProperty.propertyList != null) {
          _getUsedProperties(uiProperty.propertyList!, properties);
        }
      }
    }
  }

  /// 创建一个用于关闭 滤镜、美妆、动效、分割 的素材
  ///
  /// @param effectName
  /// @return
  static TESDKParam createNoneItem(String effectName) {
    TESDKParam param = TESDKParam();
    param.effectName = effectName;
    return param;
  }

  /// 将属性值 修改为0，用于美颜 美体属性
  /// @param usedList
  static void changParamValuedTo0(List<TESDKParam>? usedList) {
    if (usedList == null) {
      return;
    }
    for (TESDKParam param in usedList) {
      param.effectValue = 0;
    }
  }

  /// 根据使用获得teParam clone一份新的param,并将effectValue设置为0
  ///
  /// @param usedList 正在生效的teParam 列表
  /// @return
  static List<TESDKParam>? clone0ValuedParam(List<TESDKParam>? usedList) {
    if (usedList == null) {
      return null;
    }
    List<TESDKParam> resultList = [];
    for (TESDKParam param in usedList) {
      TESDKParam cloneParam = TESDKParam();
      cloneParam.effectName = param.effectName;
      cloneParam.effectValue = 0;
      cloneParam.resourcePath = param.resourcePath;
      if (param.extraInfo != null && param.extraInfo!.isNotEmpty) {
        Map<String, String> newExtraInfo = {};
        Iterable<MapEntry<String, String>> iterable = param.extraInfo!.entries;
        for (MapEntry<String, String> item in iterable) {
          newExtraInfo[item.key] = item.value;
        }
        cloneParam.extraInfo = newExtraInfo;
      }
      resultList.add(cloneParam);
    }
    return resultList;
  }

  /// 将美颜属性的UI状态进行还原处理
  ///
  /// @param uiPropertyList
  static void revertUIState(
      List<TEUIProperty>? uiPropertyList, TEUIProperty currentItem) {
    if (uiPropertyList == null) {
      return;
    }
    for (TEUIProperty? property in uiPropertyList) {
      if (property == null) {
        continue;
      }
      ProducerUtils.revertUIState(property.propertyList, currentItem);

      if (property.getUiState() == UIState.INIT) {
        continue;
      }
      if (property.uiCategory == UICategory.BEAUTY ||
          property.uiCategory == UICategory.BODY_BEAUTY) {
        if (isSameEffectName(property, currentItem)) {
          changeParamUIState(property, UIState.INIT);
        } else {
          changeParamUIState(property, UIState.IN_USE);
        }
      } else {
        changeParamUIState(property, UIState.INIT);
      }
    }
  }

  static bool isSameEffectName(
      TEUIProperty? property, TEUIProperty? property2) {
    if (property == null || property2 == null) {
      return false;
    }
    if (property.sdkParam == null || property2.sdkParam == null) {
      return false;
    }
    if (property.sdkParam!.effectName == property2.sdkParam!.effectName) {
      return true;
    }
    if (ProducerUtils.contains(
            BEAUTY_WHITEN_EFFECT_NAMES, property.sdkParam!.effectName) &&
        ProducerUtils.contains(
            BEAUTY_WHITEN_EFFECT_NAMES, property2.sdkParam!.effectName)) {
      return true;
    }
    if (ProducerUtils.contains(
            BEAUTY_FACE_EFFECT_NAMES, property.sdkParam!.effectName) &&
        ProducerUtils.contains(
            BEAUTY_FACE_EFFECT_NAMES, property2.sdkParam!.effectName)) {
      return true;
    }
    return false;
  }

  static bool contains(List<String> names, String? effectName) {
    for (String name in names) {
      if (name == effectName) {
        return true;
      }
    }
    return false;
  }

  /// 修改 uiState
  ///
  /// @param teuiProperty
  static void changeParamUIState(TEUIProperty? teuiProperty, int uiState) {
    if (teuiProperty == null) {
      return;
    }
    teuiProperty.setUiState(uiState);
    ProducerUtils.changeParamUIState(teuiProperty.parentUIProperty, uiState);
  }
}
