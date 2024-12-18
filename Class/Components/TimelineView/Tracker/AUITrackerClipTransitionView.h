//
//  AUITrackerClipTransitionView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUITrackerClipTransitionView : UIView

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong, readonly) UIImageView *iconView;

- (instancetype)initWithFrame:(CGRect)frame withWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
