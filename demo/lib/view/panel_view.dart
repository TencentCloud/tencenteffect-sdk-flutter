import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tencent_effect_flutter/api/tencent_effect_api.dart';
import 'package:tencent_effect_flutter/model/beauty_constant.dart';
import 'package:tencent_effect_flutter/model/xmagic_property.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_effect_flutter_demo/languages/AppLocalizations.dart';

typedef PanelViewCallBack = void Function(XmagicProperty property);
class PanelView extends StatefulWidget {

  final PanelViewCallBack? _itemClickCallBack;

  final int onSliderUpdateXmagicType; //默认表示在onChanged方法中回调  2.表示在onChangeEnd中调用

  final Map<String, List<XmagicUIProperty>>? _beautyProperties;

  const PanelView(this._itemClickCallBack, this._beautyProperties,
      {Key? key, this.onSliderUpdateXmagicType = 1})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PanelState();
  }


  static PanelState? of(BuildContext context) {
    final _PanelScope? scope = context.dependOnInheritedWidgetOfExactType<_PanelScope>();
    return scope?._panelState;
  }
}

class _PanelScope extends InheritedWidget {
  const _PanelScope({
    Key? key,
    required Widget child,
    required PanelState panelState,
    required int generation,
  }) : _panelState = panelState,
        _generation = generation,
        super(key: key, child: child);

  final PanelState _panelState;

  /// Incremented every time a form field has changed. This lets us know when
  /// to rebuild the form.
  final int _generation;

  /// The [Form] associated with this widget.
  PanelView get form => _panelState.widget;

  @override
  bool updateShouldNotify(_PanelScope old) => _generation != old._generation;
}

class PanelState extends State<PanelView> {
  final ScrollController _scrollController = ScrollController();
  double _listViewOffect = 0;
  List<String> _beautyTypes = [];
  bool _isShowSeekBar = false;
  double _progressMin = 0;
  double _progressMax = 100;
  double _currentProgress = 0;
  String _secondTitleName = "";

  XmagicProperty? _xmagicProperty;
  String? _titleKey;
  bool _isShowBackBtn = false;

  //当前展示的列表
  List<XmagicUIProperty>? _currentList;



  static List<String> specialEffectKeys = [
    /// 口红id
    BeautyConstant.BEAUTY_MOUTH_LIPSTICK,
    BeautyConstant.BEAUTY_MOUTH_LIPSTICK_IOS,

    /// 腮红id
    BeautyConstant.BEAUTY_FACE_RED_CHEEK,
    BeautyConstant.BEAUTY_FACE_RED_CHEEK_IOS,

    /// 立体 id
    BeautyConstant.BEAUTY_FACE_SOFTLIGHT,
    BeautyConstant.BEAUTY_FACE_SOFTLIGHT_IOS,

    /// 自然 id
    BeautyConstant.BEAUTY_FACE_NATURE,
    BeautyConstant.BEAUTY_FACE_NATURE_IOS,

    /// 女神 id
    BeautyConstant.BEAUTY_FACE_GODNESS,
    BeautyConstant.BEAUTY_FACE_GODNESS_IOS,

    /// 英俊 id
    BeautyConstant.BEAUTY_FACE_MALE_GOD,
    BeautyConstant.BEAUTY_FACE_MALE_GOD_IOS,
  ];

  @override
  initState() {
    super.initState();
    processData();
  }

  ///获取所有美颜属性
  ///get all data
  void processData() async {
    List<String> types = [];
    for (var key in Category.orderKeys) {
      if (widget._beautyProperties?[key]?.isNotEmpty ?? false) {
        types.add(key);
      }
    }
    _titleKey = types[0];
    List<XmagicUIProperty>? firstList = widget._beautyProperties?[_titleKey];
    setState(() {
      _beautyTypes = types;
      _currentList = firstList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isShowBackBtn ? _buildBackLayout() : Container(),
          _buildSlider(),
          //标题
          _buildTitle(context),
          //内容
          SizedBox(
            height: 120,
            child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: itemBuilder,
                itemCount: _currentList?.length),
          )
        ],
      ),
    );
  }

  ///创建返回布局
  Widget _buildBackLayout() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          iconSize: 30,
          onPressed: _onBackBtnClick,
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        Text(
          _secondTitleName,
          style: const TextStyle(color: Colors.white),
        ),
        Container(
          width: 30,
        ),
      ],
    );
  }

  ///创建分类布局
  ///create type layout
  Widget _buildTitle(BuildContext context) {
    List<Widget> titlesView = [];
    for (var titleName in _beautyTypes) {
      titlesView.add(TextButton(
        onPressed: () {
          _onTitleClick(titleName);
        },
        child: Text(
          getNameByCode(context, titleName)!,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: titleName == _titleKey ? Colors.red : Colors.white),
        ),
      ));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: titlesView,
      ),
    );
  }

  static String? getNameByCode(BuildContext context, String code) {
    switch (code) {
      case "LUT":
        return AppLocalizations.of(context)!.xmagicPannelTab3;
      case "BEAUTY":
        return AppLocalizations.of(context)!.xmagicPannelTab1;
      case "BODY_BEAUTY":
        return AppLocalizations.of(context)!.xmagicPannelTab2;
      case "MOTION":
        return AppLocalizations.of(context)!.xmagicPannelTab4;
      case "SEGMENTATION":
        return AppLocalizations.of(context)!.xmagicPannelTab6;
      case "MAKEUP":
        return AppLocalizations.of(context)!.xmagicPannelTab5;
    }
    return "";
  }

  ///创建slider布局
  ///create slider layout
  Widget _buildSlider() {
    return _isShowSeekBar
        ? Slider(
            value: _currentProgress,
            thumbColor: Colors.red,
            activeColor: Colors.redAccent,
            inactiveColor: Colors.white,
            divisions: 100,
            onChanged: (value) {
              var localValue = value.round().toDouble();
              if (localValue != _currentProgress) {
                _xmagicProperty?.effValue?.setCurrentDisplayValue(localValue);
                if (widget.onSliderUpdateXmagicType == 1) {
                  _onUpdateBeautyValue();
                }
              }
              setState(() {
                _currentProgress = localValue;
              });
            },
            onChangeEnd: (value) {
              if (widget.onSliderUpdateXmagicType == 2) {
                _onUpdateBeautyValue();
              }
            },
            min: _progressMin,
            max: _progressMax,
            label: '$_currentProgress',
          )
        : Container();
  }

  ///用于创建listview 的item中的image
  ///create listeView item :imageview
  Widget _getItemIcon(int index) {
    if (_currentList?[index].thumbDrawableName?.isNotEmpty ?? false) {
      String path =
          "assets/images/icon/${_currentList?[index].thumbDrawableName ?? "beauty_basic_face"}.png";
      return Container(
        width: 65,
        height: 65,
        decoration: _currentList?[index].isChecked ?? false
            ? BoxDecoration(
                border: Border.all(width: 2, color: Colors.red.shade500),
                borderRadius: BorderRadius.circular(10))
            : null,
        child: Image.asset(
          path,
          width: 65,
          height: 65,
        ),
      );
    } else {
      return Container(
        width: 65,
        height: 65,
        decoration: _currentList?[index].isChecked ?? false
            ? BoxDecoration(
                border: Border.all(width: 2, color: Colors.red.shade500),
                borderRadius: BorderRadius.circular(10))
            : null,
        child: Image.file(
          File(_currentList?[index].thumbImagePath ?? ""),
          width: 65,
          height: 65,
        ),
      );
    }
  }

  ///用于创建listview的item
  ///create listview items
  Widget itemBuilder(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        _onListItemClick(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: _getItemIcon(index),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: Text(
                _currentList?[index].displayName ?? "",
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              )),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
                color: _isShowPoint(_currentList?[index])
                    ? Colors.red
                    : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(3))),
          ),
        ],
      ),
    );
  }

  bool _isShowPoint(XmagicUIProperty? uiProperty) {
    if (uiProperty == null) {
      return false;
    }
    if (uiProperty.uiCategory != Category.BEAUTY) {
      return false;
    }
    if (uiProperty.xmagicUIPropertyList != null) {
      for (XmagicUIProperty xmagicUIProperty
          in uiProperty.xmagicUIPropertyList!) {
        bool isShow = _isShowPoint(xmagicUIProperty);
        if (isShow) {
          return true;
        }
      }
    } else {
      XmagicPropertyValues? propertyValues = uiProperty.property?.effValue;
      if (propertyValues?.getCurrentDisplayValue() != 0 && uiProperty.isUsed) {
        return true;
      }
    }
    return false;
  }

  ///返回按钮点击事件
  void _onBackBtnClick() {
    List<XmagicUIProperty>? list = widget._beautyProperties?[_titleKey];
    setState(() {
      _currentList = list;
      _isShowBackBtn = false;
    });
    _scrollController.jumpTo(_listViewOffect);
  }

  ///分类的点击事件
  void _onTitleClick(String titleName) {
    setState(() {
      _titleKey = titleName;
    });
    List<XmagicUIProperty>? list = widget._beautyProperties?[titleName];
    setState(() {
      _isShowBackBtn = false;
      _currentList = list;
    });
  }

  /// 美颜属性的点击事件
  /// item click
  void _onListItemClick(int index) {
    XmagicUIProperty xmagicUIProperty = _currentList![index];
    _updateIsUsed(index);
    _upDateCheckedItem(_currentList!);
    xmagicUIProperty.isChecked = true;
    if (xmagicUIProperty.xmagicUIPropertyList?.isNotEmpty ?? false) {
      _xmagicProperty = null;
      setState(() {
        _isShowSeekBar = false;
        _currentList = xmagicUIProperty?.xmagicUIPropertyList;
        _isShowBackBtn = true;
        _secondTitleName = xmagicUIProperty?.displayName ?? "";
      });
      _listViewOffect = _scrollController.offset;
    } else {
      _onClickListItem(xmagicUIProperty);
    }
  }

  void _onClickListItem(XmagicUIProperty? xmagicUIProperty) {
    _xmagicProperty = xmagicUIProperty?.property;
    bool localisShowSeekBar =
        (_xmagicProperty != null && _xmagicProperty?.effValue != null);
    double localCurrentProgress =
        _xmagicProperty?.effValue?.getCurrentDisplayValue() ?? 0;
    double localMin = _xmagicProperty?.effValue?.displayMinValue ?? 0;
    double localMax = _xmagicProperty?.effValue?.displayMaxValue ?? 0;
    setState(() {
      _isShowSeekBar = localisShowSeekBar;
      if (_isShowSeekBar) {
        _currentProgress = localCurrentProgress;
        _progressMax = localMax;
        _progressMin = localMin;
      }
    });
    _onUpdateBeautyValue();
  }

  _updateIsUsed(int index) {
    XmagicUIProperty uiProperty = _currentList![index];
    if (uiProperty.property?.effKey?.isNotEmpty ?? false) {
      if (specialEffectKeys.contains(uiProperty.property?.effKey)) {
        for (XmagicUIProperty uiProperty in _currentList!) {
          uiProperty.isUsed = false;
        }
      }
    }
    uiProperty.isUsed = true;
  }

  _upDateCheckedItem(List<XmagicUIProperty> uiPropertyList) {
    for (XmagicUIProperty uiProperty in uiPropertyList) {
      uiProperty.isChecked = false;
      if (uiProperty.xmagicUIPropertyList != null) {
        _upDateCheckedItem(uiProperty.xmagicUIPropertyList!);
      }
      if (uiProperty.property != null) {
        uiProperty.isChecked = false;
      }
    }
  }

  /// 更新美颜属性值
  /// update beauty item
  Future<void> _onUpdateBeautyValue() async {
    if (_xmagicProperty != null) {
      if (_xmagicProperty?.id == "video_empty_segmentation") {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
        ].request();
        if (statuses[Permission.photos] != PermissionStatus.denied) {
          final ImagePicker _picker = ImagePicker();
          // Pick an image
          XFile? image = await _picker.pickImage(source: ImageSource.gallery);
          // XFile? image = await _picker.pickVideo(source: ImageSource.gallery);//选取视频
          if (image == null) {
            return;
          }
          _xmagicProperty?.effKey = image.path;
        }
      }
      TencentEffectApi.getApi()?.updateProperty(_xmagicProperty!);
      widget._itemClickCallBack?.call(_xmagicProperty!);
    }
  }


}
