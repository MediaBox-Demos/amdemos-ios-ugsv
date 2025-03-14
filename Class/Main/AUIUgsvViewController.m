//
//  AUIUgsvViewController.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/21.
//

#import "AUIUgsvViewController.h"
#import "AUIUgsvModuleHeader.h"
#import "AUIUgsvMoreViewController.h"


typedef NS_ENUM(NSUInteger, AUIUgsvEntranceType) {
    AUIUgsvEntranceTypeRecorder,
    AUIUgsvEntranceTypeMixRecorder,
    AUIUgsvEntranceTypeEditor,
    AUIUgsvEntranceTypeClipper,
    AUIUgsvEntranceTypeMore
};

@interface AUIUgsvViewController ()
@end

@implementation AUIUgsvViewController

- (instancetype)init {
    AVCommonListItem *item1 = [AVCommonListItem new];
    item1.title = AUIUgsvGetString(@"视频拍摄");
    item1.info = @"";
    item1.icon = AUIUgsvGetImage(@"ic_ugsv_recorder");
    item1.tag = AUIUgsvEntranceTypeRecorder;

    AVCommonListItem *item2 = [AVCommonListItem new];
    item2.title = AUIUgsvGetString(@"视频合拍");
    item2.info = @"";
    item2.icon = AUIUgsvGetImage(@"ic_ugsv_mix_recorder");
    item2.tag = AUIUgsvEntranceTypeMixRecorder;
    
    AVCommonListItem *item3 = [AVCommonListItem new];
    item3.title = AUIUgsvGetString(@"视频编辑");
    item3.info = @"";
    item3.icon = AUIUgsvGetImage(@"ic_ugsv_editor");
    item3.tag = AUIUgsvEntranceTypeEditor;
    
    AVCommonListItem *item4 = [AVCommonListItem new];
    item4.title = AUIUgsvGetString(@"视频裁剪");
    item4.info = @"";
    item4.icon = AUIUgsvGetImage(@"ic_ugsv_clipper");
    item4.tag = AUIUgsvEntranceTypeClipper;
    
    AVCommonListItem *item5 = [AVCommonListItem new];
    item5.title = AUIUgsvGetString(@"更多");
    item5.info = @"";
    item5.icon = AUIUgsvGetImage(@"ic_ugsv_more");
    item5.tag = AUIUgsvEntranceTypeMore;
    
    
    
    NSArray *list = @[item1, item2, item3, item4, item5];
    
    self = [super initWithItemList:list];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hiddenMenuButton = YES;
    self.titleView.text = AUIUgsvGetString(@"短视频");
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AVCommonListItem *item = [self.itemList objectAtIndex:indexPath.row];
    switch (item.tag) {
        case AUIUgsvEntranceTypeRecorder:
        {
            [self openRecorder];
        }
            break;
        case AUIUgsvEntranceTypeMixRecorder: 
        {
            [self openMixRecorder];
        }
            break;
        case AUIUgsvEntranceTypeEditor:
        {
            [self openEditor];
        }
            break;
        case AUIUgsvEntranceTypeClipper:
        {
            [self openClipper];
        }
            break;
        case AUIUgsvEntranceTypeMore:
        {
            [self openMore];
        }
            break;
        default:
            break;
    }
}

- (void)openRecorder {
#ifdef ENABLE_UGSV_RECORDER
    [AUIUgsvOpenModuleHelper openRecorder:self config:nil finishBlock:^(AUIUgsvRecorderFinishInfo *info){
        [self openEditorAfterFinish:info];
    } publishParam:nil];
#else
    [AVAlertController show:AUIUgsvGetString(@"当前集成的SDK或模块不支持")];
#endif
}

- (void)openMixRecorder {
#ifdef ENABLE_UGSV_RECORDER
    [AUIUgsvOpenModuleHelper openMixRecorder:self config:nil finishBlock:^(AUIUgsvRecorderFinishInfo *info){
        [self openEditorAfterFinish:info];
    } publishParam:nil];
#else
    [AVAlertController show:AUIUgsvGetString(@"当前集成的SDK或模块不支持")];
#endif
}

- (void)openEditor {
#ifdef ENABLE_UGSV_EDITOR
    [AUIUgsvOpenModuleHelper openEditor:self param:nil publishParam:nil];
#else
    [AVAlertController show:AUIUgsvGetString(@"当前集成的SDK或模块不支持")];
#endif
}

#ifdef ENABLE_UGSV_RECORDER
- (void)openEditorAfterFinish:(AUIUgsvRecorderFinishInfo *)info {
#ifdef ENABLE_UGSV_EDITOR
    if (info.config.mergeOnFinish) {
        AUIVideoOutputParam *outputParam = [AUIUgsvOpenModuleHelper videoOutputParamFromRecorderConfig:info.config];
        [AUIUgsvOpenModuleHelper openEditor:self videoPath:info.outputPath outputParam:outputParam publishParam:info.publishParam];
    }
    else {
        [AUIUgsvOpenModuleHelper openEditor:self taskPath:info.taskPath publishParam:info.publishParam];
    }
#endif
}
#endif


- (void)openClipper {
#ifdef ENABLE_UGSV_CLIPPER
    [AUIUgsvOpenModuleHelper openClipper:self param:nil publishParam:nil];
#else
    [AVAlertController show:AUIUgsvGetString(@"当前集成的SDK或模块不支持")];
#endif
}

- (void)openMore {
    AUIUgsvMoreViewController *vc = [[AUIUgsvMoreViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
