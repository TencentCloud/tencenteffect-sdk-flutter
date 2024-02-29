
import '../model/te_ui_property.dart';

abstract class BeautyPanelViewCallBack {
  ///更新美颜属性时使用
  void onUpdateEffect(TESDKParam sdkParam);

  ///用于更新多个美颜属性时使用，例如点击关闭按钮的时候
  void onUpdateEffectList(List<TESDKParam> sdkParams);

  /// @param paramList 此方法用于将默认的美颜效果列表 属性返回给客户
  void onDefaultEffectList(List<TESDKParam> paramList);

  /// 由于绿幕和 自定义分割属性比较特殊，需要特殊处理，所以单独通过此方法返回对应的数据
  /// 当点击了绿幕 或者 自定义分割的时候会回调此方法
  /// @param uiProperty
  void onClickCustomSeg(TEUIProperty uiProperty);
}
