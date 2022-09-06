//
//  XmagicProcesserFactory.h
//  tencent_effect_flutter
//
//  Created by tao yue on 2022/5/24.
//  Copyright (c) 2020年 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
@import TXCustomBeautyProcesserPlugin;

NS_ASSUME_NONNULL_BEGIN

/**
 实现TRTC或者Live协议的类
 */
@interface XmagicProcesserFactory : NSObject<ITXCustomBeautyProcesserFactory,ITXCustomBeautyProcesser>

@end

NS_ASSUME_NONNULL_END
