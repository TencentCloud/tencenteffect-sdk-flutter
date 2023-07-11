//
//  XmagicApiManager.m
//  tencent_effect_flutter
//
//  Created by tao yue on 2022/6/12.
//  Copyright (c) 2020年 Tencent. All rights reserved.

#import "XmagicApiManager.h"
#import "XMagic.h"
#import "YTCommonXMagic/TELicenseCheck.h"

#define VERBOSE_LEVEL 2
#define DEBUG_LEVEL   3
#define INFO_LEVEL    4
#define WARN_LEVEL    5
#define ERROR_LEVEL   6
#define DEFAULT_LEVEL 7
#define UNKNOWN_LEVEL 8

#define CATEGORY_BEAUTY @"BEAUTY"
#define CATEGORY_LUT @"LUT"
#define CATEGORY_MOTION @"MOTION"
#define CATEGORY_SEGMENTATION @"SEGMENTATION"
#define CATEGORY_BODY_BEAUTY @"BODY_BEAUTY"
#define CATEGORY_MAKEUP @"MAKEUP"

static const int MAX_SEG_VIDEO_DURATION = 200 * 1000;//视频长度限制

@interface XmagicApiManager()<YTSDKEventListener, YTSDKLogListener>

@property (nonatomic, strong) XMagic          *xMagicApi;
@property (assign, nonatomic) NSUInteger       heightF;
@property (assign, nonatomic) NSUInteger       widthF;
@property (nonatomic, strong) NSString        *xmagicResPath;//resource path
@property (nonatomic, strong) NSString                  *makeup;//设置美妆时，只需要进行一次动效设置
@property (nonatomic, strong) NSArray *resNames;  //resource name
@property (nonatomic, strong) NSLock  *lock;

@end

@implementation XmagicApiManager

static XmagicApiManager *shareSingleton = nil;
 
+ (instancetype)shareSingleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSingleton = [[super allocWithZone:NULL] init];
    });
    return shareSingleton;
}
 
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [XmagicApiManager shareSingleton];
}
 
- (id)copyWithZone:(struct _NSZone *)zone {
    return [XmagicApiManager shareSingleton];
}

//init resource
//初始化美颜资源
-(void)initXmagicRes:(NSString *)resPath complete:(initXmagicResCallback)complete{
    [self initResName];
    if ([[NSFileManager  defaultManager] fileExistsAtPath:resPath]){
        [[NSFileManager defaultManager] removeItemAtPath:resPath error:nil];
    }
    [[NSFileManager  defaultManager] createDirectoryAtPath:resPath withIntermediateDirectories:YES attributes:nil error:NULL];
    NSError *error = nil;
    for (int i = 0; i < _resNames.count; i++) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:_resNames[i] ofType:@"bundle"];
        if (bundlePath !=nil) {
            NSString *path = [NSString stringWithFormat:@"%@/%@.bundle",resPath,_resNames[i]];
            [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:path error:&error];
            if (error != nil) {
                NSLog(@"xmagic init resource error：%@",error.description);
                break;
            }
        }

    }
    if (complete != nil) {
        self.xmagicResPath = resPath;
        complete(error == nil);
    }
}

-(void)initResName{
    _resNames = @[@"Light3DPlugin",@"LightBodyPlugin",@"LightCore",
    @"LightHandPlugin",@"LightSegmentPlugin",@"makeupMotionRes",@"2dMotionRes",
    @"3dMotionRes",@"ganMotionRes",@"handMotionRes",@"lut",@"segmentMotionRes"];
    _lock = [[NSLock alloc] init];
}

//Authentication
//鉴权
-(void)setLicense:(NSString *)licenseKey licenseUrl:(NSString *)licenseUrl completion:(setLicenseCallback)completion{
    [TELicenseCheck setTELicense:licenseUrl key:licenseKey completion:^(NSInteger authresult, NSString * _Nonnull errorMsg) {
        if(completion != nil){
            completion(authresult,errorMsg);
        }
    }];
}

//Set sdk log level
//设置sdk日志等级
-(void)setXmagicLogLevel:(int)logLevel{
    if (self.xMagicApi != nil) {
        if (logLevel == VERBOSE_LEVEL) {
            [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_VERBOSE_LEVEL];
        }else if(logLevel == DEBUG_LEVEL){
            [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_DEBUG_LEVEL];
        }else if (logLevel == INFO_LEVEL){
            [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_INFO_LEVEL];
        }else if (logLevel == WARN_LEVEL){
            [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_WARN_LEVEL];
        }else if (logLevel == ERROR_LEVEL){
            [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_ERROR_LEVEL];
        }else if (logLevel == DEFAULT_LEVEL){
            [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_DEFAULT_LEVEL];
        }else{
            [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_UNKNOWN_LEVEL];
        }
    }
}

-(void)onPause{
    if (self.xMagicApi != nil) {
        [self.xMagicApi onPause];
    }
}

-(void)onResume{
    if (self.xMagicApi != nil) {
        [self.xMagicApi onResume];
    }
}

-(void)onDestroy{
    if (self.xMagicApi != nil) {
        [_lock lock];
        [self.xMagicApi deinit];
        self.xMagicApi = nil;
        [_lock unlock];
    }
}

//Determine which beauties (beauty and body) are supported by the current license authorization
//判断当前的 license 授权支持哪些美颜（beauty和body）
-(NSString *)isBeautyAuthorized:(NSString *)jsonString{
    NSString *result;
    NSDictionary *dictionary = [self stringToMap:jsonString];
    for(id dic in dictionary){
        if ([XMagic isBeautyAuthorized:dic[@"effKey"]]) {
            dic[@"isAuth"] = @true;
        }else{
            dic[@"isAuth"] = @false;
        }
    }
    result = [self mapToString:dictionary];
    return  result;
}

- (void)enableEnhancedMode{
    if (self.xMagicApi != nil) {
        [self.xMagicApi enableEnhancedMode];
    }
}

//build sdk
//创建sdk
- (void)buildBeautySDK:(int)width and:(int)height texture:(unsigned)textureID {
    NSString *beautyConfigPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    beautyConfigPath = [beautyConfigPath stringByAppendingPathComponent:@"beauty_config.json"];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    BOOL isDir = YES;
    NSDictionary * beautyConfigJson = @{};
    if ([localFileManager fileExistsAtPath:beautyConfigPath isDirectory:&isDir] && !isDir) {
        NSString *beautyConfigJsonStr = [NSString stringWithContentsOfFile:beautyConfigPath encoding:NSUTF8StringEncoding error:nil];
        NSError *jsonError;
        NSData *objectData = [beautyConfigJsonStr dataUsingEncoding:NSUTF8StringEncoding];
        beautyConfigJson = [NSJSONSerialization JSONObjectWithData:objectData
        options:NSJSONReadingMutableContainers error:&jsonError];
    }
    NSDictionary *assetsDict = @{@"core_name":@"LightCore.bundle",
                                 @"root_path":self.xmagicResPath,
                                 @"plugin_3d":@"Light3DPlugin.bundle",
                                 @"plugin_hand":@"LightHandPlugin.bundle",
                                 @"plugin_segment":@"LightSegmentPlugin.bundle",
                                 @"beauty_config":beautyConfigJson
    };

    // Init beauty kit
   self.xMagicApi = [[XMagic alloc] initWithRenderSize:CGSizeMake(width,height) assetsDict:assetsDict];
   [self.xMagicApi registerSDKEventListener:self];
   [self.xMagicApi registerLoggerListener:self withDefaultLevel:YT_SDK_ERROR_LEVEL];
   
    _makeup = @"";
    [self.xMagicApi configPropertyWithType:@"beauty" withName:@"beauty.whiten" withData:@"1" withExtraInfo:nil];
}


//Set beauty effects
//设置美颜效果
-(void)updateProperty:(NSString *)json{
    if (self.xMagicApi == nil) {
        return;
    }
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString* category = jsonDic[@"category"];
    if ([category isEqual:CATEGORY_BEAUTY]) {
        _makeup = @"";
        [self.xMagicApi configPropertyWithType:@"beauty" withName:
         jsonDic[@"effKey"] withData:jsonDic[@"effValue"][@"currentDisplayValue"]
        withExtraInfo:[self stringToMap:[self getString:jsonDic[@"id"]]]];
    }else if([category isEqual:CATEGORY_LUT]){
        _makeup = @"";
        if ([jsonDic[@"id"] isEqual:@"ID_NONE"]) {
            [self.xMagicApi configPropertyWithType:@"lut" withName:jsonDic[@"id"] withData:@"0" withExtraInfo:nil];
        }else{
            [self.xMagicApi configPropertyWithType:@"lut" withName:jsonDic[@"resPath"] withData:jsonDic[@"effValue"][@"currentDisplayValue"] withExtraInfo:nil];
        }
    }else if([category isEqual:CATEGORY_MOTION]){
        _makeup = @"";
        [self.xMagicApi configPropertyWithType:@"motion" withName:jsonDic[@"id"] withData:[self getString:jsonDic[@"resPath"]] withExtraInfo:nil];
    }else if ([category isEqual:CATEGORY_SEGMENTATION]){
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH.mm.ss"];
        NSURL *newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]];
        _makeup = @"";
        if ([jsonDic[@"id"] isEqual:@"video_empty_segmentation"]) {
            if ([jsonDic[@"effKey"] isEqual:[NSNull null]]) {
                return;
            }
            AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:jsonDic[@"effKey"]]];
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if(tracks.count == 0){ //图片
                NSDictionary *dic = @{@"bgName":jsonDic[@"effKey"], @"bgType":@0, @"timeOffset": @0};
                [self.xMagicApi configPropertyWithType:@"motion" withName:@"video_empty_segmentation" withData:jsonDic[@"resPath"] withExtraInfo:dic];
            }else{//视频
                [self convertVideoQuailtyWithInputAVURLAsset:asset outputURL:newVideoUrl resPath:jsonDic[@"resPath"]];
            }
        }else{
            [self.xMagicApi configPropertyWithType:@"motion" withName:[self getString:
            jsonDic[@"id"]] withData:[self getString:jsonDic[@"resPath"]]
            withExtraInfo:@{@"bgName":@"BgSegmentation.bg.png", @"bgType":@0, @"timeOffset": @0}];
        }
    }else if([category isEqual:CATEGORY_BODY_BEAUTY]){
        _makeup = @"";
        [self.xMagicApi configPropertyWithType:@"body" withName:jsonDic[@"effKey"] withData:jsonDic[@"effValue"][@"currentDisplayValue"] withExtraInfo:nil];
    }else if ([category isEqual:CATEGORY_MAKEUP]){
        if(![_makeup isEqual:jsonDic[@"id"]]){
            _makeup = jsonDic[@"id"];
            [self.xMagicApi configPropertyWithType:@"motion" withName:jsonDic[@"id"] withData:[self getString:jsonDic[@"resPath"]] withExtraInfo:nil];
            _makeup = jsonDic[@"id"];
        }
        if ([jsonDic[@"id"] isEqual:@"ID_NONE"]) {
            [self.xMagicApi configPropertyWithType:@"custom" withName:@"makeup.strength" withData:@"0" withExtraInfo:nil];
        }else{
            [self.xMagicApi configPropertyWithType:@"custom" withName:@"makeup.strength" withData:jsonDic[@"effValue"][@"currentDisplayValue"] withExtraInfo:nil];
        }
    }
}

// Video compression and transcoding
// 视频压缩转码处理
-(void)convertVideoQuailtyWithInputAVURLAsset:(AVURLAsset*)avAsset
                              outputURL:(NSURL*)outputURL
                                       resPath:(NSString *)resPath {
    CMTime videoTime = [avAsset duration];
    int timeOffset = ceil(1000 * videoTime.value / videoTime.timescale) - 10;
    if (timeOffset > MAX_SEG_VIDEO_DURATION) {
        NSLog(@"TencentEffectFlutter:background video too long(limit %i)",
              MAX_SEG_VIDEO_DURATION);
        return;
    }
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
    initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"AVAssetExportSessionStatusCancelled");
                break;
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"AVAssetExportSessionStatusUnknown");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"AVAssetExportSessionStatusWaiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"AVAssetExportSessionStatusExporting");
                break;
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"AVAssetExportSessionStatusCompleted");
                NSDictionary *dic = @{@"bgName":outputURL.path, @"bgType":@1, @"timeOffset": [NSNumber numberWithInt:timeOffset]};
                [self.xMagicApi configPropertyWithType:@"motion"
                withName:@"video_empty_segmentation" withData:resPath withExtraInfo:dic];
            }
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AVAssetExportSessionStatusFailed");
                break;
        }
    }];
    if (exportSession.status == AVAssetExportSessionStatusFailed) {
        NSLog(@"TencentEffectFlutter:background video export failed");
    }
}


//return TextureId
//获取TextureId
-(int)getTextureId:(ITXCustomBeautyVideoFrame * _Nonnull)srcFrame{
    [_lock lock];
    if (self.xMagicApi == nil) {
        [self buildBeautySDK:srcFrame.width and:srcFrame.height texture:srcFrame.textureId];
        self.heightF = srcFrame.height;
        self.widthF = srcFrame.width;
    }
    if(self.xMagicApi!=nil && (self.heightF != srcFrame.height || self.widthF != srcFrame.width)){
        [self.xMagicApi setRenderSize:CGSizeMake(srcFrame.width, srcFrame.height)];
        self.heightF = srcFrame.height;
        self.widthF = srcFrame.width;
    }
    YTProcessInput *input = [[YTProcessInput alloc] init];
    input.textureData = [[YTTextureData alloc] init];
    input.textureData.texture = srcFrame.textureId;
    input.textureData.textureWidth = srcFrame.width;
    input.textureData.textureHeight = srcFrame.height;
    input.dataType = kYTTextureData;
    YTProcessOutput *output = [self.xMagicApi process:input withOrigin:YtLightImageOriginTopLeft withOrientation:YtLightCameraRotation0];
    [_lock unlock];
    return output.textureData.texture;
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

-(NSString *)getString:(NSString *)string{
    if ([string isEqual:[NSNull null]]) {
        return @"";
    }
    return string;
}

#pragma mark - YTSDKEventListener

- (void)onAIEvent:(id _Nonnull)event {
    if(_eventAICallBlock != nil){
        _eventAICallBlock(event);
    }
}

- (void)onAssetEvent:(id _Nonnull)event {
    
}

- (void)onTipsEvent:(id _Nonnull)event {
    if(_eventTipsCallBlock != nil){
        _eventTipsCallBlock(event);
    }
}

- (void)onYTDataEvent:(id _Nonnull)event {
    if(_eventYTDataCallBlock != nil){
        _eventYTDataCallBlock(event);
    }
}

#pragma mark - YTSDKLogListener

- (void)onLog:(YtSDKLoggerLevel)loggerLevel withInfo:(NSString * _Nonnull)logInfo {
    NSLog(@"[%ld]-%@", (long)loggerLevel, logInfo);
}
@end
