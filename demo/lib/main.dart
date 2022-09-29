import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_effect_flutter/api/tencent_effect_api.dart';
import 'package:tencent_effect_flutter/utils/Logs.dart';
import 'package:tencent_effect_flutter_demo/languages/app_localization_delegate.dart';
import 'package:tencent_effect_flutter_demo/page/superplayer_page.dart';
import 'package:tencent_effect_flutter_demo/page/trtc_camera_preview_page.dart';
import 'package:tencent_effect_flutter_demo/view/progress_dialog.dart';
import 'producer/beauty_data_manager.dart';
import 'page/live_camera_preview_page.dart';

//授权使用的license 信息
const String licenseUrl =
    "https://license.vod2.myqcloud.com/license/v2/1258289294_1/v_cube.license";
const String licenseKey = "3c16909893f53b9600bc63941162cea3";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate, //对布局方向进行国际化
          GlobalMaterialLocalizations.delegate, //对Material Widgets进行了国际化，
          GlobalCupertinoLocalizations.delegate, //对Cupertino Widgets进行了国际化
          APPLocalizationDelegate.delegate
        ],
        supportedLocales: const [
          Locale.fromSubtags(languageCode: 'en'),
          Locale.fromSubtags(languageCode: 'zh')
        ],
        initialRoute: "/",
        routes: <String, WidgetBuilder>{
          '/homepage': (BuildContext context) => const HomePage(),
          '/cameraBeautyPage_Live': (BuildContext context) =>
              const LiveCameraPushPage(),
          '/cameraBeautyPage_Trtc': (BuildContext context) =>
              const TrtcCameraPreviewPage(),
          '/playerpage': (BuildContext context) => const PlayerPage(),
        },
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {

  static const String TAG = "_HomeState";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tencent Effect demo'),
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () => {_onCameraPressedLive(context)},
              child: const Text('Live',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          TextButton(
              onPressed: () => {_onCameraPressedTrtc(context)},
              child: const Text('Trtc',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          TextButton(
              onPressed: () => {_onPlayerPressed(context)},
              child: const Text('Player',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
        ],
      )),
    );
  }

  bool _isInitResource = false;

  void _initResource(InitXmagicCallBack callBack) async {
    if (_isInitResource) {
      callBack.call(true);
      return;
    }

    String dir = await BeautyDataManager.getInstance().getResDir();
    TXLog.printlog('$TAG method is _initResource ,xmagic resource dir is $dir');
    TencentEffectApi.getApi()?.initXmagic(dir, (reslut) {
      _isInitResource = reslut;
      callBack.call(reslut);
      if (!reslut) {
        Fluttertoast.showToast(msg: "initialization failed");
      }
    });
  }

  void _onCameraPressedLive(BuildContext context) {
    _showDialog(context);
    _initResource((reslut) {
      if (reslut) {
        TencentEffectApi.getApi()?.setLicense(licenseKey, licenseUrl,
            (errorCode, msg) {
          _dismissDialog(context);
          TXLog.printlog('$TAG  setLicense result : errorCode =$errorCode ,msg = $msg');
          if (errorCode == 0) {
            _requestPermission(context, 0);
          }
        });
      } else {
        _dismissDialog(context);
      }
    });
  }

  ///跳转到播放器
  ///action player page
  void _onPlayerPressed(BuildContext context) {
    Navigator.of(context).pushNamed("/playerpage");
  }

  void _onCameraPressedTrtc(BuildContext context) {
    _showDialog(context);
    _initResource((reslut) {
      if (reslut) {
        TencentEffectApi.getApi()?.setLicense(licenseKey, licenseUrl,
            (errorCode, msg) {
          _dismissDialog(context);
          TXLog.printlog('$TAG  setLicense result : errorCode =$errorCode ,msg = $msg');
          if (errorCode == 0) {
            _requestPermission(context, 1);
          }
        });
      } else {
        _dismissDialog(context);
      }
    });
  }

  void _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return const ProgressDialog();
        });
  }

  ///关闭对话框
  ///dismiss dialog
  _dismissDialog(BuildContext context) {
    Navigator.of(context).pop(true);
  }

  void _requestPermission(BuildContext context, int pageType) async {
    ///开始申请权限
    ///request permission
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    if (statuses[Permission.camera] != PermissionStatus.denied &&
        statuses[Permission.microphone] != PermissionStatus.denied) {
      if (pageType == 0) {
        Navigator.of(context).pushNamed("/cameraBeautyPage_Live");
      } else if (pageType == 1) {
        Navigator.of(context).pushNamed("/cameraBeautyPage_Trtc");
      }
    }
  }
}
