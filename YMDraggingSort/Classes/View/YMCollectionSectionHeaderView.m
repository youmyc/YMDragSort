//
//  YMCollectionSectionHeaderView.m
//  YMDraggingSort
//
//  Created by lantaiyuan on 16/12/26.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import "YMCollectionSectionHeaderView.h"
#import "UIView+Frame.h"
#import "YMDragSortTool.h"

@interface YMCollectionSectionHeaderView ()
@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation YMCollectionSectionHeaderView

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [self createLabelWithFrame:CGRectMake(20, 0, 70, self.height) font:[UIFont systemFontOfSize:15] color:[UIColor darkGrayColor] text:@"我的频道"];
    }
    return _titleLabel;
}

- (UILabel *)sortLabel{
    if (!_sortLabel) {
        _sortLabel = [self createLabelWithFrame:CGRectMake(CGRectGetMaxX(_titleLabel.frame), 0, 80, self.height) font:[UIFont systemFontOfSize:11] color:[UIColor lightGrayColor] text:@"拖拽可以排序"];
        _sortLabel.hidden = YES;
    }
    return _sortLabel;
}

- (UIButton *)doneBtn{
    if (!_doneBtn) {
        _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 60, self.height - 30, 40, 20)];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        [_doneBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor  redColor] forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneOrEditAction:) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.layer.borderWidth = 0.5;
        _doneBtn.layer.borderColor = [UIColor redColor].CGColor;
        _doneBtn.layer.cornerRadius = 10.0;
        _doneBtn.centerY = self.titleLabel.centerY;
    }
    return _doneBtn;
}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)doneOrEditAction:(UIButton *)button{
    [YMDragSortTool shareInstance].isEditing = ![YMDragSortTool shareInstance].isEditing;
    NSString * title = [YMDragSortTool shareInstance].isEditing ? @"完成":@"编辑";
    
    _sortLabel.hidden = ![YMDragSortTool shareInstance].isEditing;
    
    [button setTitle:title forState:UIControlStateNormal];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionHeaderView:clickButton:)]) {
        [self.delegate sectionHeaderView:self clickButton:button];
    }
}

- (void)setupUI{
    [self addSubview:self.titleLabel];
    [self addSubview:self.sortLabel];
    [self addSubview:self.doneBtn];
}

- (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font color:(UIColor *)color text:(NSString *)text{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = color;
    label.font = font;
    label.text = text;
    return label;
}

@end
