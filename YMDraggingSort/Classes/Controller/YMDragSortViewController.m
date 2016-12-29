//
//  YMDragSortViewController.m
//  YMDraggingSort
//
//  Created by lantaiyuan on 16/12/23.
//  Copyright © 2016年 youmy. All rights reserved.
//

#import "YMDragSortViewController.h"
#import "YMDargSortCell.h"
#import "YMDragSortTool.h"
#import "UIView+Frame.h"
#import "YMDefine.h"
#import "YMCollectionSectionHeaderView.h"
#import "NSMutableArray+Swizzling.h"

#define kSpaceBetweenSubscribe  2 * SCREEN_WIDTH_RATIO
#define kVerticalSpaceBetweenSubscribe  1 * SCREEN_WIDTH_RATIO
#define kSubscribeHeight  35 * SCREEN_WIDTH_RATIO
#define kContentLeftAndRightSpace  20 * SCREEN_WIDTH_RATIO
#define kTopViewHeight  0 * SCREEN_WIDTH_RATIO

static CGFloat kHEIGHT = 30;

@interface YMDragSortViewController ()<UICollectionViewDataSource, YMDargSortCellDelegate, YMCollectionSectionHeaderViewDelegate>
@property (nonatomic, strong) UIView * topView;
@property (nonatomic, strong) UICollectionView * dragSortView;
@property (nonatomic,strong) UIView * snapshotView; //截屏得到的view
@property (nonatomic,weak) YMDargSortCell * originalCell;
@property (nonatomic,strong) NSIndexPath * indexPath;
@property (nonatomic,strong) NSIndexPath * nextIndexPath;
@property (nonatomic, strong) YMCollectionSectionHeaderView * sectionHeader;
@property (nonatomic, strong) NSMutableArray * myChannels;
@property (nonatomic, strong) NSMutableArray * recommendChannels;
@end

@implementation YMDragSortViewController
#pragma mark - Lazy
- (UICollectionView *)dragSortView{
    if (!_dragSortView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat width = (SCREEN_WIDTH - 3*kSpaceBetweenSubscribe - 2 * kContentLeftAndRightSpace) / 4;
        layout.itemSize = CGSizeMake(width, kSubscribeHeight + 10 * SCREEN_WIDTH_RATIO);
        layout.minimumLineSpacing = kSpaceBetweenSubscribe;
        layout.minimumInteritemSpacing = kVerticalSpaceBetweenSubscribe;
        layout.sectionInset = UIEdgeInsetsMake(kContentLeftAndRightSpace * 0.5, kContentLeftAndRightSpace, kContentLeftAndRightSpace * 0.5, kContentLeftAndRightSpace);
        layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 30);
        
        _dragSortView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kTopViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kTopViewHeight) collectionViewLayout:layout];
        
        [_dragSortView registerClass:[YMDargSortCell class] forCellWithReuseIdentifier:@"YMDragSortCell"];
        _dragSortView.dataSource = self;
        _dragSortView.backgroundColor = self.view.backgroundColor;
        
        [_dragSortView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"sectionHeader"];
        
        _dragSortView.contentInset = UIEdgeInsetsMake(kHEIGHT, 0, 0, 0);
        [_dragSortView addSubview:self.sectionHeader];
    }
    return _dragSortView;
}

- (YMCollectionSectionHeaderView *)sectionHeader{
    if (!_sectionHeader) {
        _sectionHeader = [[YMCollectionSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHEIGHT)];
        _sectionHeader.delegate = self;
    }
    return _sectionHeader;
}


- (NSMutableArray *)myChannels{
    if (!_myChannels) {
        _myChannels = [NSMutableArray array];
    }
    return _myChannels;
}



- (NSMutableArray *)recommendChannels{
    if (!_recommendChannels) {
        _recommendChannels = [NSMutableArray array];
    }
    return _recommendChannels;
}

#pragma mark - System
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.dragSortView];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"defaultData"]) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"channel.json" ofType:nil];
        NSData * data = [NSData dataWithContentsOfFile:path];
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [self.myChannels addObjectsFromArray:dic[@"myChannel"]];
        [self.recommendChannels addObjectsFromArray:dic[@"recommendChannel"]];
        [self writeData];
    }else{
        [self update];
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section) {
        return self.recommendChannels.count;
    }else{
        return self.myChannels.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YMDargSortCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YMDragSortCell" forIndexPath:indexPath];
    cell.delegate = self;
//    cell.subscribe = [YMDragSortTool shareInstance].subscribeArray[indexPath.row];
    if (indexPath.section) {
        cell.subscribe = self.recommendChannels[indexPath.row];
        [cell hideDeleteBtn:YES];
    }else{
        cell.subscribe = self.myChannels[indexPath.row];
        [cell hideDeleteBtn:![YMDragSortTool shareInstance].isEditing];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView * reusableView  = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sectionHeader" forIndexPath:indexPath];
        
        UILabel * label = [self createLabelWithFrame:CGRectMake(20, 0, 70, 30) font:[UIFont systemFontOfSize:15] color:[UIColor darkGrayColor] text:indexPath.section ? @"推荐频道" : @""];
        for (UIView * view in reusableView.subviews) {
            [view removeFromSuperview];
        }
        
        [reusableView addSubview:label];
        return reusableView;
    }
    return nil;
}

- (UILabel *)createLabelWithFrame:(CGRect)frame font:(UIFont *)font color:(UIColor *)color text:(NSString *)text{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = color;
    label.font = font;
    label.text = text;
    return label;
}

#pragma mark - YMDargSortCellDelegate
- (void)dragSortCell:(YMDargSortCell *)cell longGesture:(UIGestureRecognizer *)gestureRecognizer{

    NSIndexPath * indexPath = [self.dragSortView indexPathForCell:cell];
    
    // 记录上一次手势的位置
    static CGPoint startPoint;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [YMDragSortTool shareInstance].isEditing = YES;
            self.dragSortView.scrollEnabled = NO;
            [self.sectionHeader.doneBtn setTitle:@"完成" forState:UIControlStateNormal];
            self.sectionHeader.sortLabel.hidden = NO;
        }
        
        if (![YMDragSortTool shareInstance].isEditing) {
            return;
        }
        
        NSArray * cells = [self.dragSortView visibleCells];
        for (YMDargSortCell * cell in cells) {
            NSIndexPath * indexPath = [self.dragSortView indexPathForCell:cell];
            if (indexPath.section == 0) {
                [cell showDeleteBtn];
            }
        }
        
        if (indexPath.section) {
            return;
        }
        
        _snapshotView = [cell snapshotViewAfterScreenUpdates:YES];
        _snapshotView.center = cell.center;
        [_dragSortView addSubview:_snapshotView];
        _indexPath = [_dragSortView indexPathForCell:cell];
        _originalCell = cell;
        _originalCell.hidden = YES;
        startPoint = [gestureRecognizer locationInView:_dragSortView];
        
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGFloat tranX = [gestureRecognizer locationOfTouch:0 inView:_dragSortView].x - startPoint.x;
        CGFloat tranY = [gestureRecognizer locationOfTouch:0 inView:_dragSortView].y - startPoint.y;
        //设置截图视图位置
        _snapshotView.center = CGPointApplyAffineTransform(_snapshotView.center, CGAffineTransformMakeTranslation(tranX, tranY));
        startPoint = [gestureRecognizer locationOfTouch:0 inView:_dragSortView];
        
        // 计算截图视图和哪个cell相交
        for (UICollectionViewCell * cell in [_dragSortView visibleCells]) {
            // 跳过隐藏的cell
            if ([_dragSortView indexPathForCell:cell] == _indexPath || [[_dragSortView indexPathForCell:cell] item] == 0) {
                continue;
            }

            // 计算中心距离
            CGFloat space = sqrt(pow(_snapshotView.center.x - cell.center.x, 2) + pow(_snapshotView.center.y - cell.center.y, 2));
            
            //如果相交一半且两个视图Y的绝对值小于高度的一半就移动
            if (space <= _snapshotView.bounds.size.width * 0.5 && fabs(_snapshotView.center.y - cell.center.y) <= _snapshotView.bounds.size.height * 0.5) {
                _nextIndexPath = [_dragSortView indexPathForCell:cell];
                
                if (!_nextIndexPath.section) {
                    if (_nextIndexPath.item > _indexPath.item) {
                        for (NSUInteger i = _indexPath.item; i < _nextIndexPath.item; i++) {
                            [self.myChannels exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                        }
                    }else{
                        for (NSUInteger i = _indexPath.item; i > _nextIndexPath.item; i --) {
                            [self.myChannels  exchangeObjectAtIndex:i withObjectAtIndex:i- 1];
                        }
                    }
                    
                    // 移动
                    [_dragSortView moveItemAtIndexPath:_indexPath toIndexPath:_nextIndexPath];
                    //设置移动后的起始indexPath
                    _indexPath = _nextIndexPath;
                }else{
                    __block BOOL singleInsert = YES;
                    __weak typeof(self) weakSelf = self;
                    
                    [self.recommendChannels enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isEqualToString:weakSelf.myChannels[_indexPath.item]]) {
                            singleInsert = NO;
                        }
                    }];
                    
                    if (singleInsert) {
//                        [self.recommendChannels insertObject:self.myChannels[_indexPath.item] atIndex:0];
                    }
                }
                break;
            }
        }
        // 停止
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        [_snapshotView removeFromSuperview];
        _originalCell.hidden = NO;
        [_dragSortView reloadData];
        _dragSortView.scrollEnabled = YES;
    }
}

- (void)dragSortCell:(YMDargSortCell *)cell tapGesture:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"点击");
    NSIndexPath * indexPath = [self.dragSortView indexPathForCell:cell];
    if (!indexPath.section) {
        return;
    }
    
    // 记录上一次手势的位置
    static CGPoint startPoint;
    
    _snapshotView = [cell snapshotViewAfterScreenUpdates:YES];
    _snapshotView.center = cell.center;
    [_dragSortView addSubview:_snapshotView];
    _originalCell = cell;
    _originalCell.hidden = YES;
    _indexPath = [_dragSortView indexPathForCell:cell];
    startPoint = [gestureRecognizer locationInView:_dragSortView];
    
    NSIndexPath * lastPath = [NSIndexPath indexPathForItem:self.myChannels.count - 1  inSection:0];
    YMDargSortCell * lastCell = (YMDargSortCell *)[self.dragSortView cellForItemAtIndexPath:lastPath];
    
    CGPoint lastPoint = CGPointMake(lastCell.centerX + lastCell.width, lastCell.centerY + lastCell.height);
    
    if (lastPoint.x > SCREEN_WIDTH) {
        lastPoint.x = kContentLeftAndRightSpace + lastCell.width * 0.5;
        lastPoint.y = lastPoint.y + lastCell.height;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _snapshotView.center = lastPoint;
    } completion:^(BOOL finished) {
        [self.myChannels addObject:self.recommendChannels[indexPath.item]];
        [self.recommendChannels removeObjectAtIndex:indexPath.item];
        [_snapshotView removeFromSuperview];
        _originalCell.hidden =  NO;
        [self writeData];
    }];
}

- (void)dragSortCell:(YMDargSortCell *)cell cancelSubscribe:(NSString *)subscribe{
    NSLog(@"取消订阅");
    
    _snapshotView = [cell snapshotViewAfterScreenUpdates:YES];
    _snapshotView.center = cell.center;
    [_dragSortView addSubview:_snapshotView];
    _originalCell = cell;
    _originalCell.hidden = YES;
    NSIndexPath * indexPath = [_dragSortView indexPathForCell:cell];
    
    NSIndexPath * lastPath = [NSIndexPath indexPathForItem:0  inSection:1];
    YMDargSortCell * lastCell = (YMDargSortCell *)[self.dragSortView cellForItemAtIndexPath:lastPath];
    
    CGPoint lastPoint = lastCell.center;

    [UIView animateWithDuration:0.5 animations:^{
        _snapshotView.center = lastPoint;
    } completion:^(BOOL finished) {
        [self.recommendChannels insertObject:self.myChannels[indexPath.item] atIndex:0];
        [self.myChannels removeObjectAtIndex:indexPath.item];
        [_snapshotView removeFromSuperview];
        _originalCell.hidden = NO;
        [_dragSortView reloadData];
        [self writeData];
    }];
}

#pragma mark - YMCollectionSectionHeaderViewDelegate
- (void)sectionHeaderView:(YMCollectionSectionHeaderView *)view clickButton:(UIButton *)button{
    self.dragSortView.scrollEnabled = ![YMDragSortTool shareInstance].isEditing;
    [self writeData];
}

- (void)writeData{
    NSDictionary * dic = @{@"myChannel":self.myChannels,@"recommendChannel":self.recommendChannels};
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * jsonPath = [path stringByAppendingPathComponent:@"channel_new.json"];
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    BOOL flag = [jsonData writeToFile:jsonPath atomically:YES];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"defaultData"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"defaultData"];
    }
    NSLog(@"%@",flag ? @"写入成功" : @"写入失败");
    [self update];
}

- (void)update{
    [self.myChannels removeAllObjects];
    [self.recommendChannels removeAllObjects];
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * jsonPath = [path stringByAppendingPathComponent:@"channel_new.json"];
    NSData * jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    [self.myChannels addObjectsFromArray:dic[@"myChannel"]];
    [self.recommendChannels addObjectsFromArray:dic[@"recommendChannel"]];
    [_dragSortView reloadData];
}
@end
