//
//  AUIUgsvOpenModuleHelper.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIUgsvPublishParamInfo : NSObject

@property (nonatomic, assign) BOOL saveToAlbum;
@property (nonatomic, assign) BOOL needToPublish;
+ (AUIUgsvPublishParamInfo *) InfoWithSaveToAlbum:(BOOL)saveToAlbum needToPublish:(BOOL)needToPublish;

@end

@interface AUIUgsvOpenModuleHelper : NSObject

+ (void)openPickerToPublish:(UIViewController *)currentVC;

@end

NS_ASSUME_NONNULL_END
