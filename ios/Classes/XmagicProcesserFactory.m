//
//  XmagicProcesserFactory.m
//  tencent_effect_flutter
//
//  Created by tao yue on 2022/5/24.
//  Copyright (c) 2020年 Tencent. All rights reserved.

#import "XmagicProcesserFactory.h"
#import "XmagicApiManager.h"

@implementation XmagicProcesserFactory

- (id<ITXCustomBeautyProcesser> _Nonnull)createCustomBeautyProcesser {
    [[XmagicApiManager shareSingleton] onDestroy]; //避免上一个xmagic未被销毁
    return self;
}

- (void)destroyCustomBeautyProcesser {
    [[XmagicApiManager shareSingleton] onDestroy];
}

- (enum ITXCustomBeautyPixelFormat)getSupportedPixelFormat {
    return ITXCustomBeautyPixelFormatTexture2D;
}

- (enum ITXCustomBeautyBufferType)getSupportedBufferType {
    return ITXCustomBeautyBufferTypeTexture;
}

- (ITXCustomBeautyVideoFrame * _Nonnull)onProcessVideoFrameWithSrcFrame:(ITXCustomBeautyVideoFrame * _Nonnull)srcFrame
    dstFrame:(ITXCustomBeautyVideoFrame * _Nonnull)dstFrame {
    dstFrame.textureId = [[XmagicApiManager shareSingleton] getTextureId:srcFrame];
    return dstFrame;
}

@end
