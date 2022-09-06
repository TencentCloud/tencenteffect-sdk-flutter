//
//  TencentEffectFlutterPlugin.m
//  tencent_effect_flutter
//
//  Created by tao yue on 2022/6/12.
//  Copyright (c) 2020年 Tencent. All rights reserved.

#import "TencentEffectFlutterPlugin.h"
#import "XmagicApiManager.h"

@interface TencentEffectFlutterPlugin() <FlutterStreamHandler>
 
@property (nonatomic, strong) FlutterEventSink eventSink;

 
@end

@implementation TencentEffectFlutterPlugin

static TencentEffectFlutterPlugin* _instance = nil;

+ (TencentEffectFlutterPlugin *)shareInstance {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        //不是使用alloc方法，而是调用[[super allocWithZone:NULL] init]
        //已经重载allocWithZone基本的对象分配方法，所以要借用父类（NSObject）的功能来帮助出处理底层内存分配的杂物
    }) ;
    return _instance ;
}
 
 //用alloc返回也是唯一实例
+(id) allocWithZone:(struct _NSZone *)zone {
    
    return [TencentEffectFlutterPlugin shareInstance] ;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"tencent_effect_methodChannel_call_native"
            binaryMessenger:[registrar messenger]];
  TencentEffectFlutterPlugin* instance = [[TencentEffectFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
  FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"tencent_effect_methodChannel_call_flutter" binaryMessenger:[registrar messenger]];
  [eventChannel setStreamHandler:instance];

}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if ([@"initXmagic" isEqualToString:call.method]) {
      result(nil);
      [self initXmagic:call.arguments];
      [self setDataCallBack];
  }else if ([@"isSupportBeauty" isEqualToString:call.method]) {
      result(@true);
  }else if ([@"setLicense" isEqualToString:call.method]) {
      result(nil);
      NSString *licenseKey = call.arguments[@"licenseKey"];
      NSString *licenseUrl = call.arguments[@"licenseUrl"];
      [self setLicense:licenseKey licenseUrl:licenseUrl];
  }else if ([@"setXmagicLogLevel" isEqualToString:call.method]) {
      [[XmagicApiManager shareSingleton] setXmagicLogLevel:[call.arguments intValue]];
      result(nil);
  }else if ([@"updateProperty" isEqualToString:call.method]) {
      result(nil);
      [[XmagicApiManager shareSingleton] updateProperty:call.arguments];
  }else if ([@"onPause" isEqualToString:call.method]) {
      [[XmagicApiManager shareSingleton] onPause];
  }else if ([@"onResume" isEqualToString:call.method]) {
      [[XmagicApiManager shareSingleton] onResume];
  }else if ([@"onDestroy" isEqualToString:call.method]) {      [[XmagicApiManager shareSingleton] onDestroy];
  }else if ([@"isBeautyAuthorized" isEqualToString:call.method]) {
      NSString *res = [[XmagicApiManager shareSingleton] isBeautyAuthorized:call.arguments];
      result(res);
  }else if ([@"isDeviceSupport" isEqualToString:call.method]) {
      NSString *res = [self isDeviceSupport:call.arguments];
      result(res);
  }else if ([@"getPropertyRequiredAbilities" isEqualToString:call.method]) {
      result(nil);
  }else if ([@"getDeviceAbilities" isEqualToString:call.method]) {
      result(nil);
  }else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)setLicense:(NSString *)licenseKey licenseUrl:(NSString *)licenseUrl{
    [[XmagicApiManager shareSingleton] setLicense:licenseKey licenseUrl:licenseUrl completion:^(NSInteger authresult, NSString * _Nonnull errorMsg) {
        if (self.eventSink){
            NSDictionary *result = @{@"methodName":@"onLicenseCheckFinish", @"code":@(authresult),@"msg":errorMsg};
            self.eventSink(result);
        }
    }];
}

-(void)initXmagic:(NSString *)resPath{
    [[XmagicApiManager shareSingleton] initXmagicRes:resPath complete:^(bool success) {
        if (self.eventSink){
            NSDictionary *result;
            if (success) {
                result = @{@"methodName":@"initXmagic", @"data":@true};
            }else{
                result = @{@"methodName":@"initXmagic", @"data":@false};
            }
            self.eventSink(result);
        }
    }];
}

-(void)setDataCallBack{
    [XmagicApiManager shareSingleton].eventAICallBlock = ^(id  _Nonnull event) {
        NSDictionary *eventDict = (NSDictionary *)event;
        NSDictionary *result;
        if (eventDict[@"face_info"] != nil) {
            result = @{@"methodName":@"aidata_onFaceDataUpdated", @"data":[self mapToString:eventDict]};
        } else if (eventDict[@"hand_info"] != nil) {
            result = @{@"methodName":@"aidata_onHandDataUpdated", @"data":[self mapToString:eventDict]};
        } else if (eventDict[@"body_info"] != nil) {
            result = @{@"methodName":@"aidata_onBodyDataUpdated", @"data":[self mapToString:eventDict]};
        }
        if (self.eventSink){
            self.eventSink(result);
        }
    };
    [XmagicApiManager shareSingleton].eventTipsCallBlock = ^(id  _Nonnull event) {
        NSDictionary *eventDict = (NSDictionary *)event;
        NSDictionary *result;
        int timeCount = eventDict[@"duration"]==nil?3:([eventDict[@"duration"] intValue]/1000);
        if ([eventDict[@"need_show"] boolValue] == YES){
            result = @{@"methodName":@"tipsNeedShow", @"tips":eventDict[@"tips"],@"tipsIcon":eventDict[@"tips_icon"],@"type":eventDict[@"tips_type"],@"duration":@(timeCount)};
        }else{
            result = @{@"methodName":@"tipsNeedHide", @"tips":eventDict[@"tips"],@"tipsIcon":eventDict[@"tips_icon"],@"type":eventDict[@"tips_type"],@"duration":@(timeCount)};
        }
        if (self.eventSink){
            self.eventSink(result);
        }
    };
    [XmagicApiManager shareSingleton].eventYTDataCallBlock = ^(id  _Nonnull event) {
        NSDictionary *eventDict = (NSDictionary *)event;
        NSDictionary *result = @{@"methodName":@"onYTDataUpdate", @"data":[self mapToString:eventDict]};
        if (self.eventSink){
            self.eventSink(result);
        }
    };
}

-(NSDictionary *)stringToMap:(NSString *)string{
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return  dict;
}

-(NSString *)mapToString:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return  string;
}

-(NSString *)isDeviceSupport:(NSString *)jsonString{
    NSString *result;
    NSDictionary *dictionary = [self stringToMap:jsonString];
    for(id dic in dictionary){
        dic[@"isSupport"] = @true;
    }
    result = [self mapToString:dictionary];
    return  result;
}

#pragma mark - FlutterStreamHandler
 
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}
 
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

@end
