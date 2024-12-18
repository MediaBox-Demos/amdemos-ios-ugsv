//
//  AUITrackerClipView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <UIKit/UIKit.h>

@interface AUITrackerThumbnailItem : NSObject

@property (nonatomic, copy) UIColor *bgColor;
@property (nonatomic, assign) UIViewContentMode thumbDisplayMode;
@property (nonatomic, strong) UIImage *thumb;
- (void)requestThumbImage:(void(^)(AUITrackerThumbnailItem *item, UIImage *thumb))completed;
- (void)cancelRequest;

@end


@interface AUITrackerThumbnailCell : UICollectionViewCell

@property (nonatomic, strong) AUITrackerThumbnailItem *item;

@property (nonatomic, strong, readonly) UIImageView *thumbImageView;

@end

@protocol AUITrackerClipThumbnailsFetcherProtocol <NSObject>

@property (nonatomic, assign, readonly) CGSize thumbSize;
@property (nonatomic, assign, readonly) NSUInteger thumbItemsCount;
@property (nonatomic, copy, readonly) AUITrackerThumbnailItem *(^thumbItemAtIndexBlock)(NSUInteger index);

@end

@interface AUITrackerClipSource : NSObject<NSCopying>

@property (nonatomic, strong) id<AUITrackerClipThumbnailsFetcherProtocol> thumbFetcher;

@property (nonatomic, assign) CGFloat contentLeft;
@property (nonatomic, assign) CGFloat contentRight;
@property (nonatomic, assign) CGFloat minContentWidth;
@property (nonatomic, assign) CGFloat maxContentWidth;

@end


@interface AUITrackerClipViewport : NSObject<NSCopying>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGPoint limitPosition;

@end

@interface AUITrackerClipTransitionInfo : NSObject

@property (nonatomic, assign) BOOL enableIn;
@property (nonatomic, assign) BOOL applyIn;
@property (nonatomic, assign) CGFloat widthIn;

@property (nonatomic, assign) BOOL enableOut;
@property (nonatomic, assign) BOOL applyOut;
@property (nonatomic, assign) CGFloat widthOut;

@property (nonatomic, assign) BOOL isSelected;

@end

@interface AUITrackerClipView : UIView

@property (nonatomic, copy, readonly) AUITrackerClipSource *source;
@property (nonatomic, copy, readonly) AUITrackerClipViewport *viewport;

- (void)setTransitionInfo:(AUITrackerClipTransitionInfo *)info;

- (void)setTitleView:(UIView *)titleView;
- (BOOL)setSource:(AUITrackerClipSource *)source viewport:(AUITrackerClipViewport *)viewport;

- (void)updateViewportOffset:(CGFloat)offset;
- (void)updateViewportPosition:(CGPoint)position;

- (BOOL)checkSourceContentTranslate:(CGFloat)dx autoPosition:(BOOL)autoPosition isLeft:(BOOL)isLeft;
- (CGFloat)translateSourceContent:(CGFloat)dx autoPosition:(BOOL)autoPosition isLeft:(BOOL)isLeft;

- (BOOL)checkViewportPositionTranslate:(CGFloat)dx autoPosition:(BOOL)autoPosition;
- (CGFloat)translateViewportPosition:(CGFloat)dx;


@end
