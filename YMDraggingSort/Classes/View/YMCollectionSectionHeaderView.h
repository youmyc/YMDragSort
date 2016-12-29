//
//  YMCollectionSectionHeaderView.h
//  YMDraggingSort
//
//  Created by lantaiyuan on 16/12/26.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBtnBlock)();

@class YMCollectionSectionHeaderView;
@protocol YMCollectionSectionHeaderViewDelegate <NSObject>

- (void)sectionHeaderView:(YMCollectionSectionHeaderView *)view clickButton:(UIButton *)button;

@end

@interface YMCollectionSectionHeaderView : UIView

@property (nonatomic, weak) id<YMCollectionSectionHeaderViewDelegate> delegate;
@property (nonatomic, copy) ClickBtnBlock clickBtnBlock;
@property (nonatomic, strong) UIButton * doneBtn;
@property (nonatomic, strong) UILabel * sortLabel;
@end
