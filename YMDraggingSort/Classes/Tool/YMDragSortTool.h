//
//  YMDragSortTool.h
//  YMDraggingSort
//
//  Created by lantaiyuan on 16/12/23.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMDragSortTool : NSObject
@property (nonatomic,assign) BOOL isEditing;
/** 标签列表 */
@property (nonatomic,strong) NSMutableArray * subscribeArray;

@property (nonatomic, strong) NSMutableArray * recommendSubscribes;
+ (instancetype)shareInstance;
@end
