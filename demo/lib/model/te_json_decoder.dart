
import 'package:tencent_effect_flutter_demo/model/te_ui_property.dart';

class TEJsonDecoder {

  ///解析 TEUIProperty 列表数据
  static List<TEUIProperty>? decodeTEUIPropertyList(List<dynamic>? json) {
    if (json != null) {
      List<TEUIProperty> list = <TEUIProperty>[];
      for (var element in json) {
        if (element != null) {
          list.add(TEUIProperty.fromJson(element));
        }
      }
      return list;
    }
    return null;
  }
}
