import 'dart:core';
import '../model/te_panel_data_model.dart';
import '../model/te_ui_property.dart';

class TEResConfig {
  List<TEPanelDataModel> defaultPanelDataList = [];

  TEResConfig._internal();

  static TEResConfig? resConfig;

  static TEResConfig getConfig() {
    resConfig ??= TEResConfig._internal();
    return resConfig!;
  }

  /// 设置美颜资源路径
  ///
  /// @param resourcePath 资源路径
  /// @return
  void setBeautyRes(String resourcePath) {
    defaultPanelDataList.add(TEPanelDataModel(resourcePath, UICategory.BEAUTY));
  }

  /// 设置美体美颜资源路径
  /// @param resourcePath 资源路径
  /// @return
  void setBeautyBodyRes(String resourcePath) {
    defaultPanelDataList
        .add(TEPanelDataModel(resourcePath, UICategory.BODY_BEAUTY));
  }

  /// 设置LUT资源路径
  /// @param resourcePath 资源路径
  /// @return
  void setLutRes(String resourcePath) {
    defaultPanelDataList.add(TEPanelDataModel(resourcePath, UICategory.LUT));
  }

  /// 设置美妆资源路径
  /// @param resourcePath 资源路径
  /// @return
  void setMakeUpRes(String resourcePath) {
    defaultPanelDataList.add(TEPanelDataModel(resourcePath, UICategory.MAKEUP));
  }

  /// 设置动效美颜资源路径
  /// @param resourcePath 资源路径
  /// @return
  void setMotionRes(String resourcePath) {
    defaultPanelDataList.add(TEPanelDataModel(resourcePath, UICategory.MOTION));
  }

  /// 设置分割美颜资源路径
  /// @param resourcePath 资源路径
  /// @return
  void setSegmentationRes(String resourcePath) {
    defaultPanelDataList
        .add(TEPanelDataModel(resourcePath, UICategory.SEGMENTATION));
  }

  List<TEPanelDataModel> getPanelDataList() {
    return defaultPanelDataList;
  }
}
