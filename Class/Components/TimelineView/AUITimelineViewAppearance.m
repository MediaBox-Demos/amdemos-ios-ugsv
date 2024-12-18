//
//  AUITimelineViewAppearance.m
//  AUIUgsvCom
//
//  Created by Bingo on 2022/8/8.
//

#import "AUITimelineViewAppearance.h"

@implementation AUITimelineViewAppearance

+ (AUITimelineViewAppearance *)defaultAppearcnce {
    static AUITimelineViewAppearance *_instance = nil;
    if (!_instance) {
        _instance = [AUITimelineViewAppearance new];
        _instance.selectionViewColor = [UIColor colorWithRed:0xfc / 255.0 green:0xfc / 255.0 blue:0xfd / 255.0 alpha:1.0];
        _instance.selectionViewLeftImage = nil;
        _instance.selectionViewRightImage = nil;
        
        _instance.transitionIconViewBackgroundColor = [UIColor colorWithRed:0xfc / 255.0 green:0xfc / 255.0 blue:0xfd / 255.0 alpha:1.0];
        _instance.transitionIconViewFillColor = [UIColor colorWithRed:0x1c / 255.0 green:0x1e / 255.0 blue:0x22 / 255.0 alpha:0.4];
        
        _instance.trackerThumbnailCellBackgroundColor = [UIColor colorWithRed:0xfc / 255.0 green:0xfc / 255.0 blue:0xfd / 255.0 alpha:0.2];
        
        _instance.trackerTimeCellColor = [UIColor colorWithRed:0x74 / 255.0 green:0x7a / 255.0 blue:0x8c / 255.0 alpha:1.0];
        _instance.timeIndicatorCellColor = [UIColor colorWithRed:0xfc / 255.0 green:0xfc / 255.0 blue:0xfd / 255.0 alpha:1.0];
    }
    return _instance;
}



@end
