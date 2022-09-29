import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_effect_flutter/api/tencent_effect_api.dart';
import 'package:tencent_effect_flutter/utils/Logs.dart';
import '../utils/GenerateTestUserSig.dart';
import '../utils/mettings_model.dart';
import '../utils/tool.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import '../view/pannel_view.dart';



/// Meeting Page
class TrtcCameraPreviewPage extends StatefulWidget {
  const TrtcCameraPreviewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TrtcCameraPreviewPageState();
}

class TrtcCameraPreviewPageState extends State<TrtcCameraPreviewPage>
    with WidgetsBindingObserver {
  static const String TAG = "TrtcCameraPreviewPageState";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late MeetingModel meetModel;

  var userInfo = {}; //Multiplayer video user list

  bool isOpenMic = true; //whether turn on the microphone
  bool isOpenCamera = true; //whether turn on the video
  bool isFrontCamera = true; //front camera
  bool isDoubleTap = false;
  bool isShowingWindow = false;
  int? localViewId;
  String doubleUserId = "";
  String doubleUserIdType = "";

  late TRTCCloud trtcCloud;
  late TXDeviceManager txDeviceManager;
  late TXAudioEffectManager txAudioManager;

  List userList = [];
  List userListLast = [];
  List screenUserList = [];
  int? meetId;
  int quality = TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT;

  bool _isOpenBeauty = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    meetModel = MeetingModel();
    meetModel.setUserSettig({
      "meetId": 1234,
      "userId": "123456",
      "enabledCamera": true,
      "enabledMicrophone": false,
      "quality": quality
    });
    var userSetting = meetModel.getUserSetting();
    meetId = userSetting["meetId"];
    userInfo['userId'] = userSetting["userId"];
    isOpenCamera = userSetting["enabledCamera"];
    isOpenMic = userSetting["enabledMicrophone"];
    iniRoom();
  }

  iniRoom() async {
    // Create TRTCCloud singleton
    trtcCloud = (await TRTCCloud.sharedInstance())!;
    // Tencent Cloud Audio Effect Management Module
    txDeviceManager = trtcCloud.getDeviceManager();
    // Tencent Cloud Audio Effect Management Module
    txAudioManager = trtcCloud.getAudioEffectManager();
    // Register event callback
    trtcCloud.registerListener(onRtcListener);
    // trtcCloud.setVideoEncoderParam(TRTCVideoEncParam(
    //     videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480,
    //     videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT));

    // Enter the room
    enterRoom();

    initData();

    enableBeauty(_isOpenBeauty);
  }

  void _setBeautyListener() {
    TencentEffectApi.getApi()
        ?.setOnCreateXmagicApiErrorListener((errorMsg, code) {
      TXLog.printlog("$TAG method is _setBeautyListener, errorMsg = $errorMsg , code = $code");
    });

    TencentEffectApi.getApi()?.setAIDataListener(XmagicAIDataListenerImp());
    TencentEffectApi.getApi()?.setYTDataListener((data) {
      TXLog.printlog("$TAG mtthod is setYTDataListener ,result data: $data");
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

    return await trtcCloud.enableCustomVideoProcess(open);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState
          .resumed: //Switch from the background to the foreground, and the interface is visible
        if (!kIsWeb && Platform.isAndroid) {
          userListLast = jsonDecode(jsonEncode(userList));
          userList = [];
          screenUserList = MeetingTool.getScreenList(userList);
          setState(() {});

          const timeout = Duration(milliseconds: 100); //10ms
          Timer(timeout, () {
            userList = userListLast;
            screenUserList = MeetingTool.getScreenList(userList);
            setState(() {});
          });
        }
        TencentEffectApi.getApi()?.onResume();
        break;
      case AppLifecycleState.paused: // Interface invisible, background
        TencentEffectApi.getApi()?.onPause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // Enter the trtc room
  enterRoom() async {
    try {
      userInfo['userSig'] =
          await GenerateTestUserSig.genTestSig(userInfo['userId']);
      meetModel.setUserInfo(userInfo);
    } catch (err) {
      userInfo['userSig'] = '';
      TXLog.printlog(err.toString());
    }
  }

  initData() async {
    if (isOpenCamera) {
      userList.add({
        'userId': userInfo['userId'],
        'type': 'video',
        'visible': true,
        'size': {'width': 0, 'height': 0}
      });
    } else {
      userList.add({
        'userId': userInfo['userId'],
        'type': 'video',
        'visible': false,
        'size': {'width': 0, 'height': 0}
      });
    }
    if (isOpenMic) {
      if (kIsWeb) {
        Future.delayed(const Duration(seconds: 2), () {
          trtcCloud.startLocalAudio(quality);
        });
      } else {
        await trtcCloud.startLocalAudio(quality);
      }
    }

    screenUserList = MeetingTool.getScreenList(userList);
    meetModel.setList(userList);
    setState(() {});
  }

  destoryRoom() {
    trtcCloud.unRegisterListener(onRtcListener);
    trtcCloud.exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  @override
  dispose() async {
    destoryRoom();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  /// Event callbacks
  onRtcListener(type, param) async {
    if (type == TRTCCloudListener.onError) {
      if (param['errCode'] == -1308) {
        MeetingTool.toast('Failed to start screen recording', context);
        await trtcCloud.stopScreenCapture();
        userList[0]['visible'] = true;
        isShowingWindow = false;
        setState(() {});
        trtcCloud.startLocalPreview(isFrontCamera, localViewId);
      } else {
        param['errMsg'];
      }
    }
    if (type == TRTCCloudListener.onEnterRoom && param > 0) {
        MeetingTool.toast('Enter room success', context);
    }
    if (type == TRTCCloudListener.onExitRoom&&param > 0) {
        MeetingTool.toast('Exit room success', context);
    }
    // Remote user entry
    if (type == TRTCCloudListener.onRemoteUserEnterRoom) {
      userList.add({
        'userId': param,
        'type': 'video',
        'visible': false,
        'size': {'width': 0, 'height': 0}
      });
      screenUserList = MeetingTool.getScreenList(userList);
      setState(() {});
      meetModel.setList(userList);
    }
    // Remote user leaves room
    if (type == TRTCCloudListener.onRemoteUserLeaveRoom) {
      String userId = param['userId'];
      for (var i = 0; i < userList.length; i++) {
        if (userList[i]['userId'] == userId) {
          userList.removeAt(i);
        }
      }
      //The user who is amplifying the video exit room
      if (doubleUserId == userId) {
        isDoubleTap = false;
      }
      screenUserList = MeetingTool.getScreenList(userList);
      setState(() {});
      meetModel.setList(userList);
    }
    _onRtcListener(type, param);
  }

  _onRtcListener(type, param) async{
    if (type == TRTCCloudListener.onUserVideoAvailable) {
      String userId = param['userId'];

      if (param['available']) {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'video') {
            userList[i]['visible'] = true;
          }
        }
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'video') {
            if (isDoubleTap &&
                doubleUserId == userList[i]['userId'] &&
                doubleUserIdType == userList[i]['type']) {}
            trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
            userList[i]['visible'] = false;
          }
        }
      }

      screenUserList = MeetingTool.getScreenList(userList);
      setState(() {});
      meetModel.setList(userList);
    }

    if (type == TRTCCloudListener.onUserSubStreamAvailable) {
      String userId = param["userId"];
      if (param["available"]) {
        userList.add({
          'userId': userId,
          'type': 'subStream',
          'visible': true,
          'size': {'width': 0, 'height': 0}
        });
      } else {
        for (var i = 0; i < userList.length; i++) {
          if (userList[i]['userId'] == userId &&
              userList[i]['type'] == 'subStream') {
            if (isDoubleTap &&
                doubleUserId == userList[i]['userId'] &&
                doubleUserIdType == userList[i]['type']) {}
            trtcCloud.stopRemoteView(
                userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB);
            userList.removeAt(i);
          }
        }
      }
      screenUserList = MeetingTool.getScreenList(userList);
      setState(() {});
      meetModel.setList(userList);
    }
  }


  Future<bool?> showErrordDialog(errorMsg) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tips"),
          content: Text(errorMsg),
          actions: <Widget>[
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showExitMeetingConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tips"),
          content: const Text("Are you sure to exit the meeting?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget renderView(item, valueKey, width, height) {
    return TRTCCloudVideoView(
        key: valueKey,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
        viewMode: TRTCCloudDef.TRTC_VideoView_Model_Virtual,
        onViewCreated: (viewId) async {
          if (item['userId'] == userInfo['userId']) {
            await trtcCloud.startLocalPreview(isFrontCamera, viewId);
            setState(() {
              localViewId = viewId;
            });
          } else {
            trtcCloud.startRemoteView(
                item['userId'],
                item['type'] == 'video'
                    ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
                    : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
                viewId);
          }
          item['viewId'] = viewId;
        });
  }

  Widget topSetting() {
    return Align(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(meetId.toString(),
                  style: const TextStyle(fontSize: 20, color: Colors.white)),
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                onPressed: () async {
                  bool? delete = await showExitMeetingConfirmDialog();
                  if (delete != null) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Exit Meeting",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Beauty Switch',
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
                ],
              ),
            ],
          ),
          height: 50.0,
          color: const Color.fromRGBO(200, 200, 200, 0.4),
        ),
        alignment: Alignment.topCenter);
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

  Widget bottomSetting() {
    return Align(
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
          TextButton(
                  child: const Text('Beauty Settings'),
                  onPressed: () {
                    _showModalBeautySheet(context);
                  }),
            ],
          ),
          height: 70.0,
          color: const Color.fromRGBO(200, 200, 200, 0.4),
        ),
        alignment: Alignment.bottomCenter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRTC Page'),
        leading: IconButton(
            onPressed: () => {_onBackPress(true)},
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () async {
          return await _onBackPress(false);
        },
        child: Stack(
          children: <Widget>[
            ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: screenUserList.length,
                cacheExtent: 0,
                itemBuilder: (BuildContext context, index) {
                  var item = screenUserList[index];
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: const Color.fromRGBO(19, 41, 75, 1),
                    child: Wrap(
                      children: List.generate(
                        item.length,
                        (index) => LayoutBuilder(
                          key: ValueKey(item[index]['userId'] +
                              item[index]['type'] +
                              item[index]['size']['width'].toString()),
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            Size size = MeetingTool.getViewSize(
                                MediaQuery.of(context).size,
                                userList.length,
                                index,
                                item.length);
                            double width = size.width;
                            double height = size.height;
                            if (isDoubleTap) {
                              //Set the width and height of other video rendering to 1, otherwise the video will not be streamed
                              if (item[index]['size']['width'] == 0) {
                                width = 1;
                                height = 1;
                              }
                            }
                            ValueKey valueKey = ValueKey(item[index]['userId'] +
                                item[index]['type'] +
                                (isDoubleTap ? "1" : "0"));
                            if (item[index]['size']['width'] > 0) {
                              width = double.parse(
                                  item[index]['size']['width'].toString());
                              height = double.parse(
                                  item[index]['size']['height'].toString());
                            }
                            return SizedBox(
                              key: valueKey,
                              height: height,
                              width: width,
                              child: renderView(
                                  item[index], valueKey, width, height),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
            topSetting(),
            bottomSetting()
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPress(bool isBackBtn) async {
    await enableBeauty(false);
    if (isBackBtn) {
      Navigator.pop(context);
    }
    return true;
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
