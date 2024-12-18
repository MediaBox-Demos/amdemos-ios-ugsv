//
//  AUITimelineView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUITimelineView.h"
#import "AUITrackerClipView.h"
#import "AUITrackerTimeView.h"
#import "AUITrackerClipTransitionView.h"
#import "AUITimelineViewAppearance.h"

@interface AUITrackerClipTransitionData ()

@property (nonatomic, weak) AUITrackerClipTransitionView *transView;

@end

@implementation AUITrackerClipTransitionData

- (instancetype)initWithIsApply:(BOOL)isApply withDuration:(NSTimeInterval)duration withIcon:(UIImage *)icon {
    self = [super init];
    if (self) {
        _isApply = isApply;
        _duration = duration;
        _icon = icon;
    }
    return self;
}

@end


@interface AUITrackerClipData ()

@property (nonatomic, weak) AUITrackerData *trackerData;
@property (nonatomic, weak) AUITrackerClipView *clipView;


@end

@implementation AUITrackerClipData

- (instancetype)initWithAutoStart:(BOOL)autoStart withStart:(NSTimeInterval)start withDruation:(NSTimeInterval)duration withClipStart:(NSTimeInterval)clipStart withClipEnd:(NSTimeInterval)clipEnd {
    return [self initWithAutoStart:autoStart withStart:start withDruation:duration withClipStart:clipStart withClipEnd:clipEnd withTrans:nil withSpeed:1.0];
}

- (instancetype)initWithAutoStart:(BOOL)autoStart withStart:(NSTimeInterval)start withDruation:(NSTimeInterval)duration withClipStart:(NSTimeInterval)clipStart withClipEnd:(NSTimeInterval)clipEnd withTrans:(AUITrackerClipTransitionData *)trans withSpeed:(CGFloat)speed {
    self = [super init];
    if (self) {
        _autoStart = autoStart;
        _enableSelected = YES;
        _enablePanLeftRight = YES;
        
        if (start < 0) {
            start = 0;
        }
        _start = start;
        
        if (duration < 0) {
            duration = 0;
        }
        _duration = duration;
        
        if (clipStart < 0) {
            _clipStart = 0;
        }
        if (clipEnd > _duration) {
            clipEnd = _duration;
        }
        if (clipStart > clipEnd) {
            clipStart = clipEnd;
        }
        _clipStart = clipStart;
        _clipEnd = clipEnd;
        _speed = speed <= 0 ? 1.0 : speed;
        _transData = trans;
        
        _thumbDisplayMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)updateWithStart:(NSTimeInterval)start withClipStart:(NSTimeInterval)clipStart withClipEnd:(NSTimeInterval)clipEnd {
    
    if (start < 0) {
        start = 0;
    }
    _start = start;
    
    if (clipStart < 0) {
        _clipStart = 0;
    }
    if (clipEnd > _duration) {
        clipEnd = _duration;
    }
    if (clipStart > clipEnd) {
        clipStart = clipEnd;
    }
    _clipStart = clipStart;
    _clipEnd = clipEnd;
}

@end

@interface AUITrackerData ()

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, strong) NSMutableArray<AUITrackerClipData *> *clipList;

@property (nonatomic, weak) UIView *headerView;

@property (nonatomic, weak) UIView *onView;
@property (nonatomic, strong) UIView *depthFlagViewForClip;

@end

@implementation AUITrackerData

- (instancetype)initWithIndex:(NSUInteger)index withThumbSize:(CGSize)size {
    self = [super init];
    if (self) {
        _index = index;
        _thumbSize = size;
        _clipList = [NSMutableArray array];
    }
    return self;
}

- (void)addDepthFlagViewForClip:(UIView *)onView {
    self.depthFlagViewForClip = [UIView new];
    self.onView = onView;
    [self.onView addSubview:self.depthFlagViewForClip];
}

- (void)removeDepthFlagViewForClip {
    [self.depthFlagViewForClip removeFromSuperview];
    self.depthFlagViewForClip = nil;
    self.onView = nil;
}

- (void)addClipView:(UIView *)clipView {
    [self.onView insertSubview:clipView belowSubview:self.depthFlagViewForClip];
}

- (void)updateClipViewDepth:(UIView *)clipView {
    UIView *topClipView = [self topClipView];
    if (!topClipView || topClipView == clipView) {
        return;
    }
    NSUInteger index1 = [self.onView.subviews indexOfObject:clipView];
    NSUInteger index2 = [self.onView.subviews indexOfObject:topClipView];
    [self.onView exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
}

- (UIView *)topClipView {
    NSInteger start = [[self.onView subviews] indexOfObject:self.depthFlagViewForClip];
    UIView *top = nil;
    for (NSInteger i = MIN(start, self.onView.subviews.count); i>=0; i--) {
        UIView *clipView = self.onView.subviews[i];
        for (AUITrackerClipData *clipData in self.clipList) {
            if (clipData.clipView == clipView) {
                top = clipView;
                break;
            }
        }
        if (top) {
            break;
        }
    }
    return top;
}

@end

@interface AUITrackerThumbnailTimeItem : AUITrackerThumbnailItem

@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, weak) id<AUITrackerThumbnailRequestProtocol> thumbRequest;
@property (nonatomic, copy) void(^completedBlock)(AUITrackerThumbnailItem *item, UIImage *thumb);

@end

@implementation AUITrackerThumbnailTimeItem

- (void)cancelRequest {
    self.completedBlock = nil;
}

- (void)requestThumbImage:(void (^)(AUITrackerThumbnailItem *, UIImage *))completed {
    self.completedBlock = completed;
    if (self.thumb) {
        if (self.completedBlock) {
            self.completedBlock(self, self.thumb);
        }
    }
    else {
        __weak typeof(self) weakSelf = self;
        [self.thumbRequest requestTimes:@[@(_time)] duration:_duration completed:^(NSTimeInterval time, UIImage *thumb) {
            NSAssert(ABS(weakSelf.time - time) < 0.001, @"");
            weakSelf.thumb = thumb;
            if (weakSelf.completedBlock) {
                weakSelf.completedBlock(weakSelf, thumb);
            }
        }];
    }
}

@end


@interface AUITrackerClipMultipleThumbnailFetcher : NSObject<AUITrackerClipThumbnailsFetcherProtocol>

@property (nonatomic, copy) NSArray<AUITrackerThumbnailTimeItem *> *thumbItems;

@end

@implementation AUITrackerClipMultipleThumbnailFetcher

@synthesize thumbSize = _thumbSize;
@synthesize thumbItemAtIndexBlock = _thumbItemAtIndexBlock;

- (instancetype)initWithSize:(CGSize)size withItems:(NSArray<AUITrackerThumbnailTimeItem *> *)items {
    self = [super init];
    if (self) {
        _thumbSize = size;
        _thumbItems = items;
        
        __weak typeof(self) weakSelf = self;
        _thumbItemAtIndexBlock = ^AUITrackerThumbnailItem *(NSUInteger index) {
            return [weakSelf.thumbItems objectAtIndex:index];
        };
    }
    return self;
}

- (NSUInteger)thumbItemsCount {
    return _thumbItems.count;
}

@end

@interface AUITrackerClipSingleThumbnailFetcher : NSObject<AUITrackerClipThumbnailsFetcherProtocol>

@property (nonatomic, copy) UIColor *thumbColor;
@property (nonatomic, assign) UIViewContentMode thumbDisplayMode;
@property (nonatomic, strong) UIImage *thumbImage;

@end

@implementation AUITrackerClipSingleThumbnailFetcher

@synthesize thumbSize = _thumbSize;
@synthesize thumbItemsCount = _thumbItemsCount;
@synthesize thumbItemAtIndexBlock = _thumbItemAtIndexBlock;

- (instancetype)initWithSize:(CGSize)size withCount:(NSUInteger)count {
    self = [super init];
    if (self) {
        _thumbSize = size;
        _thumbItemsCount = count;
        
        __weak typeof(self) weakSelf = self;
        _thumbItemAtIndexBlock = ^AUITrackerThumbnailItem *(NSUInteger index) {
            AUITrackerThumbnailItem *item = [AUITrackerThumbnailItem new];
            item.bgColor = weakSelf.thumbColor;
            item.thumbDisplayMode = weakSelf.thumbDisplayMode;
            item.thumb = weakSelf.thumbImage;
            return item;
        };
    }
    return self;
}

@end


@interface AlivcDraggingDataParser : NSObject

@property (nonatomic, assign) CGFloat leftEdge;
@property (nonatomic, assign) CGFloat rightEdge;
@property (nonatomic, weak) UIView *draggingView;
@property (nonatomic, assign, readonly) CGPoint clickPositionInDraggingView;
@property (nonatomic, assign, readonly) CGPoint startPosition;
@property (nonatomic, assign, readonly) CGPoint clickPosition;
@property (nonatomic, assign, readonly) CGPoint currentPosition;
@property (nonatomic, assign, readonly) BOOL moveToLeft;
@property (nonatomic, assign, readonly) NSUInteger autoChangedCount;
@property (nonatomic, assign, readonly) BOOL dataChanged;


@property (nonatomic, copy) BOOL (^checkChangedPosition)(CGPoint delta);

@end

@implementation AlivcDraggingDataParser

- (void)began:(CGPoint)position clipPosInDraggingView:(CGPoint)clipPos {
    _dataChanged = NO;
    _autoChangedCount = 0;
    _startPosition = position;
    _clickPosition = position;
    _currentPosition = position;
    _clickPositionInDraggingView = clipPos;
}

- (void)changedPosition:(CGPoint)position completed:(CGFloat(^)(CGPoint delta, BOOL reachEdge))completed {
    _clickPosition = position;
    if (_autoChangedCount > 0) {
        BOOL reachEdge = _clickPosition.x < _leftEdge || _clickPosition.x > _rightEdge;
        if (reachEdge) {
            return;
        }
    }
    CGPoint old = _currentPosition;
    CGPoint delta = CGPointMake(_clickPosition.x - old.x, _clickPosition.y - old.y);
    if (_checkChangedPosition) {
        if (!_checkChangedPosition(delta)) {
            return;
        }
    }
    _currentPosition = _clickPosition;
    _moveToLeft = _currentPosition.x < old.x;
    _autoChangedCount = 0;
    _dataChanged = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    
    BOOL reachEdge = _currentPosition.x < _leftEdge || _currentPosition.x > _rightEdge;
    CGFloat applyDelta = delta.x;
    if (completed) {
        applyDelta = completed(delta, reachEdge);
    }
    _currentPosition.x = old.x + applyDelta;
    if ((_currentPosition.x < _leftEdge && _moveToLeft) || (_currentPosition.x > _rightEdge && !_moveToLeft)) {
        _autoChangedCount = 1;
        [self performSelector:@selector(startAutoChanged:) withObject:completed afterDelay:0.5];
    }
}

- (void)startAutoChanged:(CGFloat(^)(CGPoint delta, BOOL reachEdge))raiseChanged {
    CGPoint delta = CGPointZero;
    CGFloat factor = MIN(ABS(_clickPosition.x - _currentPosition.x) / 10.0 + 1, 3.0);
    if (_currentPosition.x < _leftEdge) {
        delta = CGPointMake(-10.0 * factor, 0);
    }
    else if (_currentPosition.x > _rightEdge) {
        delta = CGPointMake(10.0 * factor, 0);
    }
    else {
        return;
    }
    
    if (_checkChangedPosition) {
        if (!_checkChangedPosition(delta)) {
            return;
        }
    }
    
    if (raiseChanged) {
        raiseChanged(delta, YES);
    }
    
    _autoChangedCount++;
    [self performSelector:@selector(startAutoChanged:) withObject:raiseChanged afterDelay:0.1];
}

- (void)end {
    _dataChanged = NO;
    _autoChangedCount = 0;
    _clickPosition = CGPointZero;
    _startPosition = CGPointZero;
    _currentPosition = CGPointZero;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end


@interface AUITimelineView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSUInteger timeScale;

@property (nonatomic, strong) AUITrackerTimeView *durationIndicator;
@property (nonatomic, strong) UIView *currentTimeIndicator;

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) AUITrackerClipSelectionView *selectionView;

@property (nonatomic, strong) AlivcDraggingDataParser *panDataParser;
@property (nonatomic, strong) AlivcDraggingDataParser *longPressDataParser;

@property (nonatomic, strong) NSMutableArray<AUITrackerData *> *trackerDataList;
@property (nonatomic, strong) AUITrackerClipData *selectedClipData;

@property (nonatomic, assign) BOOL isSettingCurrentTime;


@end

@implementation AUITimelineView

- (instancetype)initWithFrame:(CGRect)frame hiddentTimeIndicator:(BOOL)hiddenTimeIndicator hiddenCurrentTimeIndicator:(BOOL)hiddenCurrentTimeIndicator scrollInset:(UIEdgeInsets)scrollInset {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _trackerMarginTop = 32.0;
        _trackerMarginBottom = 20.0;
        _trackerMarginSpace = 8.0;
        _timeScale = 100; // 100 pixes for 1 second
        _actualDuration = 0.0;
        _maxDuration = CGFLOAT_MAX;

        CGRect rect = UIEdgeInsetsInsetRect(self.bounds, scrollInset);
        _scrollview = [[UIScrollView alloc] initWithFrame:rect];
        _scrollview.delegate = self;
        _scrollview.directionalLockEnabled = YES;
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.contentInset = UIEdgeInsetsMake(0, CGRectGetWidth(_scrollview.bounds) / 2.0, 0, CGRectGetWidth(_scrollview.bounds) / 2.0);
        _scrollview.contentSize = CGSizeMake([self widthWithTime:_actualDuration], CGRectGetHeight(_scrollview.bounds));
        [self addSubview:_scrollview];
        
        if (!hiddenTimeIndicator) {
            _durationIndicator = [[AUITrackerTimeView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 12)];
            _durationIndicator.duration = _actualDuration;
            _durationIndicator.backgroundColor = UIColor.clearColor;
            [self addSubview:_durationIndicator];
        }
        
        if (!hiddenCurrentTimeIndicator) {
            _currentTimeIndicator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds) - 1, CGRectGetMaxY(_durationIndicator.frame) + 6, 1, CGRectGetMaxY(_scrollview.frame) - CGRectGetMaxY(_durationIndicator.frame) - 6 - 6)];
            _currentTimeIndicator.backgroundColor = [AUITimelineViewAppearance defaultAppearcnce].timeIndicatorCellColor;
            [self addSubview:_currentTimeIndicator];
        }
        
        _selectionView = [AUITrackerClipSelectionView new];
        _selectionView.frame = CGRectZero;
        _selectionView.hidden = YES;
        [_scrollview addSubview:_selectionView];
        UIPanGestureRecognizer *leftGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectionPanGestureAction:)];
        [_selectionView.leftView addGestureRecognizer:leftGesture];
        UIPanGestureRecognizer *rightGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectionPanGestureAction:)];
        [_selectionView.rightView addGestureRecognizer:rightGesture];
        
        _trackerDataList = [NSMutableArray array];
        _selectedClipData = nil;
    }
    return self;
}

// MARK: - current time & duration & content width

- (NSTimeInterval)timeWithWidth:(CGFloat)width {
    return width / self.timeScale;
}

- (CGFloat)widthWithTime:(NSTimeInterval)time {
    return time * self.timeScale;
}

- (NSTimeInterval)currentTime {
    return [self timeWithWidth:_scrollview.contentOffset.x + _scrollview.contentInset.left];
}

- (void)setCurrentTime:(NSTimeInterval)time {
    self.isSettingCurrentTime = YES;
    _scrollview.contentOffset = CGPointMake([self widthWithTime:time] - _scrollview.contentInset.left, _scrollview.contentOffset.y);
    self.isSettingCurrentTime = NO;
}

- (void)setMinDuration:(NSTimeInterval)minDuration {
    if (minDuration == _minDuration) {
        return;
    }
    
    _minDuration = minDuration;
    [self updateDuration:YES];
}

- (void)updateDuration:(BOOL)notify {
    
    NSTimeInterval duration = MAX(_minDuration, _actualDuration);
    _durationIndicator.duration = duration;
    
    CGFloat contentWidth = [self widthWithTime:duration];
    _scrollview.contentSize = CGSizeMake(contentWidth, _scrollview.contentSize.height);
    
    if (_delegate && [_delegate respondsToSelector:@selector(timeline:durationChanged:)]) {
        [_delegate timeline:self durationChanged:duration];
    }
}

- (void)updateDurationIndicatorImmediately {
    NSTimeInterval duration = MAX(_minDuration, [self timeWithWidth:[self actualContentWidth]]);
    _durationIndicator.duration = duration;
}

- (CGFloat)actualContentWidth {
    __block CGFloat contentWidth = 0;
    [_trackerDataList enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull trackerData, NSUInteger idx, BOOL * _Nonnull stop) {
        [trackerData.clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            AUITrackerClipView *clipView = obj.clipView;
            contentWidth = MAX(contentWidth, clipView.source.contentRight - clipView.source.contentLeft + clipView.viewport.position.x);
        }];
    }];
    return contentWidth;
}

- (void)updateContentWidth {
    
    CGFloat actualtWidth = [self actualContentWidth];
    _actualDuration = [self timeWithWidth:actualtWidth];
    
    [self updateDuration:YES];
}

// MARK: - Track & clip

- (BOOL)addTracker:(AUITrackerData *)tracker {
    
    __block NSUInteger index = _trackerDataList.count;
    [_trackerDataList enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.index > tracker.index) {
            index = idx;
        }
    }];
    CGFloat y = self.trackerMarginTop;
    if (index > 0) {
        y = _trackerDataList[index - 1].position.y + _trackerDataList[index - 1].thumbSize.height + self.trackerMarginSpace;
    }
    tracker.position = CGPointMake(0, y);
    tracker.headerView = [tracker.headerViewLoader loadHeaderView];
    tracker.headerView.frame = CGRectMake(-(CGRectGetWidth(_scrollview.bounds) / 2.0), y, CGRectGetWidth(_scrollview.bounds) / 2.0, tracker.thumbSize.height);
    [_scrollview addSubview:tracker.headerView];
    [_trackerDataList insertObject:tracker atIndex:index];
    [tracker addDepthFlagViewForClip:_scrollview];
    
    for (NSUInteger i=index+1; i<_trackerDataList.count; i++) {
        AUITrackerData *data = _trackerDataList[i];
        y = y + _trackerDataList[i - 1].thumbSize.height + self.trackerMarginSpace;
        data.position = CGPointMake(data.position.x, y);
        [data.clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.clipView updateViewportPosition:CGPointMake(obj.clipView.viewport.position.x, y)];
        }];
    }
    
    y = y + _trackerDataList.lastObject.thumbSize.height + self.trackerMarginBottom;
    _scrollview.contentSize = CGSizeMake(_scrollview.contentSize.width, y);
    
    return YES;
}

- (AUITrackerData *)trackerAtIndex:(NSUInteger)index {
    __block AUITrackerData *ret = nil;
    [_trackerDataList enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.index == index) {
            ret = obj;
        }
    }];
    return ret;
}

- (NSArray<AUITrackerData *> *)allTrackers {
    return [_trackerDataList copy];
}

- (BOOL)removeTracker:(AUITrackerData *)tracker {
    if (![_trackerDataList containsObject:tracker]) {
        return NO;
    }
    
    if (tracker.clipList.count > 0) {
        NSArray<AUITrackerClipData *> *clipList = [tracker.clipList copy];
        [clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeOneClip:obj];
        }];
    }
    NSInteger index = [_trackerDataList indexOfObject:tracker];
    CGFloat y = self.trackerMarginTop;
    if (index > 0) {
        y = _trackerDataList[index - 1].position.y + _trackerDataList[index - 1].thumbSize.height + self.trackerMarginSpace;
    }
    for (NSUInteger i=index+1; i<_trackerDataList.count; i++) {
        AUITrackerData *data = _trackerDataList[i];
        data.position = CGPointMake(data.position.x, y);
        [data.clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.clipView updateViewportPosition:CGPointMake(obj.clipView.viewport.position.x, y)];
        }];
        y = y + _trackerDataList[i].thumbSize.height + self.trackerMarginSpace;
    }
    [_trackerDataList removeObject:tracker];
    [tracker.headerView removeFromSuperview];
    [tracker removeDepthFlagViewForClip];
    
    [self updateContentWidth];
    y = y - self.trackerMarginSpace + self.trackerMarginBottom;
    _scrollview.contentSize = CGSizeMake(_scrollview.contentSize.width, y);

    return YES;
}

- (NSArray<AUITrackerClipData *> *)clipsAtTracker:(AUITrackerData *)tracker {
    if (![_trackerDataList containsObject:tracker]) {
        return nil;
    }
    
    return [tracker.clipList copy];
}

- (BOOL)addClip:(AUITrackerClipData *)clip atTracker:(AUITrackerData *)tracker {
    if (![_trackerDataList containsObject:tracker]) {
        return NO;
    }
    
    AUITrackerClipView *lastClipView = tracker.clipList.lastObject.clipView;
    CGFloat startX = lastClipView.source.contentRight - lastClipView.source.contentLeft + lastClipView.viewport.position.x;
    
    clip.trackerData = tracker;
    AUITrackerClipView *clipView = [self trackerClipView:clip startX:startX];
    if (!clipView) {
        return NO;
    }
    
    clip.clipView = clipView;
    [tracker.clipList addObject:clip];
    
    clip.transData.transView = [self transitionView:clip];

    [self updateContentWidth];
    return YES;
}

- (BOOL)removeClip:(AUITrackerClipData *)removedClip {
    AUITrackerData *trackerData = removedClip.trackerData;
    if (![_trackerDataList containsObject:trackerData] || ![trackerData.clipList containsObject:removedClip]) {
        return NO;
    }
    
    AUITrackerClipData *preClipData = nil;
    NSUInteger index = [trackerData.clipList indexOfObject:removedClip];
    if (index > 0) {
        preClipData = [trackerData.clipList objectAtIndex:index-1];
    }

    [self removeOneClip:removedClip];
    
    [self updateTrackerClipList:trackerData current:preClipData completed:nil];
    [self updateTransInfo:preClipData isSelect:_selectedClipData == preClipData];
    NSArray<AUITrackerClipData *> *clips = [self clipListBeenUpdated:trackerData current:preClipData includeCurrent:NO];
    [self updateTransInfo:clips.firstObject isSelect:_selectedClipData == clips.firstObject];

    
    [self updateContentWidth];
    
    // raised update event
    if (clips.count>0 && _delegate && [_delegate respondsToSelector:@selector(timeline:didUpdatedClips:atTracker:byEvent:)]) {
        [_delegate timeline:self didUpdatedClips:clips atTracker:clips.firstObject.trackerData byEvent:AUITimelineViewClipUpdatedEventRemove];
    }
    
    return YES;
}

- (BOOL)removeAllClipsAtTracker:(AUITrackerData *)tracker {
    if (![_trackerDataList containsObject:tracker]) {
        return NO;
    }
    
    if (tracker.clipList.count > 0) {
        NSArray<AUITrackerClipData *> *clipList = [tracker.clipList copy];
        [clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeOneClip:obj];
        }];
        [self updateContentWidth];
    }
    return YES;
}

- (BOOL)removeOneClip:(AUITrackerClipData *)clip {
    if (!clip) {
        return NO;
    }
    
    if (_selectedClipData == clip) {
        [self unselectClipView];
    }
    
    [clip.transData.transView removeFromSuperview];
    clip.transData.transView = nil;
    
    [clip.clipView removeFromSuperview];
    clip.clipView = nil;
    
    AUITrackerData *tracker = clip.trackerData;
    clip.trackerData = nil;
    [tracker.clipList removeObject:clip];
        
    return YES;
}

- (BOOL)updateTrackerClipList:(AUITrackerData *)trackerData current:(AUITrackerClipData *)currentClipData completed:(void(^)(AUITrackerClipData *clipData))completed {
    
    BOOL update = NO;
    BOOL start = trackerData.clipList.count > 0 && currentClipData == nil;
    for (NSUInteger i=0; i<trackerData.clipList.count; i++) {
        AUITrackerClipData *clipData = trackerData.clipList[i];
        if (start) {
            if (!clipData.autoStart) {
                break;
            }
            CGFloat startX = 0;
            if (i > 0) {
                AUITrackerClipView *lastClipView = trackerData.clipList[i-1].clipView;
                startX = lastClipView.source.contentRight - lastClipView.source.contentLeft + lastClipView.viewport.position.x;
                if (clipData.transData.isApply) {
                    startX = startX - clipData.transData.duration  * self.timeScale;
                }
                if (clipData.transData.transView) {
                    CGRect transViewFrame = clipData.transData.transView.frame;
                    transViewFrame.origin.x = startX - (clipData.transData.isApply ? 0 : CGRectGetWidth(transViewFrame) / 2.0);
                    clipData.transData.transView.frame = transViewFrame;
                }
            }
            else {
                [clipData.transData.transView removeFromSuperview];
                clipData.transData.transView = nil;
            }
            
            [clipData.clipView updateViewportPosition:CGPointMake(startX, clipData.clipView.viewport.position.y)];
            [clipData updateWithStart:clipData.clipView.viewport.position.x / _timeScale
                                 withClipStart:clipData.clipView.source.contentLeft * clipData.speed / _timeScale
                                   withClipEnd:clipData.clipView.source.contentRight * clipData.speed / _timeScale];
            if (completed) {
                completed(clipData);
            }
            update = YES;
        }
        else if (clipData == currentClipData) {
            start = YES;
        }
    }
    return update;
}

- (NSArray<AUITrackerClipData *> *)clipListBeenUpdated:(AUITrackerData *)trackerData current:(AUITrackerClipData *)currentClipData includeCurrent:(BOOL)includeCurrent {
    NSMutableArray<AUITrackerClipData *> *clips = [NSMutableArray array];
    BOOL result = trackerData.clipList.count > 0 && currentClipData == nil;
    for (NSUInteger i=0; i<trackerData.clipList.count; i++) {
        AUITrackerClipData *clipData = trackerData.clipList[i];
        if (result) {
            if (!clipData.autoStart) {
                break;
            }
            [clips addObject:clipData];
        }
        if (clipData == currentClipData) {
            if (includeCurrent) {
                [clips addObject:currentClipData];
            }
            result = YES;
        }
    }
    return clips;
}

- (BOOL)updateClip:(AUITrackerClipData *)clip withStart:(NSTimeInterval)start withClipStart:(NSTimeInterval)clipStart withClipEnd:(NSTimeInterval)clipEnd {
    AUITrackerData *tracker = clip.trackerData;
    if (![_trackerDataList containsObject:tracker] || ![tracker.clipList containsObject:clip]) {
        return NO;
    }
    
    CGFloat translateLeft = clipStart / clip.speed * _timeScale - clip.clipView.source.contentLeft;
    [clip.clipView translateSourceContent:translateLeft autoPosition:clip.autoStart isLeft:YES];
    
    CGFloat translateRight = clipEnd / clip.speed * _timeScale - clip.clipView.source.contentRight;
    [clip.clipView translateSourceContent:translateRight autoPosition:clip.autoStart isLeft:NO];
    
    CGPoint pos = clip.clipView.viewport.position;
    pos.x = start;
    [clip.clipView updateViewportPosition:pos];
    
    [clip updateWithStart:clip.clipView.viewport.position.x / _timeScale
            withClipStart:clip.clipView.source.contentLeft * clip.speed / _timeScale
              withClipEnd:clip.clipView.source.contentRight * clip.speed / _timeScale];
    
    [self updateContentWidth];
    
    return YES;
}

- (AUITrackerClipSource *)clipSource:(AUITrackerClipData *)clip viewportWidth:(CGFloat)viewportWidth {
    CGFloat maxContentWidth = clip.duration / clip.speed * self.timeScale;
    NSUInteger count = maxContentWidth / clip.trackerData.thumbSize.width + 1;
    id<AUITrackerClipThumbnailsFetcherProtocol> fetcher = nil;
    if (clip.thumbRequest) {
        NSMutableArray<AUITrackerThumbnailTimeItem *> *thumbItems = [NSMutableArray array];
        NSMutableArray *times = [NSMutableArray array];
        NSTimeInterval timeStep = clip.duration / count;
        for (NSUInteger i=0; i<count; i++) {
            NSTimeInterval time = timeStep * i;
            NSTimeInterval thumbTime = (int64_t)(time * 1000) / 1000.0;
            if (time + timeStep > clip.clipStart && time < clip.clipEnd) {
                // 仅加载一屏缩略图
                if ((time - clip.clipStart) / clip.speed * self.timeScale < viewportWidth)
                {
                    [times addObject:@(thumbTime)];
                }
            }
            AUITrackerThumbnailTimeItem *timeItem = [AUITrackerThumbnailTimeItem new];
            timeItem.time = thumbTime;
            timeItem.duration = timeStep;
            timeItem.bgColor = clip.thumbBgColor;
            timeItem.thumbDisplayMode = clip.thumbDisplayMode;
            timeItem.thumbRequest = clip.thumbRequest;
            [thumbItems addObject:timeItem];
        }
        [clip.thumbRequest requestTimes:times duration:timeStep completed:^(NSTimeInterval time, UIImage *thumb) {
            [thumbItems enumerateObjectsUsingBlock:^(AUITrackerThumbnailTimeItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (ABS(obj.time - time) < 0.001) {
                    obj.thumb = thumb;
                    if (obj.completedBlock) {
                        obj.completedBlock(obj, thumb);
                    }
                }
            }];
        }];
            
        fetcher = [[AUITrackerClipMultipleThumbnailFetcher alloc] initWithSize:clip.trackerData.thumbSize withItems:thumbItems];
    }
    else {
        AUITrackerClipSingleThumbnailFetcher *singleFetcher = [[AUITrackerClipSingleThumbnailFetcher alloc] initWithSize:clip.trackerData.thumbSize withCount:count];
        singleFetcher.thumbColor = clip.thumbBgColor;
        singleFetcher.thumbDisplayMode = clip.thumbDisplayMode;
        singleFetcher.thumbImage = clip.thumbImage;
        fetcher = singleFetcher;
    }
    
    AUITrackerClipSource *source = [AUITrackerClipSource new];
    source.thumbFetcher = fetcher;
    source.contentLeft = clip.clipStart / clip.speed * self.timeScale;
    source.contentRight = clip.clipEnd / clip.speed * self.timeScale;
    source.minContentWidth = 0.1 * self.timeScale;
    source.maxContentWidth = maxContentWidth;
    
    return source;
}

- (AUITrackerClipView *)trackerClipView:(AUITrackerClipData *)clip startX:(CGFloat)startX {
    
    AUITrackerClipView *tra = [[AUITrackerClipView alloc] init];
    
    // viewport
    CGFloat x = clip.start * self.timeScale;
    if (clip.autoStart) {
        x = startX;
        if (clip.trackerData.clipList.count > 0 && clip.transData.isApply) {
            x = x - clip.transData.duration  * self.timeScale;
        }
    }
    AUITrackerClipViewport *viewport = [AUITrackerClipViewport new];
    viewport.position = CGPointMake(x, clip.trackerData.position.y);
    viewport.size = CGSizeMake(self.bounds.size.width, clip.trackerData.thumbSize.height);
    viewport.limitPosition = CGPointMake(_maxDuration == CGFLOAT_MAX ? CGFLOAT_MAX : _maxDuration * self.timeScale, CGFLOAT_MAX);
    
    AUITrackerClipSource *source = [self clipSource:clip viewportWidth:viewport.size.width];
    BOOL result = [tra setSource:source viewport:viewport];
    if (!result) {
        return nil;
    }
    
    [tra setTitleView:[clip.titleViewLoader loadTitleView]];
    [tra updateViewportOffset:_scrollview.contentOffset.x];

    if (!self.disbaleSelectClipByTap) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTrackerViewTap:)];
        [tra addGestureRecognizer:tap];
        tra.userInteractionEnabled = YES;
    }
    
    if (!self.disbaleClipLongPress) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onTrackerViewLongPress:)];
        longPress.minimumPressDuration = 0.5;
        [tra addGestureRecognizer:longPress];
        tra.userInteractionEnabled = YES;
    }

    [clip.trackerData addClipView:tra];
    return tra;
}

// MARK: - Transition

- (AUITrackerClipTransitionInfo *)transInfoWithInData:(AUITrackerClipTransitionData *)inData withOutData:(AUITrackerClipTransitionData *)outData {
    if (!inData && !outData) {
        return nil;
    }
    AUITrackerClipTransitionInfo *info = [AUITrackerClipTransitionInfo new];
    if (inData) {
        info.enableIn = YES;
        info.applyIn = inData.isApply;
        info.widthIn = inData.duration * self.timeScale;
    }
    if (outData) {
        info.enableOut = YES;
        info.applyOut = outData.isApply;
        info.widthOut = outData.duration * self.timeScale;
    }
    return info;
}

- (void)updateTransInfo:(AUITrackerClipData *)currentClip isSelect:(BOOL)isSelected {
    if (!currentClip) {
        return;
    }
    
    AUITrackerClipData *nextClipData = nil;
    NSUInteger index = [currentClip.trackerData.clipList indexOfObject:currentClip];
    if (index != NSNotFound && index < currentClip.trackerData.clipList.count - 1) {
        nextClipData = [currentClip.trackerData.clipList objectAtIndex:index + 1];
    }
    if (nextClipData) {
        [_scrollview bringSubviewToFront:nextClipData.transData.transView];
    }
    AUITrackerClipTransitionInfo *info = [self transInfoWithInData:currentClip.transData withOutData:nextClipData.transData];
    info.isSelected = isSelected;
    [currentClip.clipView setTransitionInfo:info];
}

- (AUITrackerClipTransitionView *)transitionView:(AUITrackerClipData *)clip {
    if (!clip.transData || !clip.autoStart || clip.trackerData.clipList.firstObject == clip) {
        return nil;
    }
    
    AUITrackerClipData *preClipData = nil;
    NSUInteger index = [clip.trackerData.clipList indexOfObject:clip];
    if (index != NSNotFound && index > 0) {
        preClipData = [clip.trackerData.clipList objectAtIndex:index-1];
    }
    if (preClipData) {
        [preClipData.clipView setTransitionInfo:[self transInfoWithInData:preClipData.transData withOutData:clip.transData]];
    }
    [clip.clipView setTransitionInfo:[self transInfoWithInData:clip.transData withOutData:nil]];
    
    CGFloat width = (clip.transData.isApply ? clip.transData.duration : 0.5)  * self.timeScale;
    CGFloat height = clip.clipView.viewport.size.height;
    CGFloat left = clip.clipView.viewport.position.x - (clip.transData.isApply ? 0 : width / 2.0);
    CGFloat top = clip.clipView.viewport.position.y;
    AUITrackerClipTransitionView *transView = [[AUITrackerClipTransitionView alloc] initWithFrame:CGRectMake(left, top, width, height) withWidth:width];
    transView.iconView.image = clip.transData.icon;
    [_scrollview addSubview:transView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTransViewTap:)];
    [transView addGestureRecognizer:tap];
    transView.userInteractionEnabled = YES;
    
    return transView;
}

- (void)onTransViewTap:(UIGestureRecognizer *)gesture {
    if (_delegate && [_delegate respondsToSelector:@selector(timeline:didClickedTransition:)]) {
        AUITrackerClipTransitionView *transView = (AUITrackerClipTransitionView *)gesture.view;
        __block AUITrackerClipData *clipData = nil;
        [_trackerDataList enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull trackerData, NSUInteger idx, BOOL * _Nonnull stop) {
            [trackerData.clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.transData.transView == transView) {
                    clipData = obj;
                    *stop = YES;
                }
            }];
            if (clipData) {
                *stop = YES;
            }
        }];
        [_delegate timeline:self didClickedTransition:clipData];
    }
}

// MARK: - select

- (AUITrackerClipData *)currentSelectedClip {
    return _selectedClipData;
}

- (BOOL)selectClip:(AUITrackerClipData *)clip {
    AUITrackerData *tracker = clip.trackerData;
    if (!tracker || ![_trackerDataList containsObject:tracker]) {
        return NO;
    }
    
    [self selectClipView:clip.clipView byTap:NO];
    return YES;
}

- (BOOL)clearSelected {
    return [self unselectClipView];
}

- (void)selectClipView:(AUITrackerClipView *)clipView byTap:(BOOL)tap {
    if (_selectedClipData.clipView == clipView) {
        return;
    }
    [self unselectClipView];
    
    __block AUITrackerClipData *clipData = nil;
    [_trackerDataList enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull trackerData, NSUInteger idx, BOOL * _Nonnull stop) {
        [trackerData.clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.clipView == clipView) {
                clipData = obj;
                *stop = YES;
            }
        }];
        if (clipData) {
            *stop = YES;
        }
    }];
    
    if (!clipData) {
        return;
    }
    
    if (tap && _delegate && [_delegate respondsToSelector:@selector(timeline:didClickedClip:)]) {
        [_delegate timeline:self didClickedClip:clipData];
    }
    
    if (!clipData.enableSelected) {
        return;
    }
    
    _selectedClipData = clipData;
    [_selectedClipData.trackerData updateClipViewDepth:_selectedClipData.clipView];
    
    [_scrollview bringSubviewToFront:_selectionView];
    
    [_scrollview bringSubviewToFront:_selectedClipData.transData.transView];
    NSUInteger index = [_selectedClipData.trackerData.clipList indexOfObject:_selectedClipData];
    if (index != NSNotFound && index < _selectedClipData.trackerData.clipList.count - 1) {
        AUITrackerClipData *nextClipData = [_selectedClipData.trackerData.clipList objectAtIndex:index + 1];
        [_scrollview bringSubviewToFront:nextClipData.transData.transView];
    }
    [self updateTransInfo:_selectedClipData isSelect:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(timeline:didSelectedClip:)]) {
        [_delegate timeline:self didSelectedClip:_selectedClipData];
    }
    
    _selectionView.frame = _selectedClipData.clipView.frame;
    _selectionView.enablePanGesture = _selectedClipData.enablePanLeftRight;
    _selectionView.hidden = NO;
}

- (BOOL)unselectClipView {
    if (_selectedClipData.clipView) {
        [_selectedClipData.trackerData updateClipViewDepth:_selectedClipData.clipView];
        [self updateTransInfo:_selectedClipData isSelect:NO];
        _selectedClipData = nil;
        
        _selectionView.frame = CGRectZero;
        _selectionView.hidden = YES;
        return YES;
    }
    return NO;
}

- (void)onTrackerViewTap:(UIGestureRecognizer *)gesture {
    if (!self.disbaleSelectClipByTap) {
        AUITrackerClipView *tra = (AUITrackerClipView *)gesture.view;
        [self selectClipView:tra byTap:YES];
    }
}

// MARK: - Pan
- (CGFloat)onPanChanged:(CGPoint)delta reachEdge:(BOOL)reachEdge {
    BOOL isLeft = _panDataParser.draggingView == _selectionView.leftView;
    CGFloat dx = delta.x;
    
    CGFloat applyOffset = [_selectedClipData.clipView translateSourceContent:dx autoPosition:_selectedClipData.autoStart isLeft:isLeft];
    [_selectedClipData.clipView updateViewportOffset:_scrollview.contentOffset.x];
    _selectionView.frame = _selectedClipData.clipView.frame;
    [_selectionView layoutSubviews];
    
    [_selectedClipData updateWithStart:_selectedClipData.clipView.viewport.position.x / _timeScale
                         withClipStart:_selectedClipData.clipView.source.contentLeft * _selectedClipData.speed / _timeScale
                           withClipEnd:_selectedClipData.clipView.source.contentRight * _selectedClipData.speed / _timeScale];
    if (_delegate && [_delegate respondsToSelector:@selector(timeline:onUpdatingClip:byEvent:)]) {
        [_delegate timeline:self onUpdatingClip:_selectedClipData byEvent:isLeft ? AUITimelineViewClipUpdatedEventPanLeft : AUITimelineViewClipUpdatedEventPanRight];
    }
    
    __weak typeof(self) weakSelf = self;
    [self updateTrackerClipList:_selectedClipData.trackerData current:_selectedClipData completed:^(AUITrackerClipData *clipData) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(timeline:onUpdatingClip:byEvent:)]) {
            [weakSelf.delegate timeline:weakSelf onUpdatingClip:clipData byEvent:AUITimelineViewClipUpdatedEventMove];
        }
    }];
    
    [self updateDurationIndicatorImmediately];
        
    CGFloat panViewX = [_panDataParser.draggingView convertPoint:_panDataParser.clickPositionInDraggingView toView:_scrollview].x;
    CGPoint currentPosition = _panDataParser.currentPosition;
    currentPosition.x = currentPosition.x - (delta.x - applyOffset);
    _scrollview.contentOffset = CGPointMake(panViewX - currentPosition.x, _scrollview.contentOffset.y);
    return applyOffset;
}

- (BOOL)shouldPanBegan:(CGPoint)delta {
    BOOL isLeft = _panDataParser.draggingView == _selectionView.leftView;
    CGFloat dx = delta.x;
    return [_selectedClipData.clipView checkSourceContentTranslate:dx autoPosition:_selectedClipData.autoStart isLeft:isLeft];
}

- (void)onPanEnd {

    [self updateContentWidth];

    BOOL isLeft = _panDataParser.draggingView == _selectionView.leftView;
    if (isLeft) {
        CGFloat contentOffsetX = _selectedClipData.clipView.viewport.position.x -_scrollview.contentInset.left;
        _scrollview.contentOffset = CGPointMake(contentOffsetX, _scrollview.contentOffset.y);
    }
    else {
        CGFloat contentOffsetX = _selectedClipData.clipView.viewport.position.x +  _selectedClipData.clipView.source.contentRight - _selectedClipData.clipView.source.contentLeft - _scrollview.contentInset.right;
        _scrollview.contentOffset = CGPointMake(contentOffsetX, _scrollview.contentOffset.y);
    }
    
    // raised update event
    if (_delegate && [_delegate respondsToSelector:@selector(timeline:didUpdatedClips:atTracker:byEvent:)]) {
        NSArray<AUITrackerClipData *> *clips = [self clipListBeenUpdated:_selectedClipData.trackerData current:_selectedClipData includeCurrent:YES];
        [_delegate timeline:self didUpdatedClips:clips atTracker:_selectedClipData.trackerData byEvent:isLeft ? AUITimelineViewClipUpdatedEventPanLeft : AUITimelineViewClipUpdatedEventPanRight];
    }
}

- (void)onSelectionPanGestureAction:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    CGPoint panViewPos = [gesture locationInView:gesture.view];

    __weak typeof(self) weakSelf = self;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _panDataParser = [[AlivcDraggingDataParser alloc] init];
            _panDataParser.draggingView = gesture.view;
            _panDataParser.leftEdge = 50;
            _panDataParser.rightEdge = CGRectGetWidth(self.bounds) - 50;
            _panDataParser.checkChangedPosition = ^BOOL(CGPoint delta) {
                return [weakSelf shouldPanBegan:delta];
            };
            [_panDataParser began:point clipPosInDraggingView:panViewPos];
        } break;
        case UIGestureRecognizerStateChanged: {
            [_panDataParser changedPosition:point completed:^CGFloat(CGPoint delta, BOOL reachEdge) {
                return [weakSelf onPanChanged:delta reachEdge:reachEdge];
            }];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (_panDataParser.dataChanged) {
                [self onPanEnd];
            }
            [_panDataParser end];
            _panDataParser = nil;
        } break;
        default: break;
    }
}

// MARK: - Long press
- (CGFloat)onLongPressChanged:(CGPoint)delta reachEdge:(BOOL)reachEdge {
    CGFloat dx = delta.x;

    CGFloat applyOffset = [_selectedClipData.clipView translateViewportPosition:dx];
    [_selectedClipData.clipView updateViewportOffset:_scrollview.contentOffset.x];
    _selectionView.frame = _selectedClipData.clipView.frame;
    [_selectionView layoutSubviews];
    
    [_selectedClipData updateWithStart:_selectedClipData.clipView.viewport.position.x / _timeScale
                         withClipStart:_selectedClipData.clipView.source.contentLeft * _selectedClipData.speed / _timeScale
                           withClipEnd:_selectedClipData.clipView.source.contentRight * _selectedClipData.speed / _timeScale];
    if (_delegate && [_delegate respondsToSelector:@selector(timeline:onUpdatingClip:byEvent:)]) {
        [_delegate timeline:self onUpdatingClip:_selectedClipData byEvent:AUITimelineViewClipUpdatedEventMove];
    }

    __weak typeof(self) weakSelf = self;
    [self updateTrackerClipList:_selectedClipData.trackerData current:_selectedClipData completed:^(AUITrackerClipData *clipData) {
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(timeline:onUpdatingClip:byEvent:)]) {
            [weakSelf.delegate timeline:weakSelf onUpdatingClip:clipData byEvent:AUITimelineViewClipUpdatedEventMove];
        }
    }];
    
    [self updateDurationIndicatorImmediately];

    CGFloat panViewX = [_longPressDataParser.draggingView convertPoint:_longPressDataParser.clickPositionInDraggingView toView:_scrollview].x;
    CGPoint currentPosition = _longPressDataParser.currentPosition;
    currentPosition.x = currentPosition.x - (delta.x - applyOffset);
    _scrollview.contentOffset = CGPointMake(panViewX - currentPosition.x, _scrollview.contentOffset.y);

    return applyOffset;
}

- (BOOL)shouldLongPressBegan:(CGPoint)delta {
    CGFloat dx = delta.x;
    return [_selectedClipData.clipView checkViewportPositionTranslate:dx autoPosition:_selectedClipData.autoStart];
}

- (void)onLongPressBegan {
    AUITrackerClipView *clipView = (AUITrackerClipView *)_longPressDataParser.draggingView;
    [self selectClipView:clipView byTap:NO];
    clipView.alpha = 0.5;
    _selectionView.alpha = 0;
}

- (void)onLongPressEnd {
    AUITrackerClipView *clipView = (AUITrackerClipView *)_longPressDataParser.draggingView;
    clipView.alpha = 1;
    _selectionView.alpha = 1;
    
    [self updateContentWidth];
    
    if (_delegate && [_delegate respondsToSelector:@selector(timeline:didUpdatedClips:atTracker:byEvent:)]) {
        NSArray<AUITrackerClipData *> *clips = [self clipListBeenUpdated:_selectedClipData.trackerData current:_selectedClipData includeCurrent:YES];
        [_delegate timeline:self didUpdatedClips:clips atTracker:_selectedClipData.trackerData byEvent:AUITimelineViewClipUpdatedEventMove];
    }
}

- (void)onTrackerViewLongPress:(UILongPressGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    CGPoint panViewPos = [gesture locationInView:gesture.view];

    __weak typeof(self) weakSelf = self;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _longPressDataParser = [[AlivcDraggingDataParser alloc] init];
            _longPressDataParser.draggingView = gesture.view;
            _longPressDataParser.leftEdge = 50;
            _longPressDataParser.rightEdge = CGRectGetWidth(self.bounds) - 50;
            _longPressDataParser.checkChangedPosition = ^BOOL(CGPoint delta) {
                return [weakSelf shouldLongPressBegan:delta];
            };
            [_longPressDataParser began:point clipPosInDraggingView:panViewPos];
            [self onLongPressBegan];
        } break;
        case UIGestureRecognizerStateChanged: {
            [_longPressDataParser changedPosition:point completed:^CGFloat(CGPoint delta, BOOL reachEdge) {
                return [weakSelf onLongPressChanged:delta reachEdge:reachEdge];
            }];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self onLongPressEnd];
            [_longPressDataParser end];
            _longPressDataParser = nil;
        } break;
        default: break;
    }
}

// MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_trackerDataList enumerateObjectsUsingBlock:^(AUITrackerData * _Nonnull tracker, NSUInteger idx, BOOL * _Nonnull stop) {
        [tracker.clipList enumerateObjectsUsingBlock:^(AUITrackerClipData * _Nonnull clip, NSUInteger idx, BOOL * _Nonnull stop) {
            [clip.clipView updateViewportOffset:scrollView.contentOffset.x];
        }];
    }];
    
    if (_selectedClipData.clipView) {
        _selectionView.frame = _selectedClipData.clipView.frame;
    }
        
    NSTimeInterval currentTime = [self currentTime];
    _durationIndicator.currentTime = currentTime;
    if (!self.isSettingCurrentTime && _delegate && [_delegate respondsToSelector:@selector(timeline:currentTimeChanged:)]) {
        [_delegate timeline:self currentTimeChanged:currentTime];
    }
}

@end
