# 如何跑通demo

## Android：

1.在demo下执行flutter pub get，然后使用Android studio 打开demo工程，直接点击run按钮。

## iOS ：

1.首次运行ios demo，进入到demo/ios/Flutter文件夹中，如果有flutter_export_environment.sh、Generated.xcconfig这两个文件，则删掉。

2.在demo下执行flutter pub get，然后进入到ios中执行pod install。

3.打开demo/ios里面的Runner.xcworkspace，编译完成以后即可运行。