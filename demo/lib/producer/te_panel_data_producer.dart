import '../model/te_panel_data_model.dart';
import '../model/te_ui_property.dart';

/// 面板数据提供接口
abstract class TEPanelDataProducer {

  /// 设置需要加载的数据
  /// @param panelDataList
  void setPanelDataList(List<TEPanelDataModel> panelDataList);

  /// 设置用户选中的默认数据，一般只设置美颜数据
  /// @param paramList
  void setUsedParams(List<TESDKParam> paramList);

  /// 获取数据
  ///
  /// @return
  Future<List<TEUIProperty>> getPanelData() ;

  /// 强制刷新数据
  ///
  /// @param context 应用上下文
  /// @return
  Future<List<TEUIProperty>> forceRefreshPanelData();

  /// 当点击分类的时候调用此方法，此方法用于处理分类数据的选中状态更换
  /// @param index
  onTabItemClick(TEUIProperty uiProperty) ;

  /// 当列表item被点击时调用
  ///
  /// @param uiProperty
  /// @return 如果有子项目则返回子项目，没有则直接返回null
  List<TEUIProperty>? onItemClick(TEUIProperty uiProperty);

  /// 获取用于还原美颜效果的属性集合
  ///
  /// @return
  List<TESDKParam> getRevertData();

  /// 用于关闭当前分类效果的 属性列表
  ///
  /// @return
  List<TESDKParam>? getCloseEffectItems(TEUIProperty uiProperty);

  /// 获取用户已使用的美颜数据
  /// @return
  List<TESDKParam> getUsedProperties();

  /// 根据JSON文件，获取第一个选中项的列表数据
  /// @return
  List<TEUIProperty>? getFirstCheckedItems();

}
