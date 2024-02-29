
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_effect_flutter/api/tencent_effect_api.dart';
import 'package:tencent_effect_flutter_demo/manager/te_param_manager.dart';

import '../model/te_ui_property.dart';
import '../view/beauty_panel_view.dart';
import '../view/beauty_panel_view_callback.dart';

class DefaultPanelViewCallBack implements BeautyPanelViewCallBack {
  final GlobalKey globalKey = GlobalKey();
  List<TESDKParam>? _defaultEffectList;
  bool _isEnable = false;
  TEParamManager paramManager = TEParamManager();

  final bool _pickImg = true ; //true 表示自定义背景的时候选择图片，false 表示选择视频
  /// 此方法的目的是
  /// 1. 当开启美颜的时候将面板返回的默认美颜数据设置上
  /// 2. 当关闭美颜效果，暂存之前生效的美颜属性，在再次打开美颜的时候重新设置上
  ///
  void setEnableEffect(bool enable) {
    _isEnable = enable;
    if (_defaultEffectList != null) {
      onUpdateEffectList(_defaultEffectList!);
      _defaultEffectList = null;
    }
    if (!enable) {
      _defaultEffectList = getUsedParams();
    }
  }

  List<TESDKParam> getUsedParams() {
    return paramManager.getParams();
  }

  @override
  Future<void> onClickCustomSeg(TEUIProperty uiProperty) async {
    if (uiProperty.sdkParam?.extraInfo == null) {
      return;
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
    ].request();
    if (statuses[Permission.photos] != PermissionStatus.denied) {
      final ImagePicker _picker = ImagePicker();
      // Pick an image
      XFile? xFile = _pickImg
          ? await _picker.pickImage(source: ImageSource.gallery)
          : await _picker.pickVideo(source: ImageSource.gallery);
      if (xFile == null) {
        return;
      }
      uiProperty.sdkParam!.extraInfo![TESDKParam.EXTRA_INFO_KEY_BG_TYPE] =
          _pickImg
              ? TESDKParam.EXTRA_INFO_BG_TYPE_IMG
              : TESDKParam.EXTRA_INFO_BG_TYPE_VIDEO;
      uiProperty.sdkParam!.extraInfo![TESDKParam.EXTRA_INFO_KEY_BG_PATH] =
          xFile.path;
      onUpdateEffect(uiProperty.sdkParam!);
      PanelViewState panelViewState = globalKey.currentState as PanelViewState;
      panelViewState.checkPanelViewItem(uiProperty);
    }
  }

  @override
  void onDefaultEffectList(List<TESDKParam> paramList) {
    if (_isEnable) {
      onUpdateEffectList(paramList);
    } else {
      _defaultEffectList = paramList;
    }
  }

  @override
  void onUpdateEffect(TESDKParam sdkParam) {
    debugPrint("onUpdateEffect   ${sdkParam.toJson().toString()}");
    if (sdkParam.effectName != null) {
      paramManager.putTEParam(sdkParam);
      TencentEffectApi.getApi()?.setEffect(sdkParam.effectName!,
          sdkParam.effectValue, sdkParam.resourcePath, sdkParam.extraInfo);
    }
  }

  @override
  void onUpdateEffectList(List<TESDKParam> sdkParams) {
    for (TESDKParam sdkParam in sdkParams) {
      onUpdateEffect(sdkParam);
    }
  }
}
