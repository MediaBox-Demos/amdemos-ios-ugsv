//
//  AUITrackerClipView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUITrackerClipView.h"
#import "AUITimelineViewAppearance.h"

@implementation AUITrackerThumbnailItem

- (void)cancelRequest {
    
}

- (void)requestThumbImage:(void (^)(AUITrackerThumbnailItem *, UIImage *))completed {
    if (completed) {
        completed(self, self.thumb);
    }
}

@end

@implementation AUITrackerClipSource

- (id)copyWithZone:(NSZone *)zone {
    AUITrackerClipSource *source = [AUITrackerClipSource new];
    source.thumbFetcher = self.thumbFetcher;
    source.contentLeft = self.contentLeft;
    source.contentRight = self.contentRight;
    source.minContentWidth = self.minContentWidth;
    source.maxContentWidth = self.maxContentWidth;
    return source;
}

@end

@implementation AUITrackerClipViewport

- (instancetype)init {
    self = [super init];
    if (self) {
        self.limitPosition = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    AUITrackerClipViewport *viewport = [AUITrackerClipViewport new];
    viewport.size = self.size;
    viewport.position = self.position;
    viewport.offset = self.offset;
    viewport.limitPosition = self.limitPosition;
    return viewport;
}

@end


@implementation AUITrackerThumbnailCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _thumbImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbImageView];

        self.backgroundColor = [AUITimelineViewAppearance defaultAppearcnce].trackerThumbnailCellBackgroundColor;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _thumbImageView.frame = self.contentView.bounds;
}

- (void)setItem:(AUITrackerThumbnailItem *)item {
    if (_item == item) {
        return;
    }
    [_item cancelRequest];
    _item = item;
    _thumbImageView.image = nil;

    __weak typeof(self) weakSelf = self;
    [_item requestThumbImage:^(AUITrackerThumbnailItem *item, UIImage *thumb) {
        if (item == weakSelf.item) {
            weakSelf.thumbImageView.image = thumb;
        }
    }];
    _thumbImageView.contentMode = [_item thumbDisplayMode];
    self.backgroundColor = _item.bgColor ? _item.bgColor : [AUITimelineViewAppearance defaultAppearcnce].trackerThumbnailCellBackgroundColor;
}

@end

@implementation AUITrackerClipTransitionInfo

@end



@interface AUITrackerClipView () <UICollectionViewDataSource>

@property (nonatomic, strong) AUITrackerClipSource *innerSource;
@property (nonatomic, strong) AUITrackerClipViewport *innerViewport;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) AUITrackerClipTransitionInfo *transitionInfo;
@property (nonatomic, strong) CALayer *transitionLayer;

@end

@implementation AUITrackerClipView

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.clipsToBounds = YES;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(45, 45);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.userInteractionEnabled = NO;
        [_collectionView registerClass:[AUITrackerThumbnailCell class] forCellWithReuseIdentifier:@"AlivcTrackerThumbnailCell"];
        [self addSubview:_collectionView];
        
        [_collectionView reloadData];
    }
    return self;
}

// MARK: - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _innerSource.thumbFetcher.thumbItemsCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUITrackerThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlivcTrackerThumbnailCell" forIndexPath:indexPath];
    if (_innerSource.thumbFetcher.thumbItemAtIndexBlock) {
        cell.item = _innerSource.thumbFetcher.thumbItemAtIndexBlock(indexPath.row);
    }
    else {
        cell.item = nil;
    }
    return cell;
}

- (AUITrackerClipSource *)source {
    return [_innerSource copy];
}

- (AUITrackerClipViewport *)viewport {
    return [_innerViewport copy];
}

- (void)setTransitionInfo:(AUITrackerClipTransitionInfo *)info {
    if (_transitionInfo != info) {
        _transitionInfo = info;
        [self updateTransitionLayer];
    }
}

- (void)updateTransitionLayer {
    self.layer.mask = nil;
    [self.transitionLayer removeFromSuperlayer];
    self.transitionLayer = nil;
    
    if (!self.transitionInfo) {
        return;
    }
    
    CGFloat width = MIN (_innerViewport.size.width + self.transitionInfo.widthIn + self.transitionInfo.widthOut, _innerSource.contentRight - _innerSource.contentLeft);
    CGFloat x = 0;
    if (_collectionView.contentOffset.x - _innerSource.contentLeft <= self.transitionInfo.widthIn) {
        x = _innerSource.contentLeft - _collectionView.contentOffset.x;
    }
    else if (_innerSource.contentRight - (_collectionView.contentOffset.x + _innerViewport.size.width) <= self.transitionInfo.widthOut ) {
        x = -width + _innerSource.contentRight - _collectionView.contentOffset.x;
    }
    else {
        x = -self.transitionInfo.widthIn;
    }
    CGRect transFrame = CGRectMake(x, 0, width, CGRectGetHeight(self.bounds));
    
    CGFloat left = 0;
    CGFloat top = 0;
    CGFloat right = CGRectGetWidth(transFrame);
    CGFloat bot = CGRectGetHeight(transFrame);
    if (self.transitionInfo.isSelected) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = transFrame;
        layer.fillColor = [AUITimelineViewAppearance defaultAppearcnce].transitionIconViewFillColor.CGColor;
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        if (self.transitionInfo.enableIn && self.transitionInfo.applyIn) {
            UIBezierPath *inPath = [UIBezierPath bezierPath];
            [inPath moveToPoint:CGPointMake(left, bot)];
            [inPath addLineToPoint:CGPointMake(left, top)];
            [inPath addLineToPoint:CGPointMake(left + self.transitionInfo.widthIn, top)];
            [inPath closePath];
            [linePath appendPath:inPath];
        }
        
        if (self.transitionInfo.enableOut && self.transitionInfo.applyOut) {
            UIBezierPath *outPath = [UIBezierPath bezierPath];
            [outPath moveToPoint:CGPointMake(right, top)];
            [outPath addLineToPoint:CGPointMake(right, bot)];
            [outPath addLineToPoint:CGPointMake(right - self.transitionInfo.widthOut, bot)];
            [outPath closePath];
            [linePath appendPath:outPath];
        }
        layer.path = linePath.CGPath;
        
        self.transitionLayer = layer;
        [self.layer addSublayer:self.transitionLayer];
    }
    else {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = transFrame;
        layer.fillColor = UIColor.blackColor.CGColor;
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        if (self.transitionInfo.enableIn) {
            if (self.transitionInfo.applyIn) {
                [linePath moveToPoint:CGPointMake(left + 1, bot)];
                [linePath addLineToPoint:CGPointMake(left + 1 + self.transitionInfo.widthIn, top)];
            }
            else {
                [linePath moveToPoint:CGPointMake(left + 1, bot)];
                [linePath addLineToPoint:CGPointMake(left + 1, top)];
            }
        }
        else {
            [linePath moveToPoint:CGPointMake(left, bot)];
            [linePath addLineToPoint:CGPointMake(left, top)];
        }
        
        if (self.transitionInfo.enableOut) {
            if (self.transitionInfo.applyOut) {
                [linePath addLineToPoint:CGPointMake(right - 1, top)];
                [linePath addLineToPoint:CGPointMake(right -1 - self.transitionInfo.widthOut, bot)];
            }
            else {
                [linePath addLineToPoint:CGPointMake(right - 1, top)];
                [linePath addLineToPoint:CGPointMake(right - 1, bot)];
            }
        }
        else {
            [linePath addLineToPoint:CGPointMake(right, top)];
            [linePath addLineToPoint:CGPointMake(right, bot)];
        }
        
        [linePath closePath];
        layer.path = linePath.CGPath;
        
        self.transitionLayer = layer;
        self.layer.mask = self.transitionLayer;
    }
}

- (void)setTitleView:(UIView *)titleView {
    if (_titleView) {
        [_titleView removeFromSuperview];
        _titleView = nil;
    }
    
    if (titleView) {
        _titleView = titleView;
        [self updateTitleViewFrame];
        [_collectionView addSubview:_titleView];
    }
}

- (void)updateTitleViewFrame {
    _titleView.frame = CGRectMake(_innerSource.contentLeft, 0, CGRectGetWidth(_collectionView.bounds), CGRectGetHeight(_collectionView.bounds));
}

- (BOOL)setSource:(AUITrackerClipSource *)source viewport:(AUITrackerClipViewport *)viewport {
    
    CGFloat maxContentWidth = source.thumbFetcher.thumbItemsCount * source.thumbFetcher.thumbSize.width;
    if (maxContentWidth <= 2.0) {
        return NO;
    }
    
    _innerSource = [source copy];
    _innerViewport = [viewport copy];
    
    if (_innerSource.minContentWidth < 1.0 || _innerSource.minContentWidth >= maxContentWidth) {
        _innerSource.minContentWidth = 1.0;
    }
    if (_innerSource.maxContentWidth <= _innerSource.minContentWidth || _innerSource.maxContentWidth > maxContentWidth) {
        _innerSource.maxContentWidth = maxContentWidth;
    }
    if (_innerSource.contentLeft < 0 || _innerSource.contentLeft > _innerSource.maxContentWidth - _innerSource.minContentWidth) {
        _innerSource.contentLeft = 0;
    }
    if (_innerSource.contentRight <= 0 || _innerSource.contentRight > _innerSource.maxContentWidth) {
        _innerSource.contentRight = _innerSource.maxContentWidth;
    }
    else if (_innerSource.contentRight < _innerSource.contentLeft + _innerSource.minContentWidth) {
        _innerSource.contentRight = _innerSource.contentLeft + _innerSource.minContentWidth;
    }
    
    if (_innerViewport.position.x < 0 || _innerViewport.position.y < 0) {
        _innerViewport.position = CGPointMake(MAX(0, _innerViewport.position.x), MAX(0, _innerViewport.position.y));
    }
    if (_innerViewport.position.x + (_innerSource.contentRight - _innerSource.contentLeft) > _innerViewport.limitPosition.x) {
        CGFloat x = _innerViewport.limitPosition.x - (_innerSource.contentRight - _innerSource.contentLeft);
        _innerViewport.position = CGPointMake(x, _innerViewport.position.y);
    }
    
    [(UICollectionViewFlowLayout *)_collectionView.collectionViewLayout setItemSize:_innerSource.thumbFetcher.thumbSize];
    [_collectionView reloadData];

    [self translateSourceContent:0 autoPosition:YES isLeft:YES];
    [self translateSourceContent:0 autoPosition:YES isLeft:NO];
    
    return YES;
}

- (void)updateFrame {
    self.frame = CGRectMake(_innerViewport.position.x, _innerViewport.position.y, MIN(_innerViewport.size.width, _innerSource.contentRight - _innerSource.contentLeft), _innerViewport.size.height);
    self.collectionView.frame = self.bounds;
    [self updateTitleViewFrame];
    [self updateTransitionLayer];
}

- (BOOL)checkSourceContentTranslate:(CGFloat)dx autoPosition:(BOOL)autoPosition isLeft:(BOOL)isLeft {
    if (isLeft) {
        if (_innerSource.contentLeft <= 0 && dx < 0) {
            return NO;
        }
        if (_innerSource.contentLeft + _innerSource.minContentWidth >= _innerSource.contentRight && dx > 0) {
            return NO;
        }
        if (!autoPosition && _innerViewport.position.x <= 0 && dx < 0) {
            return NO;
        }
    }
    else {
        if (_innerSource.contentRight >= _innerSource.maxContentWidth && dx > 0) {
            return NO;
        }
        if (_innerSource.contentRight - _innerSource.minContentWidth <= _innerSource.contentLeft && dx < 0) {
            return NO;
        }
        if (dx > 0 && _innerViewport.position.x + _innerSource.contentRight - _innerSource.contentLeft >= _innerViewport.limitPosition.x) {
            return NO;
        }
    }
    return YES;
}

- (CGFloat)translateSourceContent:(CGFloat)dx autoPosition:(BOOL)autoPosition isLeft:(BOOL)isLeft {
    
    CGFloat applyDx = 0;
    if (isLeft) {
        if (!autoPosition && _innerViewport.position.x + dx < 0) {
            NSLog(@"");
            dx = -(_innerViewport.position.x);
        }
        CGFloat left = _innerSource.contentLeft + dx;
        if (left < 0) {
            left = 0;
        }
        if (left > _innerSource.contentRight - _innerSource.minContentWidth) {
            left = _innerSource.contentRight - _innerSource.minContentWidth;
        }
        applyDx = left - _innerSource.contentLeft;
        _innerSource.contentLeft = left;
        if (!autoPosition) {
            _innerViewport.position = CGPointMake(_innerViewport.position.x + applyDx, _innerViewport.position.y);
        }
    }
    else {
        CGFloat right = _innerSource.contentRight + dx;
        if (right > _innerSource.maxContentWidth) {
            right = _innerSource.maxContentWidth;
        }
        if (right < _innerSource.contentLeft + _innerSource.minContentWidth) {
            right = _innerSource.contentLeft + _innerSource.minContentWidth;
        }
        if (_innerViewport.position.x + right - _innerSource.contentLeft > _innerViewport.limitPosition.x) {
            right = _innerViewport.limitPosition.x - _innerViewport.position.x + _innerSource.contentLeft;
        }
        applyDx = right - _innerSource.contentRight;
        _innerSource.contentRight = right;
    }
    
    [self updateFrame];
    _collectionView.contentOffset = CGPointMake(_innerSource.contentLeft, 0);

    return applyDx;
}

- (BOOL)checkViewportPositionTranslate:(CGFloat)dx autoPosition:(BOOL)autoPosition {
    if (autoPosition) {
        return NO;
    }
    
    if (_innerViewport.position.x <= 0 && dx < 0) {
        return NO;
    }
    
    if (dx > 0 && _innerViewport.position.x + _innerSource.contentRight - _innerSource.contentLeft >= _innerViewport.limitPosition.x) {
        return NO;
    }
    
    return YES;
}

- (CGFloat)translateViewportPosition:(CGFloat)dx {
    CGFloat x = _innerViewport.position.x + dx;
    if (x < 0) {
        x = 0;
    }
    if (x + _innerSource.contentRight - _innerSource.contentLeft > _innerViewport.limitPosition.x) {
        x = _innerViewport.limitPosition.x - (_innerSource.contentRight - _innerSource.contentLeft);
    }
    CGFloat applyOffset = x - _innerViewport.position.x;
    _innerViewport.position = CGPointMake(x, _innerViewport.position.y);

    [self updateFrame];
    
    return applyOffset;
}


- (void)updateViewportOffset:(CGFloat)offset {
    
    _innerViewport.offset = offset;

    CGFloat width = self.frame.size.width;
    CGFloat posx = self.frame.origin.x;
    CGFloat contentOffset = _innerSource.contentLeft;
    if (offset < _innerViewport.position.x) {
        posx = _innerViewport.position.x;
        contentOffset = _innerSource.contentLeft;
    }
    else if (offset > _innerViewport.position.x + _innerSource.contentRight - _innerSource.contentLeft - _innerViewport.size.width) {
        posx = _innerViewport.position.x + _innerSource.contentRight - _innerSource.contentLeft - width;
        contentOffset = _innerSource.contentRight - width;
    }
    else {
        posx = offset;
        contentOffset = offset - (_innerViewport.position.x - _innerSource.contentLeft);
    }
    
    CGRect frame = self.frame;
    frame.origin.x = posx;
    self.frame = frame;
    _collectionView.contentOffset = CGPointMake(contentOffset, 0);
    
    CGRect transFrame = self.transitionLayer.frame;
    if (contentOffset - _innerSource.contentLeft <= self.transitionInfo.widthIn) {
        transFrame.origin.x = _innerSource.contentLeft - contentOffset;
    }
    else if (_innerSource.contentRight - (contentOffset + _innerViewport.size.width) <= self.transitionInfo.widthOut ) {
//        transFrame.origin.x = -(transFrame.size.width - (_innerSource.contentRight - (contentOffset + _innerViewport.size.width)) - _innerViewport.size.width);
        transFrame.origin.x = -transFrame.size.width + _innerSource.contentRight - contentOffset;
    }
    else {
        transFrame.origin.x = -self.transitionInfo.widthIn;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.transitionLayer.frame = transFrame;
    [CATransaction commit];
    
    NSLog(@"%@ transitionLayer:%f, %f", self, CGRectGetWidth(transFrame), CGRectGetMinX(transFrame));

}

- (void)updateViewportPosition:(CGPoint)position {
    _innerViewport.position = position;
    [self updateFrame];
    [self updateViewportOffset:_innerViewport.offset];
}

@end
