//
//  YMDargSortCell.m
//  YMDraggingSort
//
//  Created by lantaiyuan on 16/12/23.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import "YMDargSortCell.h"
#import "YMDragSortTool.h"
#import "UIView+Frame.h"
#import "YMDefine.h"

#define kDeleteBtnWH 10 * SCREEN_WIDTH_RATIO

@interface YMDargSortCell ()<UIGestureRecognizerDelegate>
/** 标签 */
@property (nonatomic,strong)  UILabel *label;
/** 是否可编辑 */
@property (nonatomic,assign) BOOL  isEditing;
/** 删除按钮 */
@property (nonatomic,strong) UIButton * deleteBtn;
@end

@implementation YMDargSortCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setup];
    }
    return self;
}

#pragma mark - Private
- (void)setup{
    UILongPressGestureRecognizer * longress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
    longress.delegate = self;
    [self addGestureRecognizer:longress];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    _label = [[UILabel alloc] init];
    [self.contentView addSubview:_label];
    _label.font = kFont(15);
    _label.textColor = RGBColorMake(110, 110, 110, 1);
    _label.backgroundColor = [UIColor whiteColor];
//    _label.layer.cornerRadius = 4 * SCREEN_WIDTH_RATIO;
    _label.layer.masksToBounds = NO;
    _label.layer.borderColor = RGBColorMake(231, 231, 231, 1).CGColor;
    _label.layer.borderWidth = kLineHeight;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.adjustsFontSizeToFitWidth = YES;
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setImage:[UIImage imageNamed:@"drag_delete"] forState:UIControlStateNormal];
    _deleteBtn.width = kDeleteBtnWH;
    _deleteBtn.height = kDeleteBtnWH;
    _deleteBtn.center = CGPointMake(self.width - _deleteBtn.width * 0.55, _deleteBtn.width * 0.55);
    
    [_deleteBtn addTarget:self action:@selector(cancelSubscribe) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
    
}

- (void)gestureAction:(UIGestureRecognizer *)gestureRecognizer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dragSortCell:longGesture:)]) {
        [self.delegate dragSortCell:self longGesture:gestureRecognizer];
    }
}

- (void)tapGestureAction:(UIGestureRecognizer *)gestureRecognizer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dragSortCell:tapGesture:)]) {
        [self.delegate dragSortCell:self tapGesture:gestureRecognizer];
    }
}

- (void)cancelSubscribe{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dragSortCell:cancelSubscribe:)]) {
        [self.delegate dragSortCell:self cancelSubscribe:self.subscribe];
    }
}

- (void)showDeleteBtn{
    _deleteBtn.hidden = NO;
}

- (void)hideDeleteBtn:(BOOL)hiden{
    _deleteBtn.hidden = hiden;
}

- (void)setSubscribe:(NSString *)subscribe{
    _subscribe = subscribe;
    _deleteBtn.hidden = ![YMDragSortTool shareInstance].isEditing;
    _label.text = subscribe;
//    _label.backgroundColor = [UIColor redColor];
    _label.width = self.width - kDeleteBtnWH * 0.25;
    _label.height = self.height - kDeleteBtnWH * 0.25;
    _label.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![YMDragSortTool shareInstance].isEditing) {
        return NO;
    }
    return YES;
}
@end
