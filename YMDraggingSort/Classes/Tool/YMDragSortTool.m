//
//  YMDragSortTool.m
//  YMDraggingSort
//
//  Created by lantaiyuan on 16/12/23.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import "YMDragSortTool.h"

@implementation YMDragSortTool

static YMDragSortTool * DragSortTool = nil;

+ (instancetype)shareInstance{
    @synchronized (self) {
        if (DragSortTool == nil) {
            DragSortTool = [[self alloc] init];
        }
    }
    return DragSortTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (DragSortTool == nil) {
            DragSortTool = [super allocWithZone:zone];
        }
    }
    return DragSortTool;
}

- (id)copy{
    return DragSortTool;
}

- (id)mutableCopy{
    return DragSortTool;
}

- (NSMutableArray *)subscribeArray {
    
    if (!_subscribeArray) {
        
        _subscribeArray = [@[@"推荐", @"热点", @"深圳", @"视频", @"社会", @"头条号", @"问答", @"娱乐", @"图片", @"科技", @"汽车", @"军事", @"国际", @"段子", @"趣图", @"健康", @"正能量", @"特卖", @"游戏", @"情感", @"星座", @"旅游", @"电影", @"养生", @"宠物", @"科学", @"房产", @"家居", @"财经"] mutableCopy];
    }
    return _subscribeArray;
}

- (NSMutableArray *)recommendSubscribes{
    if (!_recommendSubscribes) {
        _recommendSubscribes = [@[@"小说", @"精选", @"时尚", @"辟谣", @"奇葩", @"育儿", @"美食", @"政务", @"历史", @"探索", @"故事", @"美文", @"美图", @"搞笑", @"文化", @"教育", @"美女", @"三农", @"收藏", @"语录", @"手机", @"孕产", @"股票", @"动漫", @"中国新唱将", @"体育", @"直播", @"数码", @"火山直播", @"彩票"]  mutableCopy];
    }
    return _recommendSubscribes;
}

@end
