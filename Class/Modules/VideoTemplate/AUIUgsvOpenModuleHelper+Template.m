//
//  AUIUgsvOpenModuleHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import "AUIUgsvOpenModuleHelper+Template.h"
#import "AUIUgsvPath.h"
#import "AUIUgsvMacro.h"

#import "AUIVideoTemplateListViewController.h"

#import "AlivcUgsvSDKHeader.h"

@implementation AUIUgsvOpenModuleHelper (Template)

+ (void)openTemplateList:(UIViewController *)currentVC {
    if (![AliyunAETemplateManager canSupport]) {
        [AVAlertController show:AUIUgsvGetString(@"当前机型不支持")];
        return;
    }
    AUIVideoTemplateListViewController *vc = [[AUIVideoTemplateListViewController alloc] init];
    [currentVC.navigationController pushViewController:vc animated:YES];
}
@end

