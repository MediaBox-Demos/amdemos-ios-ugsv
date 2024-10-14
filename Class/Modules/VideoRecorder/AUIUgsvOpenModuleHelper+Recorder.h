//
//  AUIUgsvOpenModuleHelper.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import <UIKit/UIKit.h>
#import "AUIUgsvOpenModuleHelper.h"
#import "AUIVideoOutputParam.h"
#import "AUIRecorderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIUgsvRecorderFinishInfo : NSObject

@property (nonatomic, copy) NSString *taskPath;
@property (nonatomic, assign) BOOL mergeOnFinish;
@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, strong) AUIRecorderConfig *config;
@property (nonatomic, strong) AUIUgsvPublishParamInfo *publishParam;

@end



@interface AUIUgsvOpenModuleHelper (Recorder)

+ (void)openRecorder:(UIViewController *)currentVC
              config:(nullable AUIRecorderConfig *)config
         finishBlock:(nullable void(^)(AUIUgsvRecorderFinishInfo *finishInfo))finishBlock
        publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam;

+ (void)openMixRecorder:(UIViewController *)currentVC
                 config:(nullable AUIRecorderConfig *)config
            finishBlock:(nullable void(^)(AUIUgsvRecorderFinishInfo *finishInfo))finishBlock
           publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam;

+ (AUIVideoOutputParam *)videoOutputParamFromRecorderConfig:(AUIRecorderConfig *)config;

@end

NS_ASSUME_NONNULL_END
