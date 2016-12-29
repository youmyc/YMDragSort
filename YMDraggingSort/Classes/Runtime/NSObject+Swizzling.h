//
//  NSObject+Swizzling.h
//  YMPalceholder
//
//  Created by lantaiyuan on 16/12/28.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzling)
+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector
                         bySwizzledSelector:(SEL)swizzledSelector;
@end
