//
//  AUIUgsvOpenModuleHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import "AUIUgsvOpenModuleHelper+Clipper.h"
#import "AUIUgsvPath.h"
#import "AUIUgsvMacro.h"

#import "AUIPhotoPicker.h"
#import "AUIVideoCrop.h"

#import "AlivcUgsvSDKHeader.h"

@implementation AUIUgsvOpenModuleHelper (Clipper)

+ (void)openClipper:(UIViewController *)currentVC
              param:(AUIVideoOutputParam *)param
       publishParam:(AUIUgsvPublishParamInfo *)publishParam {
    if (!param) {
        param = [AUIVideoOutputParam Portrait720P];
    }
    if (!publishParam) {
        publishParam = [AUIUgsvPublishParamInfo new];
    }
    
    __weak typeof(currentVC) weakVC = currentVC;
    AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:1 withAllowPickingImage:NO withAllowPickingVideo:YES withTimeRange:kCMTimeRangeZero];
    [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
        if (results.firstObject && results.firstObject.filePath.length > 0) {
            [sender dismissViewControllerAnimated:NO completion:^{
                AUIVideoCrop *crop = [[AUIVideoCrop alloc] initWithFilePath:results.firstObject.filePath withParam:param];
                crop.saveToAlbumExportCompleted = publishParam.saveToAlbum;
                crop.needToPublish = publishParam.needToPublish;
                [weakVC.navigationController pushViewController:crop animated:YES];
            }];
        }
        else {
            [AVAlertController show:AUIUgsvGetString(@"选择的视频出错了或无权限") vc:sender];
        }
    } withOutputDir:[AUIUgsvPath cacheDir]];
    
    [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
}


@end

