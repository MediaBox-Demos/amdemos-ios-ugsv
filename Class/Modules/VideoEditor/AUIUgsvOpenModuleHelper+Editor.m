//
//  AUIUgsvOpenModuleHelper.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/15.
//

#import "AUIUgsvOpenModuleHelper+Editor.h"
#import "AUIUgsvPath.h"
#import "AUIUgsvMacro.h"

#import "AUIPhotoPicker.h"
#import "AUIVideoEditor.h"

#import "AlivcUgsvSDKHeader.h"

@implementation AUIUgsvOpenModuleHelper (Editor)


+ (void)openEditor:(UIViewController *)currentVC
             param:(AUIVideoOutputParam *)param
      publishParam:(AUIUgsvPublishParamInfo *)publishParam {
    if (!param) {
        param = [AUIVideoOutputParam Portrait720P];
    }
    if (!publishParam) {
        publishParam = [AUIUgsvPublishParamInfo new];
    }
    
    __weak typeof(currentVC) weakVC = currentVC;
    AUIPhotoPicker *picker = [[AUIPhotoPicker alloc] initWithMaxPickingCount:6 withAllowPickingImage:YES withAllowPickingVideo:YES withTimeRange:CMTimeRangeMake(CMTimeMake(100, 1000), CMTimeMake(3600*1000, 1000))];
    [picker onSelectionCompleted:^(AUIPhotoPicker * _Nonnull sender, NSArray<AUIPhotoPickerResult *> * _Nonnull results) {
        if (results.count > 0) {
            NSMutableArray<AliyunClip *> *clips = [NSMutableArray array];
            [results enumerateObjectsUsingBlock:^(AUIPhotoPickerResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.filePath.length == 0) {
                    return;
                }
                if (obj.model.type == AUIPhotoAssetTypePhoto) {
                    AliyunClip *clip = [[AliyunClip alloc] initWithImagePath:obj.filePath duration:obj.model.assetDuration animDuration:0];
                    [clips addObject:clip];
                }
                else {
                    AliyunClip *clip = [[AliyunClip alloc] initWithVideoPath:obj.filePath animDuration:0];
                    [clips addObject:clip];
                }
            }];
            if (clips.count > 0) {
                [sender dismissViewControllerAnimated:NO completion:^{
                    AUIVideoEditor *editor = [[AUIVideoEditor alloc] initWithClips:clips withParam:param];
                    editor.saveToAlbumExportCompleted = publishParam.saveToAlbum;
                    editor.needToPublish = publishParam.needToPublish;
                    [weakVC.navigationController pushViewController:editor animated:YES];
                    
                }];
            }
            else {
                [AVAlertController show:AUIUgsvGetString(@"选择的视频出错了或无权限") vc:sender];
            }
        }
    } withOutputDir:[AUIUgsvPath cacheDir]];
    [currentVC av_presentFullScreenViewController:picker animated:YES completion:nil];
}

+ (void)openEditor:(UIViewController *)currentVC
          taskPath:(NSString *)taskPath
      publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam {
    AUIVideoEditor *editor = [[AUIVideoEditor alloc] initWithTaskPath:taskPath];
    editor.saveToAlbumExportCompleted = publishParam.saveToAlbum;
    editor.needToPublish = publishParam.needToPublish;
    [currentVC.navigationController pushViewController:editor animated:YES];
}

+ (void)openEditor:(UIViewController *)currentVC
         videoPath:(NSString *)videoPath
       outputParam:(AUIVideoOutputParam *)outputParam
      publishParam:(nullable AUIUgsvPublishParamInfo *)publishParam {
    AliyunClip *clip = [[AliyunClip alloc] initWithVideoPath:videoPath animDuration:0];
    AUIVideoEditor *editor = [[AUIVideoEditor alloc] initWithClips:@[clip] withParam:outputParam];
    editor.saveToAlbumExportCompleted = publishParam.saveToAlbum;
    editor.needToPublish = publishParam.needToPublish;
    [currentVC.navigationController pushViewController:editor animated:YES];
}

@end

