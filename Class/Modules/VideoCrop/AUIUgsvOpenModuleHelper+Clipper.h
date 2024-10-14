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

@interface AUIUgsvOpenModuleHelper (Clipper)

+ (void)openClipper:(UIViewController *)currentVC
              param:(nullable AUIVideoOutputParam *)param
       publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam;

@end

NS_ASSUME_NONNULL_END
