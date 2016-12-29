//
//  YMDargSortCell.h
//  YMDraggingSort
//
//  Created by lantaiyuan on 16/12/23.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YMDargSortCell;
@protocol  YMDargSortCellDelegate<NSObject>

- (void)dragSortCell:(YMDargSortCell *)cell longGesture:(UIGestureRecognizer *)gestureRecognizer;

- (void)dragSortCell:(YMDargSortCell *)cell tapGesture:(UIGestureRecognizer *)gestureRecognizer;

- (void)dragSortCell:(YMDargSortCell *)cell cancelSubscribe:(NSString *)subscribe;
@end

@interface YMDargSortCell : UICollectionViewCell
@property (nonatomic, copy) NSString * subscribe;
@property (nonatomic, weak) id<YMDargSortCellDelegate> delegate;

- (void)showDeleteBtn;
- (void)hideDeleteBtn:(BOOL)hiden;
@end
