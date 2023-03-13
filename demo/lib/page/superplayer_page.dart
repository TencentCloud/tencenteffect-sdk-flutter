import 'package:flutter/material.dart';
import 'package:super_player/super_player.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestState();
}

class _TestState extends State<PlayerPage>  with WidgetsBindingObserver{
  late TXVodPlayerController _controller;

  final double _aspectRatio = 16.0 / 9.0;
  final String _url = "http://1400329073.vod2.myqcloud.com/d62d88a7vodtranscq1400329073/59c68fe75285890800381567412/adp.10.m3u8";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    String licenceUrl = ""; // 获取到的 licence url
    String licenseKey = ""; // 获取到的 licence key
    SuperPlayerPlugin.setGlobalLicense(licenceUrl, licenseKey);
    _controller = TXVodPlayerController();
    initPlayer();
  }

  Future<void> initPlayer() async {
    await _controller.initialize();
    _controller.setConfig(FTXVodPlayConfig());
    await _controller.startVodPlay(_url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 220,
            color: Colors.black,
            child: AspectRatio(
                aspectRatio: _aspectRatio,
                child: TXPlayerVideo(controller: _controller)))
      ],
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed: //Switch from the background to the foreground, and the interface is visible
        _controller.resume();
        break;
      case AppLifecycleState.paused: // Interface invisible, background
        _controller.pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
  }
}
