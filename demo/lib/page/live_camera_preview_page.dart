import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:live_flutter_plugin/manager/tx_device_manager.dart';
import 'package:live_flutter_plugin/v2_tx_live_code.dart';
import 'package:live_flutter_plugin/v2_tx_live_def.dart';
import 'package:live_flutter_plugin/v2_tx_live_pusher.dart';
import 'package:live_flutter_plugin/widget/v2_tx_live_video_widget.dart';
import 'package:tencent_effect_flutter/api/tencent_effect_api.dart';
import 'package:tencent_effect_flutter/model/xmagic_property.dart';
import 'package:tencent_effect_flutter/utils/Logs.dart';
import 'package:tencent_effect_flutter_demo/view/pannel_view.dart';
import '../languages/AppLocalizations.dart';
import '../producer/beauty_data_manager.dart';


/// 直播推流页面
/// Live-Camera page
class LiveCameraPushPage extends StatefulWidget {
  const LiveCameraPushPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LiveCameraPushPageState();
  }
}

class _LiveCameraPushPageState extends State<LiveCameraPushPage>
    with WidgetsBindingObserver {

  static const String TAG = "LiveCameraPushPage";

  /// 分辨率
  /// Resolution
  V2TXLiveVideoResolution _resolution =
      V2TXLiveVideoResolution.v2TXLiveVideoResolution1280x720;

  /// 旋转角度
  /// Rotation angle
  V2TXLiveRotation _liveRotation = V2TXLiveRotation.v2TXLiveRotation0;

  /// 摄像头
  /// Camera
  V2TXLiveMirrorType _liveMirrorType =
      V2TXLiveMirrorType.v2TXLiveMirrorTypeAuto;

  /// 音频设置
  /// Audio settings
  TXDeviceManager? _txDeviceManager;

  /// 音频数据
  /// Audio data
  int? _localViewId;
  V2TXLivePusher? _livePusher;

  bool _isOpenBeauty = true;
  bool? _isFrontCamera = true;

  Map<String, List<XmagicUIProperty>>? data;
  String resultMsg = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initLive();
    _getAllData();
  }

  //获取测试使用的数据
  void _getAllData() async{
    Map<String, List<XmagicUIProperty>>? data =
    await BeautyDataManager.getInstance().getAllPannelData(context);
    this.data = data;
  }


  @override
  void deactivate() {
    debugPrint("Live-Camera push deactivate");
    TencentEffectApi.getApi()?.onPause();
    enableBeauty(false);
    _livePusher?.stopMicrophone();
    _livePusher?.stopCamera();
    _livePusher?.destroy();
    super.deactivate();
  }

  @override
  dispose() {
    debugPrint("Live-Camera push dispose");
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  initLive() async {
    await initPlatformState();
    // 获取设备管理模块
    _txDeviceManager = _livePusher?.getDeviceManager();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _livePusher = V2TXLivePusher(V2TXLiveMode.v2TXLiveModeRTMP);
    if (!mounted) return;
    setState(() {
      debugPrint("CreatePusher result is ${_livePusher?.status}");
    });
  }

  _startPreview() async {
    if (_livePusher == null) {
      return;
    }
    await _livePusher?.setRenderMirror(_liveMirrorType);
    var videoEncoderParam = V2TXLiveVideoEncoderParam();
    videoEncoderParam.videoResolution = _resolution;
    videoEncoderParam.videoResolutionMode =
        V2TXLiveVideoResolutionMode.v2TXLiveVideoResolutionModePortrait;
    await _livePusher?.setVideoQuality(videoEncoderParam);

    ///设置默认清晰度
    ///Set default sharpness
    await _livePusher
        ?.setAudioQuality(V2TXLiveAudioQuality.v2TXLiveAudioQualityDefault);

    if (_localViewId != null) {
      var code = await _livePusher?.setRenderViewID(_localViewId!);
      if (code != V2TXLIVE_OK) {
        showErrordDialog("StartPush error： please check remoteView load");
        return;
      }
    }
    var cameraCode = await _livePusher?.startCamera(_isFrontCamera!);
    if (cameraCode == null || cameraCode != V2TXLIVE_OK) {
      debugPrint("cameraCode: $cameraCode");
      showErrordDialog("Camera push error：please check Camera system auth.");
      return;
    }
    await _livePusher?.startMicrophone();

    Future.delayed(const Duration(seconds: 3), () async {
      _isFrontCamera = await _txDeviceManager?.isFrontCamera();
      setState(() {});
    });
    enableBeauty(_isOpenBeauty);
  }

  ///切换摄像头
  ///switch camera
  void _switchCamera() async {
    await _txDeviceManager?.switchCamera(_isFrontCamera!);
  }

  void _setBeautyListener() {
    TencentEffectApi.getApi()
        ?.setOnCreateXmagicApiErrorListener((errorMsg, code) {
      TXLog.printlog("create xmaogicApi is error:  errorMsg = $errorMsg , code = $code");
    });

    TencentEffectApi.getApi()?.setAIDataListener(XmagicAIDataListenerImp());
    TencentEffectApi.getApi()?.setYTDataListener((data) {
      TXLog.printlog("setYTDataListener  $data");
    });
    TencentEffectApi.getApi()?.setTipsListener(XmagicTipsListenerImp());
  }

  void _removeBeautyListener() {
    TencentEffectApi.getApi()?.onPause();
    TencentEffectApi.getApi()?.setOnCreateXmagicApiErrorListener(null);
    TencentEffectApi.getApi()?.setAIDataListener(null);
    TencentEffectApi.getApi()?.setYTDataListener(null);
    TencentEffectApi.getApi()?.setTipsListener(null);
  }

  ///打开美颜操作，true表示开启美颜，FALSE表示关闭美颜
  ///true is turn on,false is turn off
  Future<int?> enableBeauty(bool open) async {
    if (open) {
      _setBeautyListener();
    } else {
      _removeBeautyListener();
    }

    ///开启美颜操作
    ///Turn on /off
    return await _livePusher?.enableCustomVideoProcess(open);
  }

  stopPush() async {
    await _livePusher?.stopMicrophone();
    await _livePusher?.stopCamera();
  }

  void setLiveMirrorType(V2TXLiveMirrorType type) async {
    await _livePusher?.setRenderMirror(type);
    setState(() {
      _liveMirrorType = type;
    });
  }

  String _liveMirrorTitle() {
    if (_liveMirrorType == V2TXLiveMirrorType.v2TXLiveMirrorTypeAuto) {
      // front camera mirror only
      return "Auto";
    } else if (_liveMirrorType == V2TXLiveMirrorType.v2TXLiveMirrorTypeEnable) {
      return "Enable";
    } else {
      return "Disable";
    }
  }

  void setLiveRotation(V2TXLiveRotation rotation) async {
    var code = await _livePusher?.setRenderRotation(rotation);
    debugPrint("setLiveRotation code: $code, rotation: $rotation ");
    if (code == V2TXLIVE_OK) {
      setState(() {
        _liveRotation = rotation;
      });
    } else {
      showErrordDialog("setLiveRotation error: code-$code");
    }
  }

  String _liveRotationTitle() {
    if (_liveRotation == V2TXLiveRotation.v2TXLiveRotation0) {
      return "0";
    } else if (_liveRotation == V2TXLiveRotation.v2TXLiveRotation90) {
      return "90";
    } else if (_liveRotation == V2TXLiveRotation.v2TXLiveRotation180) {
      return "180";
    } else {
      return "270";
    }
  }

  void setLiveVideoResolution(V2TXLiveVideoResolution resolution) async {
    var videoEncoderParam = V2TXLiveVideoEncoderParam();
    videoEncoderParam.videoResolution = resolution;
    await _livePusher?.setVideoQuality(videoEncoderParam);
    setState(() {
      _resolution = resolution;
    });
  }

  String _liveResolutionTitle() {
    if (_resolution == V2TXLiveVideoResolution.v2TXLiveVideoResolution640x360) {
      return "360P";
    } else if (_resolution ==
        V2TXLiveVideoResolution.v2TXLiveVideoResolution960x540) {
      return "540P";
    } else if (_resolution ==
        V2TXLiveVideoResolution.v2TXLiveVideoResolution1280x720) {
      return "720P";
    } else if (_resolution ==
        V2TXLiveVideoResolution.v2TXLiveVideoResolution1920x1080) {
      return "1080P";
    } else {
      return "unknown";
    }
  }

  bool _isStartPreview = false;

  Widget renderView() {
    return V2TXLiveVideoWidget(
      onViewCreated: (viewId) async {
        _localViewId = viewId;
        if (_isStartPreview == false) {
          _isStartPreview = true;
          Future.delayed(const Duration(seconds: 1), () {
            _startPreview();
          });
        }
      },
    );
  }

  // sdk出错信查看
  Future<bool?> showErrordDialog(errorMsg) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text("Alert"),
          content: Text(errorMsg),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// 打开美颜面板
  /// show beauty pannel
  void _showModalBeautySheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return const PannelView(null);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('LIVE Page'),
          leading: IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: ConstrainedBox(
          // color: Colors.black12,
          constraints: const BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                child: Center(
                  child: renderView(),
                ),
                color: Colors.black,
              ),
              Positioned(
                  right: 10,
                  top: 10,
                  child: Column(
                     children: [
                       TextButton(
                          onPressed: () => {onCheckAuth()},
                          child: Text(
                              AppLocalizations.of(context)!.getDemoLiveLabel1!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ))),
                      TextButton(
                          onPressed: () => {onGetDeviceAbilities()},
                          child: Text(
                              AppLocalizations.of(context)!.getDemoLiveLabel2!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ))),
                      TextButton(
                          onPressed: () => {onCheckSupportBeauty()},
                          child: Text(
                              AppLocalizations.of(context)!.getDemoLiveLabel3!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ))),
                      TextButton(
                          onPressed: () => {onCheckDeviceSupport()},
                          child: Text(
                              AppLocalizations.of(context)!.getDemoLiveLabel4!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ))),
                      TextButton(
                          onPressed: () => {onCallPropertyRequiredAbilities()},
                          child: Text(
                              AppLocalizations.of(context)!.getDemoLiveLabel5!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              )))
                    ],
              )),

              Positioned(
                bottom: 40.0,
                left: 10,
                right: 10,
                child: Container(
                  // color: Colors.black12,
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            'ON/OFF Beauty',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Switch(
                            value: _isOpenBeauty,
                            onChanged: (value) {
                              setState(() {
                                _isOpenBeauty = value;
                              });
                              enableBeauty(value);
                            },
                          ),
                          const Text(
                            'Camera',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Switch(
                            value: _isFrontCamera!,
                            onChanged: (value) {
                              setState(() {
                                _isFrontCamera = value;
                              });
                              _switchCamera();
                            },
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: SizedBox(
                          height: 80,
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: ElevatedButton(
                                        child: const Text(
                                          "Beauty settings",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        onPressed: () {
                                          _showModalBeautySheet(context);
                                        },
                                      ),
                                    ),
                                    const Spacer(flex: 1),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: SizedBox(
                          height: 80,
                          child: Flex(
                            direction: Axis.vertical,
                            children: [
                              const Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text("videoSettings",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Flex(
                                        direction: Axis.vertical,
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Text("Resolution",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  child: Text(
                                                    _liveResolutionTitle(),
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.grey),
                                                  ),
                                                  onPressed: () {
                                                    showAdaptiveActionSheet(
                                                      context: context,
                                                      title: null,
                                                      androidBorderRadius: 30,
                                                      actions: <
                                                          BottomSheetAction>[
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '360P',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveVideoResolution(
                                                                  V2TXLiveVideoResolution
                                                                      .v2TXLiveVideoResolution640x360);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '540P',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveVideoResolution(
                                                                  V2TXLiveVideoResolution
                                                                      .v2TXLiveVideoResolution960x540);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '720P',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveVideoResolution(
                                                                  V2TXLiveVideoResolution
                                                                      .v2TXLiveVideoResolution1280x720);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '1080P',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveVideoResolution(
                                                                  V2TXLiveVideoResolution
                                                                      .v2TXLiveVideoResolution1920x1080);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      ],
                                                      cancelAction: CancelAction(
                                                          title: const Text(
                                                              'Cancel')), // onPressed parameter is optional by default will dismiss the ActionSheet
                                                    );
                                                  },
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    const Spacer(flex: 1),
                                    Expanded(
                                      flex: 5,
                                      child: Flex(
                                        direction: Axis.vertical,
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Text("Rotation",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  child: Text(
                                                    _liveRotationTitle(),
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.grey),
                                                  ),
                                                  onPressed: () {
                                                    showAdaptiveActionSheet(
                                                      context: context,
                                                      title: null,
                                                      androidBorderRadius: 30,
                                                      actions: <
                                                          BottomSheetAction>[
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '0',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveRotation(
                                                                  V2TXLiveRotation
                                                                      .v2TXLiveRotation0);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '90',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveRotation(
                                                                  V2TXLiveRotation
                                                                      .v2TXLiveRotation90);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '180',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveRotation(
                                                                  V2TXLiveRotation
                                                                      .v2TXLiveRotation180);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                '270',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveRotation(
                                                                  V2TXLiveRotation
                                                                      .v2TXLiveRotation270);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      ],
                                                      cancelAction: CancelAction(
                                                          title: const Text(
                                                              'Cancel')), // onPressed parameter is optional by default will dismiss the ActionSheet
                                                    );
                                                  },
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    const Spacer(flex: 1),
                                    Expanded(
                                      flex: 5,
                                      child: Flex(
                                        direction: Axis.vertical,
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: Text("MirrorType",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  child: Text(
                                                    _liveMirrorTitle(),
                                                    style: const TextStyle(
                                                        fontSize: 10),
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.grey),
                                                  ),
                                                  onPressed: () {
                                                    showAdaptiveActionSheet(
                                                      context: context,
                                                      title: null,
                                                      androidBorderRadius: 30,
                                                      actions: <
                                                          BottomSheetAction>[
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                'MirrorTypeAuto',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveMirrorType(
                                                                  V2TXLiveMirrorType
                                                                      .v2TXLiveMirrorTypeAuto);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                'MirrorTypeEnable',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveMirrorType(
                                                                  V2TXLiveMirrorType
                                                                      .v2TXLiveMirrorTypeEnable);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        BottomSheetAction(
                                                            title: const Text(
                                                                'MirrorTypeDisable',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue)),
                                                            onPressed: (BuildContext context) {
                                                              setLiveMirrorType(
                                                                  V2TXLiveMirrorType
                                                                      .v2TXLiveMirrorTypeDisable);
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                      ],
                                                      cancelAction: CancelAction(
                                                          title: const Text(
                                                              'Cancel')), // onPressed parameter is optional by default will dismiss the ActionSheet
                                                    );
                                                  },
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: //从后台切换前台，界面可见
        TencentEffectApi.getApi()?.onResume();
        break;
      case AppLifecycleState.paused: // 界面不可见，后台
        TencentEffectApi.getApi()?.onPause();
        break;
      case AppLifecycleState.detached: // APP结束时调用
        break;
    }
  }



  //检测美颜是否授权
  void onCheckAuth() async {
    List<XmagicUIProperty>? beautyUiList = data?['BEAUTY'];
    List<XmagicProperty> beautyList = [];
    beautyUiList?.forEach((uiproperty) {
      if (uiproperty.xmagicUIPropertyList != null) {
        uiproperty.xmagicUIPropertyList?.forEach((element) {
          element.property!.isAuth = false;
          beautyList.add(element.property!);
        });
      } else {
        uiproperty.property!.isAuth = false;
        beautyList.add(uiproperty.property!);
      }
    });
    List<XmagicProperty>? resultList =
    await TencentEffectApi.getApi()?.isBeautyAuthorized(beautyList);
    resultList?.forEach((element) {
      TXLog.printlog("$TAG  method is onCheckAuth , result is  ${json.encode(element)}");
    });
    resultMsg = json.encode(resultList);
    showTipDialog();
  }

  void onGetDeviceAbilities() async {
    Map<String, bool>? deviceAbilities =
    await TencentEffectApi.getApi()?.getDeviceAbilities();
    deviceAbilities?.forEach((key, value) {
      TXLog.printlog(
          "$TAG method is onGetDeviceAbilities ,result data is:  key = $key  , value = $value");
    });
    resultMsg = json.encode(deviceAbilities);
    showTipDialog();
  }

  void onCheckSupportBeauty() async {
    bool? isSupport = await TencentEffectApi.getApi()?.isSupportBeauty();

    TXLog.printlog("$TAG  method is  onCheckSupportBeauty,result is  $isSupport");
    resultMsg = " this device is support beauty : $isSupport";
    showTipDialog();
  }

  //检测此设备是否支持此动效
  void onCheckDeviceSupport() async {
    var inputList = <XmagicProperty>[];
    data?['MOTION']?.forEach((uiproperty) {
      if (uiproperty.xmagicUIPropertyList != null) {
        uiproperty.xmagicUIPropertyList?.forEach((element) {
          element.property!.isSupport = false;
          inputList.add(element.property!);
        });
      } else {
        uiproperty.property!.isSupport = false;
        inputList.add(uiproperty.property!);
      }
    });

    List<XmagicProperty>? resultList =
    await TencentEffectApi.getApi()?.isDeviceSupport(inputList);
    resultList?.forEach((element) {
      TXLog.printlog(
          "$TAG method is onCheckDeviceSupport ,result data is ${json.encode(element)}");
    });
    resultMsg = json.encode(resultList);
    showTipDialog();
  }

  //传入 动效/美妆/分割/的数据，返回此属性所需要的原子能力
  void onCallPropertyRequiredAbilities() async {
    var inputList = <XmagicProperty>[];
    data?['SEGMENTATION']?.forEach((uiproperty) {
      if (uiproperty.xmagicUIPropertyList != null) {
        uiproperty.xmagicUIPropertyList?.forEach((element) {
          inputList.add(element.property!);
        });
      } else {
        inputList.add(uiproperty.property!);
      }
    });

    Map<XmagicProperty, List<String>?>? resultList =
        await TencentEffectApi.getApi()
            ?.getPropertyRequiredAbilities(inputList);
    resultMsg = "";
    resultList?.forEach((key, value) {
      TXLog.printlog(
          "$TAG method is  onCallPropertyRequiredAbilities ,key :   ${json.encode(key)}");
      resultMsg = resultMsg +
          "XmagicProperty ： " +
          json.encode(key) +
          "   Abilities：" +
          json.encode(value);
      value?.forEach((element) {
        TXLog.printlog(
            "$TAG  method is onCallPropertyRequiredAbilities, abilities : ${element.toString()}");
      });
    });
    showTipDialog();
  }

  void showTipDialog() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('result'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text(resultMsg),
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: resultMsg));
                      Fluttertoast.showToast(msg: 'copy success');
                    },
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ok'),
                onPressed: () {
                  disDialog();
                },
              ),
            ],
          );
        });
  }

  void disDialog() {
    Navigator.of(context).pop();
  }
}

class XmagicAIDataListenerImp extends XmagicAIDataListener {
  @override
  void onBodyDataUpdated(String bodyDataList) {
    var result = json.decode(bodyDataList);
    if (result is List) {
      if (result.isNotEmpty) {
        var points = result[0]['points'];
        if (points is List && points.isNotEmpty) {
          TXLog.printlog("onBodyDataUpdated = ${points.length}");
        }
      }
    }
    TXLog.printlog("onBodyDataUpdated = $bodyDataList   ");
  }

  @override
  void onFaceDataUpdated(String faceDataList) {
    var result = json.decode(faceDataList);
    if (result is List) {
      if (result.isNotEmpty) {
        var points = result[0]['points'];
        if (points is List && points.isNotEmpty) {
          TXLog.printlog("onFaceDataUpdated = ${points.length}");
        }
      }
    }
    TXLog.printlog("onFaceDataUpdated = $faceDataList   ");
  }

  @override
  void onHandDataUpdated(String handDataList) {
    var result = json.decode(handDataList);
    if (result is List) {
      if (result.isNotEmpty) {
        var points = result[0]['points'];
        if (points is List && points.isNotEmpty) {
          TXLog.printlog("onHandDataUpdated = ${points.length}");
        }
      }
    }
    TXLog.printlog("onHandDataUpdated = $handDataList   ");
  }
}

class XmagicTipsListenerImp extends XmagicTipsListener {
  @override
  void tipsNeedHide(String tips, String tipsIcon, int type) {
    Fluttertoast.showToast(msg: tips);
  }

  @override
  void tipsNeedShow(String tips, String tipsIcon, int type, int duration) {}
}
