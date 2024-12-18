//
//  AUITrackerTimeView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUITrackerTimeView.h"
#import "AUITimelineViewAppearance.h"

#define TIME_CELL_HEIGHT 12


@interface AlivcTrackerTimeCellItem : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSTimeInterval curTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSUInteger timeScale;

@end

@implementation AlivcTrackerTimeCellItem

@end


@interface AlivcTrackerTimeCell : UICollectionViewCell

@property (nonatomic, strong) AlivcTrackerTimeCellItem *item;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *midView;

@end

@implementation AlivcTrackerTimeCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [AUITimelineViewAppearance defaultAppearcnce].trackerTimeCellColor;
        _timeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:9];
        [self.contentView addSubview:_timeLabel];

        _midView = [[UIView alloc] initWithFrame:CGRectZero];
        _midView.backgroundColor = [AUITimelineViewAppearance defaultAppearcnce].trackerTimeCellColor;
        _midView.hidden = YES;
        [self.contentView addSubview:_midView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = _item.timeScale * 1.0;
    _timeLabel.frame = CGRectMake(-width / 2.0, 0, width, TIME_CELL_HEIGHT);
    _midView.frame = CGRectMake(width / 2.0 - 1, CGRectGetMidY(self.contentView.bounds) - 2, 2, 4);
}

- (void)setItem:(AlivcTrackerTimeCellItem *)item {
    if (_item == item) {
        return;
    }
    
    _item = item;
    int min = (int)_item.curTime / 60;
    int sec = (int)_item.curTime % 60;
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    _midView.hidden = _item.duration < 0.5;
    [self setNeedsLayout];
}

@end

@interface AUITrackerTimeView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<AlivcTrackerTimeCellItem *> *timeSource;

@end

@implementation AUITrackerTimeView

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.blackColor;
        
        _timeScale = 100;  // 100 pixes for 1 second
        _duration = 1.0;
        _currentTime = 0.0;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), TIME_CELL_HEIGHT) collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.userInteractionEnabled = NO;
        _collectionView.contentInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.bounds) / 2.0, 0, CGRectGetWidth(self.bounds) / 2.0);
        [_collectionView registerClass:[AlivcTrackerTimeCell class] forCellWithReuseIdentifier:@"AlivcTrackerTimeCell"];
        [self addSubview:_collectionView];
        
        [self reload];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), TIME_CELL_HEIGHT);
}

- (void)reload {
    
    _timeSource = [NSMutableArray array];
    NSTimeInterval step = 1.0;
    NSTimeInterval start = 0.0;
    while (start <= _duration) {
        NSTimeInterval duration = step;
        NSTimeInterval end = start + step;
        if (end > _duration) {
            duration = _duration - start;
        }
        AlivcTrackerTimeCellItem *item = [AlivcTrackerTimeCellItem new];
        item.curTime = start;
        item.duration = duration;
        item.timeScale = _timeScale;
        [_timeSource addObject:item];
        start = end;
    }
    [_collectionView reloadData];
}

- (void)setDuration:(NSTimeInterval)duration {
    if (duration < 0 || duration == _duration) {
        return;
    }
    
    _duration = duration;
    [self reload];
    if (_currentTime < 0 || _duration < _currentTime) {
        [_collectionView layoutIfNeeded];
        _collectionView.contentOffset = CGPointMake(_currentTime * _timeScale - _collectionView.contentInset.left, _collectionView.contentOffset.y);
    }
}

- (void)setTimeScale:(NSUInteger)timeScale {
    if (timeScale < 0 || timeScale == _timeScale) {
        return;
    }
    
    _timeScale = timeScale;
    [self reload];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    if (currentTime == _currentTime) {
        return;
    }
    
    _currentTime = currentTime;
    _collectionView.contentOffset = CGPointMake(_currentTime * _timeScale - _collectionView.contentInset.left, _collectionView.contentOffset.y);
}

// MARK: - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _timeSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlivcTrackerTimeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlivcTrackerTimeCell" forIndexPath:indexPath];
    cell.item = [_timeSource objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(MAX([_timeSource objectAtIndex:indexPath.row].duration * _timeScale, 1), TIME_CELL_HEIGHT);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

@end
