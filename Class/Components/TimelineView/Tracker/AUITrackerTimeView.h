//
//  AUITrackerTimeView.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import <UIKit/UIKit.h>

@interface AUITrackerTimeView : UIView

@property (nonatomic, assign) NSUInteger timeScale;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval currentTime;

@end
