//
//  AUITrackerClipTransitionView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/26.
//

#import "AUITrackerClipTransitionView.h"
#import "AUITimelineViewAppearance.h"

@interface AUITrackerClipTransitionView ()

@end

@implementation AUITrackerClipTransitionView

- (instancetype)initWithFrame:(CGRect)frame withWidth:(CGFloat)width {
    self = [super initWithFrame:frame];
    if (self) {
        self.width = width;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.backgroundColor = [AUITimelineViewAppearance defaultAppearcnce].transitionIconViewBackgroundColor;
        [self addSubview:_iconView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _iconView.frame = CGRectMake(0, 0, 16, 16);
    _iconView.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) / 2.0);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect validRect = UIEdgeInsetsInsetRect(self.iconView.frame, UIEdgeInsetsMake(-4, -4, -4, -4));
    if (CGRectContainsPoint(validRect, point)) {
        return [super pointInside:point withEvent:event];
    }
    return NO;
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    CGPoint center = self.center;
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
    self.center = center;
}

@end
