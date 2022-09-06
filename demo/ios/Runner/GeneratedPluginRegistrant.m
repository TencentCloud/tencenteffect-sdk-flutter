//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<fluttertoast/FluttertoastPlugin.h>)
#import <fluttertoast/FluttertoastPlugin.h>
#else
@import fluttertoast;
#endif

#if __has_include(<image_picker_ios/FLTImagePickerPlugin.h>)
#import <image_picker_ios/FLTImagePickerPlugin.h>
#else
@import image_picker_ios;
#endif

#if __has_include(<live_flutter_plugin/TencentLiveCloudPlugin.h>)
#import <live_flutter_plugin/TencentLiveCloudPlugin.h>
#else
@import live_flutter_plugin;
#endif

#if __has_include(<path_provider_ios/FLTPathProviderPlugin.h>)
#import <path_provider_ios/FLTPathProviderPlugin.h>
#else
@import path_provider_ios;
#endif

#if __has_include(<permission_handler_apple/PermissionHandlerPlugin.h>)
#import <permission_handler_apple/PermissionHandlerPlugin.h>
#else
@import permission_handler_apple;
#endif

#if __has_include(<super_player/SuperPlayerPlugin.h>)
#import <super_player/SuperPlayerPlugin.h>
#else
@import super_player;
#endif

#if __has_include(<tencent_effect_flutter/TencentEffectFlutterPlugin.h>)
#import <tencent_effect_flutter/TencentEffectFlutterPlugin.h>
#else
@import tencent_effect_flutter;
#endif

#if __has_include(<tencent_trtc_cloud/TencentTRTCCloud.h>)
#import <tencent_trtc_cloud/TencentTRTCCloud.h>
#else
@import tencent_trtc_cloud;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FluttertoastPlugin registerWithRegistrar:[registry registrarForPlugin:@"FluttertoastPlugin"]];
  [FLTImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImagePickerPlugin"]];
  [TencentLiveCloudPlugin registerWithRegistrar:[registry registrarForPlugin:@"TencentLiveCloudPlugin"]];
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [SuperPlayerPlugin registerWithRegistrar:[registry registrarForPlugin:@"SuperPlayerPlugin"]];
  [TencentEffectFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"TencentEffectFlutterPlugin"]];
  [TencentTRTCCloud registerWithRegistrar:[registry registrarForPlugin:@"TencentTRTCCloud"]];
}

@end
