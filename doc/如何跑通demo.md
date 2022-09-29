# 如何跑通demo

## 环境要求

- Flutter 2.0 及以上版本。

**Android 端开发：**

- Android Studio 3.5及以上版本。

- App 要求 Android 5.0及以上版本设备。

**iOS & macOS 端开发：**

- Xcode 11.0及以上版本。

- osx 系统版本要求 10.11 及以上版本

- 请确保您的项目已设置有效的开发者签名。

## Android：

1.在demo下执行flutter pub get，然后使用Android studio 打开demo工程，直接点击run按钮。

## iOS ：

1.首次运行ios demo，进入到demo/ios/Flutter文件夹中，如果有flutter_export_environment.sh、Generated.xcconfig这两个文件，则删掉。

2.在demo下执行flutter pub get，然后进入到ios中执行pod install。

3.打开demo/ios里面的Runner.xcworkspace，编译完成以后即可运行。

**常见问题**

1.Visual Studio Code运行iOS端时报错“iOS Observatory not discovered after 30 seconds. This is taking much longer than expected”，无法Hot Reload

解决办法：在xcode中的Build Seetings的FLUTTER_BUILD_MODE的值改成debug

2.demo与xcode断开连接的时候无法运行

解决办法：在xcode中的Build Seetings的FLUTTER_BUILD_MODE的值改成release