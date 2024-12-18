//
//  AUITrackerClipSelectionView.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUITrackerClipSelectionView.h"
#import "AUITimelineViewAppearance.h"

@interface AUITrackerClipSelectionView ()

@property (nonatomic, strong) UIView *borderView;

@end

@implementation AUITrackerClipSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;

        _borderView = [[UIView alloc] initWithFrame:self.bounds];
        _borderView.userInteractionEnabled = NO;
        _borderView.layer.borderColor = [AUITimelineViewAppearance defaultAppearcnce].selectionViewColor.CGColor;
        _borderView.layer.borderWidth = [self sectionEdgeSize].height;
        [self addSubview:_borderView];
        
        _leftView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _leftView.backgroundColor = [AUITimelineViewAppearance defaultAppearcnce].selectionViewColor;
        _leftView.image = [AUITimelineViewAppearance defaultAppearcnce].selectionViewLeftImage;
        _leftView.contentMode = UIViewContentModeCenter;
        _leftView.userInteractionEnabled = YES;
        [self addSubview:_leftView];

        _rightView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _rightView.backgroundColor = [AUITimelineViewAppearance defaultAppearcnce].selectionViewColor;
        _rightView.image = [AUITimelineViewAppearance defaultAppearcnce].selectionViewRightImage;
        _rightView.contentMode = UIViewContentModeCenter;
        _rightView.userInteractionEnabled = YES;
        [self addSubview:_rightView];
    }
    return self;
}

- (CGSize)sectionEdgeSize {
    // width: pan width
    // height: border width
    return CGSizeMake(16, 2);
}

- (void)setEnablePanGesture:(BOOL)enablePanGesture {
    _enablePanGesture = enablePanGesture;
    _leftView.hidden = !enablePanGesture;
    _rightView.hidden = !enablePanGesture;
}

- (void)setFrame:(CGRect)frame {
    frame = CGRectInset(frame, - [self sectionEdgeSize].width - [self sectionEdgeSize].height, -[self sectionEdgeSize].height);
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat borderWidth = [self sectionEdgeSize].height;
    CGFloat panViewWidth = [self sectionEdgeSize].width + borderWidth;

    _borderView.frame = CGRectInset(self.bounds, [self sectionEdgeSize].width, 0);
    
    _leftView.frame = CGRectMake(0, 0, panViewWidth, CGRectGetHeight(self.frame));
    UIBezierPath *leftMaskPath = [UIBezierPath bezierPathWithRoundedRect:_leftView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *leftMaskLayer = [[CAShapeLayer alloc] init];
    leftMaskLayer.frame = _leftView.bounds;
    leftMaskLayer.path = leftMaskPath.CGPath;
    _leftView.layer.mask = leftMaskLayer;
    
    _rightView.frame = CGRectMake(CGRectGetWidth(self.frame) - panViewWidth, 0, panViewWidth, CGRectGetHeight(self.frame));
    UIBezierPath *rightMaskPath = [UIBezierPath bezierPathWithRoundedRect:_rightView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *rightMaskLayer = [[CAShapeLayer alloc] init];
    rightMaskLayer.frame = _rightView.bounds;
    rightMaskLayer.path = rightMaskPath.CGPath;
    _rightView.layer.mask = rightMaskLayer;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.leftView.hidden && CGRectContainsPoint(UIEdgeInsetsInsetRect(self.leftView.frame, UIEdgeInsetsMake(0, -4, 0, -4)), point)) {
        return self.leftView;
    }
    if (!self.rightView.hidden && CGRectContainsPoint(UIEdgeInsetsInsetRect(self.rightView.frame, UIEdgeInsetsMake(0, -4, 0, -4)), point)) {
        return self.rightView;
    }
    return nil;
}

@end
