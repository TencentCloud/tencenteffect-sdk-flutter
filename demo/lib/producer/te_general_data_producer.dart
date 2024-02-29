import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_effect_flutter_demo/producer/te_panel_data_producer.dart';

import '../constant/te_constant.dart';
import '../manager/te_param_manager.dart';
import '../model/te_panel_data_model.dart';
import '../model/te_ui_property.dart';
import '../utils/producer_utils.dart';


class TEGeneralDataProducer implements TEPanelDataProducer {
  List<TEPanelDataModel>? _panelDataList;
  List<TEUIProperty> _allData = [];
  List<TESDKParam> _originalParamList = [];
    final Map<UICategory, TEUIProperty> _dataCategory = {};


  /// 用于存储TEParam.effectName和TEUIProperty的对应关系
  final Map<String, TEUIProperty> _uiPropertyIndexByNameMap =
      HashMap<String, TEUIProperty>();

  @override
  void setPanelDataList(List<TEPanelDataModel> panelDataList) {
    _panelDataList = panelDataList;
  }

  @override
  void setUsedParams(List<TESDKParam> paramList) {
    _originalParamList = paramList;
  }

  @override
  Future<List<TEUIProperty>> getPanelData() async {
    if (_allData.isNotEmpty) {
      return _allData;
    }
    _allData = await forceRefreshPanelData();
    return _allData;
  }

  @override
  Future<List<TEUIProperty>> forceRefreshPanelData() async {
    List<TEUIProperty> result = [];
    _uiPropertyIndexByNameMap.clear();
    _dataCategory.clear();
    for (var dataModel in _panelDataList!) {
      final jsonString = await rootBundle.loadString(dataModel.jsonFilePath!);
      Map<String, dynamic> map = json.decode(jsonString);
      TEUIProperty uiProperty = TEUIProperty.fromJson(map);
      uiProperty.uiCategory = dataModel.category;
      if (uiProperty.propertyList != null) {
        _completionParam(
            uiProperty.propertyList!, dataModel.category, uiProperty);
      }
      _putDataToMap(uiProperty);
      result.add(uiProperty);
      _dataCategory[dataModel.category] = uiProperty;
    }

    syncUIState();
    return result;
  }

  void _completionParam(List<TEUIProperty> list, UICategory category,
      TEUIProperty parentProperty) {
    for (TEUIProperty property in list) {
      property.parentUIProperty = parentProperty;
      property.uiCategory = category; //设置category
      ProducerUtils.createDlModelAndSDKParam(property, category);
      if (property.sdkParam != null) {
        //设置effectName
        switch (category) {
          case UICategory.LUT:
            property.sdkParam!.effectName = TEffectName.EFFECT_LUT;
            break;
          case UICategory.MAKEUP:
            property.sdkParam!.effectName = TEffectName.EFFECT_MAKEUP;
            break;
          case UICategory.MOTION:
            property.sdkParam!.effectName = TEffectName.EFFECT_MOTION;
            break;
          case UICategory.SEGMENTATION:
            property.sdkParam!.effectName = TEffectName.EFFECT_SEGMENTATION;
            break;
          default:
            break;
        }
      }
      ProducerUtils.completionResPath(property); //补全路径
      _putDataToMap(property);
      if (property.propertyList != null) {
        _completionParam(property.propertyList!, category, property);
      }
    }
  }

  /// 将数据添加到对应的map中
  ///
  /// @param property
  void _putDataToMap(TEUIProperty property) {
    if (_originalParamList.isEmpty) {
      return;
    }
    property.setUiState(UIState.INIT); //去除JSON文件中设置的UI状态
    if (property.sdkParam != null) {
      _uiPropertyIndexByNameMap[_getNameMapKey(property.sdkParam!)] = property;
    }
  }

  String _getNameMapKey(TESDKParam param) {
    StringBuffer keyBuilder = StringBuffer();
    if (param.effectName != null && param.effectName!.isNotEmpty) {
      keyBuilder.write(param.effectName);
    }
    if (param.resourcePath != null && param.resourcePath!.isNotEmpty) {
      keyBuilder.write(param.resourcePath);
    }
    return keyBuilder.toString();
  }

  /// 同步UI状态
  void syncUIState() {
    if (_originalParamList.isEmpty) {
      return;
    }
    for (TESDKParam param in _originalParamList) {
      //先假设此数据是 美颜或者美体，通过effectName进行查询
      TEUIProperty? teuiProperty =
          _uiPropertyIndexByNameMap[_getNameMapKey(param)];
      //表示查询到了
      if (teuiProperty != null) {
        teuiProperty.sdkParam!.effectValue = param.effectValue;
        if (teuiProperty.uiCategory == UICategory.BEAUTY ||
            teuiProperty.uiCategory == UICategory.BODY_BEAUTY) {
          teuiProperty.setUiState(UIState.IN_USE);
          ProducerUtils.changeParentUIState(teuiProperty, UIState.IN_USE);
        } else {
          teuiProperty.setUiState(UIState.CHECKED_AND_IN_USE);
          ProducerUtils.changeParentUIState(
              teuiProperty, UIState.CHECKED_AND_IN_USE);
        }
      }
    }
    List<TEUIProperty> allBeautyPropertyList = [];
    for (TEUIProperty teuiProperty in _allData) {
      if (teuiProperty.uiCategory == UICategory.BODY_BEAUTY &&
          teuiProperty.propertyList != null) {
        ProducerUtils.findFirstInUseItemAndMakeChecked(
            teuiProperty.propertyList);
      }
      if (teuiProperty.uiCategory == UICategory.BEAUTY) {
        allBeautyPropertyList.add(teuiProperty);
      }
    }
    if (allBeautyPropertyList.isNotEmpty) {
      ProducerUtils.findFirstInUseItemAndMakeChecked(allBeautyPropertyList);
    }
  }

  @override
  List<TESDKParam>? getCloseEffectItems(TEUIProperty uiProperty) {
    //根据UICategory 判断类型  然后进行处理
    switch (uiProperty.uiCategory) {
      case UICategory.BEAUTY:
      case UICategory.BODY_BEAUTY:
        TEUIProperty? currentProperty = _dataCategory[uiProperty.uiCategory];
        if (currentProperty != null) {
          List<TESDKParam> usedList = ProducerUtils.getUsedProperties(currentProperty.propertyList!);
          ProducerUtils.changParamValuedTo0(usedList);
          return usedList;
        }
        break;
      case UICategory.LUT:
        return [ProducerUtils.createNoneItem(TEffectName.EFFECT_LUT)];
      case UICategory.MAKEUP:
      case UICategory.MOTION:
      case UICategory.SEGMENTATION:
        return [ProducerUtils.createNoneItem(TEffectName.EFFECT_MOTION)];
    }
    return null;
  }

  @override
  List<TESDKParam> getRevertData() {
    //获取使用的item
    List<TESDKParam> usedList = ProducerUtils.getUsedProperties(_allData);
    bool hasLut = false;
    bool hasMotion = false;
    for (TESDKParam param in usedList) {
      if (identical(param.effectName,TEffectName.EFFECT_LUT)) {
        hasLut = true;
      }
      if (param.effectName == TEffectName.EFFECT_MAKEUP
          || param.effectName == TEffectName.EFFECT_MOTION
          || param.effectName == TEffectName.EFFECT_SEGMENTATION) {
        hasMotion = true;
      }
    }

    //从新获取数据
    forceRefreshPanelData();
    //获取默认的选中项
    List<TESDKParam> defaultUsedList = ProducerUtils.getUsedProperties(_allData);

    for (TESDKParam param in defaultUsedList) {
      if (identical(param.effectName, TEffectName.EFFECT_LUT)) {
        hasLut = false;
      }
      if (param.effectName == TEffectName.EFFECT_MAKEUP
          || param.effectName == TEffectName.EFFECT_MOTION
          || param.effectName == TEffectName.EFFECT_SEGMENTATION) {
        hasMotion = false;
      }
    }

    TEParamManager paramManager = TEParamManager();
    paramManager.putTEParams(ProducerUtils.clone0ValuedParam(usedList));
    paramManager.putTEParams(defaultUsedList);
    if (hasLut) {
      paramManager.putTEParam(ProducerUtils.createNoneItem(TEffectName.EFFECT_LUT));
    }
    if (hasMotion) {
      paramManager.putTEParam(ProducerUtils.createNoneItem(TEffectName.EFFECT_MOTION));
    }
    return paramManager.getParams();
  }

  @override
  List<TESDKParam> getUsedProperties() {
    return ProducerUtils.getUsedProperties(_allData);
  }

  @override
  List<TEUIProperty>? onItemClick(TEUIProperty uiProperty) {
    if (uiProperty.uiCategory == null) {
      return null;
    }
    switch (uiProperty.uiCategory) {
      case UICategory.BEAUTY:
      case UICategory.BODY_BEAUTY:
      case UICategory.LUT:
        TEUIProperty? currentProperty = _dataCategory[uiProperty.uiCategory];
        if ((uiProperty.propertyList == null && uiProperty.sdkParam != null) || uiProperty.isNoneItem()) {
          if (currentProperty != null) {
            ProducerUtils.revertUIState(currentProperty.propertyList, uiProperty);
            ProducerUtils.changeParamUIState(uiProperty, UIState.CHECKED_AND_IN_USE);
          }
        }
        break;
      case UICategory.MAKEUP:
      case UICategory.MOTION:
      case UICategory.SEGMENTATION:
        TEUIProperty? makeUpProperty = _dataCategory[UICategory.MAKEUP];
        TEUIProperty? motionProperty = _dataCategory[UICategory.MOTION];
        TEUIProperty? segProperty = _dataCategory[UICategory.SEGMENTATION];
        if ((uiProperty.propertyList == null && uiProperty.sdkParam != null) || uiProperty.isNoneItem()) {
          if (makeUpProperty != null) {
            ProducerUtils.revertUIState(makeUpProperty.propertyList, uiProperty);
          }
          if (motionProperty != null) {
            ProducerUtils.revertUIState(motionProperty.propertyList, uiProperty);
          }
          if (segProperty != null) {
            ProducerUtils.revertUIState(segProperty.propertyList, uiProperty);
          }
          ProducerUtils.changeParamUIState(uiProperty, UIState.CHECKED_AND_IN_USE);
        }
        break;
    }
    return uiProperty.propertyList;
  }

  @override
  void onTabItemClick(TEUIProperty uiProperty) {
    for(TEUIProperty property in _allData){
      if (property == uiProperty) {
        property.setUiState(UIState.CHECKED_AND_IN_USE);
      } else {
        property.setUiState(UIState.INIT);
      }
    }
  }

  @override
  List<TEUIProperty>? getFirstCheckedItems() {
    for (TEUIProperty property in _allData) {
      if (property.uiState == UIState.CHECKED_AND_IN_USE &&
          property.propertyList != null) {
        return property.propertyList!;
      }
    }
    return null;
  }
}
