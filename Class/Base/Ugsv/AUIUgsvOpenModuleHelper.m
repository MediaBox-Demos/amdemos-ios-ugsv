//
//  AUIUgsvOpenModuleHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import "AUIUgsvOpenModuleHelper.h"
#import "AUIUgsvPath.h"
#import "AUIUgsvMacro.h"
#import "AUIPhotoPicker.h"
#import "AUIMediaPublisher.h"

@implementation AUIUgsvPublishParamInfo

+ (AUIUgsvPublishParamInfo *) InfoWithSaveToAlbum:(BOOL)saveToAlbum needToPublish:(BOOL)needToPublish {
    AUIUgsvPublishParamInfo *info = [AUIUgsvPublishParamInfo new];
    info.saveToAlbum = saveToAlbum;
    info.needToPublish = needToPublish;
    return info;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _saveToAlbum = YES;
        _needToPublish = NO;
    }
    return self;
}

@end


@implementation AUIUgsvOpenModuleHelper

+ (void)openPickerToPublish:(UIViewController *)currentVC {
    __weak typeof(currentVC) weakVC = currentVC;
    AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:1 withAllowPickingImage:NO withAllowPickingVideo:YES withTimeRange:kCMTimeRangeZero];
    [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
        if (results.firstObject) {
            [sender dismissViewControllerAnimated:NO completion:^{
                AUIPhotoPickerResult *result = results.firstObject;
                [self publish:weakVC filePath:result.filePath withThumbnailImage:result.model.thumbnailImage];
            }];
        }
    } withOutputDir:[AUIUgsvPath cacheDir]];
    
    [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
}

+ (void)publish:(UIViewController *)currentVC filePath:(NSString *)filePath withThumbnailImage:(UIImage *)thumb  {
    __weak typeof(currentVC) weakVC = currentVC;
    AUIMediaPublisher *publisher = [[AUIMediaPublisher alloc] initWithVideoFilePath:filePath withThumbnailImage:thumb];
    publisher.onFinish = ^(UIViewController * _Nonnull current, NSError * _Nullable error, id  _Nullable product) {
        if (error) {
            [AVAlertController showWithTitle:AUIUgsvGetString(@"出错了") message:error.description needCancel:NO onCompleted:^(BOOL isCanced) {
                [current.navigationController popToViewController:weakVC animated:YES];
            }];
        }
        else {
            [AVAlertController showWithTitle:nil message:AUIUgsvGetString(@"发布成功了") needCancel:NO onCompleted:^(BOOL isCanced) {
                [current.navigationController popToViewController:weakVC animated:YES];
            }];
        }
    };
    [currentVC.navigationController pushViewController:publisher animated:YES];
}

@end

