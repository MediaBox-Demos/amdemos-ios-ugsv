//
//  AUIUgsvOpenModuleHelper.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import <UIKit/UIKit.h>
#import "AUIUgsvOpenModuleHelper.h"
#import "AUIVideoOutputParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIUgsvOpenModuleHelper (Editor)

+ (void)openEditor:(UIViewController *)currentVC
             param:(nullable AUIVideoOutputParam *)param
      publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam;

+ (void)openEditor:(UIViewController *)currentVC
          taskPath:(NSString *)taskPath
      publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam;

+ (void)openEditor:(UIViewController *)currentVC
         videoPath:(NSString *)videoPath
       outputParam:(AUIVideoOutputParam *)outputParam
      publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam;

@end

NS_ASSUME_NONNULL_END
