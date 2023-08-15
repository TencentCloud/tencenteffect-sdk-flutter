//
//  XmagicApiManager.h
//  tencent_effect_flutter
//
//  Created by tao yue on 2022/6/12.
//  Copyright (c) 2020年 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
@import TXCustomBeautyProcesserPlugin;

NS_ASSUME_NONNULL_BEGIN

typedef void(^initXmagicResCallback)(bool success);
typedef void(^setLicenseCallback)(NSInteger authresult, NSString *errorMsg);
typedef void (^eventAICallBlock)(id event);
typedef void (^eventTipsCallBlock)(id event);
typedef void (^eventYTDataCallBlock)(id event);

@interface XmagicApiManager : NSObject

+ (instancetype)shareSingleton;

@property (nonatomic, copy) eventAICallBlock eventAICallBlock; //ai数据回调
@property (nonatomic, copy) eventTipsCallBlock eventTipsCallBlock;//tips数据回调
@property (nonatomic, copy) eventYTDataCallBlock eventYTDataCallBlock; //ytdata数据回调

//初始化美颜资源
-(void)initXmagicRes:(NSString *)resPath complete:(initXmagicResCallback)complete;

//鉴权
-(void)setLicense:(NSString *)licenseKey licenseUrl:(NSString *)licenseUrl completion:(setLicenseCallback)completion;

//获取TextureId
-(int)getTextureId:(ITXCustomBeautyVideoFrame * _Nonnull)srcFrame;

//设置美颜效果
-(void)updateProperty:(NSString *)json;

//设置日志等级
-(void)setXmagicLogLevel:(int)logLevel;

//判断当前的 license 授权支持哪些美颜（beauty和body）
-(NSString *)isBeautyAuthorized:(NSString *)jsonString;

//开启美颜增强模式
-(void)enableEnhancedMode;

//美颜性能模式
-(void)setDowngradePerformance;

//背景音乐是否静音
-(void)setAudioMute:(BOOL)mute;

//设置某个特性的开或关
- (void)setFeatureEnableDisable:(NSString *_Nonnull)featureName enable:(BOOL)enable;

//设置画面方向
- (void)setImageOrientation:(int)orientation;

-(void)onPause;

-(void)onResume;

-(void)onDestroy;

@end

NS_ASSUME_NONNULL_END
