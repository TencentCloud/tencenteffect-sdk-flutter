import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tencent_effect_flutter/api/tencent_effect_api.dart';
import 'package:tencent_effect_flutter/model/xmagic_property.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_effect_flutter_demo/languages/AppLocalizations.dart';
import '../producer/beauty_data_manager.dart';

class PannelView extends StatefulWidget {
  final Function? _itemClickCallBack;

  final int onSliderUpdateXmagicType; //默认表示在onChanged方法中回调  2.表示在onChangeEnd中调用

  const PannelView(this._itemClickCallBack,
      {Key? key, this.onSliderUpdateXmagicType = 1})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PannelState();
  }
}

class _PannelState extends State<PannelView> {
  final ScrollController _scrollController = ScrollController();
  double _listViewOffect = 0;
  Map<String, List<XmagicUIProperty>>? _datas;
  List<String> _beautyTypes = [];
  bool _isShowSeekBar = false;
  double _progressMin = 0;
  double _progressMax = 100;
  double _currentProgress = 0;
  String _secondTitleName = "";

  XmagicProperty? _xmagicProperty;
  String? _titleKey;
  bool isShowBackBtn = false;

  //当前展示的列表
  List<XmagicUIProperty>? currentList;

  @override
  initState() {
    super.initState();
    _getAllData();
  }

  ///获取所有美颜属性
  ///get all data
  void _getAllData() async {
    _datas = await BeautyDataManager.getInstance().getAllPannelData(context);
    List<String> types = [];
    for (var key in Category.orderKeys) {
      if (_datas?[key]?.isNotEmpty ?? false) {
        types.add(key);
      }
    }

    _titleKey = types[0];

    List<XmagicUIProperty>? firstList = _datas?[_titleKey];
    setState(() {
      _beautyTypes = types;
      currentList = firstList;
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
          isShowBackBtn ? _buildBackLayout() : Container(),
          _buildSlider(),
          //标题
          _buildTitle(context),
          //内容
          SizedBox(
            height: 100,
            child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: itemBuilder,
                itemCount: currentList?.length),
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
                  _onUpdataBeautyValue();
                }
              }
              setState(() {
                _currentProgress = localValue;
              });
            },
            onChangeEnd: (value) {
              if (widget.onSliderUpdateXmagicType == 2) {
                _onUpdataBeautyValue();
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
    if (currentList?[index]?.thumbDrawableName?.isNotEmpty ?? false) {
      String path =
          "assets/images/icon/${currentList?[index].thumbDrawableName ?? "beauty_basic_face"}.png";
      return Image.asset(
        path,
        width: 65,
        height: 65,
      );
    } else {
      return Image.file(
        File(currentList?[index].thumbImagePath ?? ""),
        width: 65,
        height: 65,
      );
    }
  }

  ///用于创建listview的item
  ///create listview items
  Widget itemBuilder(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        _onListItemClick(currentList?[index]);
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
                currentList?[index].displayName ?? "",
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }

  ///返回按钮点击事件
  void _onBackBtnClick() {
    List<XmagicUIProperty>? list = _datas?[_titleKey];
    setState(() {
      currentList = list;
      isShowBackBtn = false;
    });
    _scrollController.jumpTo(_listViewOffect);
  }

  ///分类的点击事件
  void _onTitleClick(String titleName) {
    setState(() {
      _titleKey = titleName;
    });
    List<XmagicUIProperty>? list = _datas?[titleName];
    setState(() {
      isShowBackBtn = false;
      currentList = list;
    });
  }

  /// 美颜属性的点击事件
  /// item click
  void _onListItemClick(XmagicUIProperty? xmagicUIProperty) {
    if (xmagicUIProperty?.xmagicUIPropertyList?.isNotEmpty ?? false) {
      _xmagicProperty = null;
      setState(() {
        _isShowSeekBar = false;
        currentList = xmagicUIProperty?.xmagicUIPropertyList;
        isShowBackBtn = true;
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
    _onUpdataBeautyValue();
  }

  /// 更新美颜属性值
  /// update beauty item
  Future<void> _onUpdataBeautyValue() async {
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
      widget._itemClickCallBack?.call();
    }
  }
}
