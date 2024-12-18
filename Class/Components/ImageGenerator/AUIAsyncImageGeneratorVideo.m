//
//  AUIAsyncImageGeneratorVideo.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#import "AUIAsyncImageGeneratorVideo.h"

@interface AUIAsyncImageGeneratorVideo ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@end

@implementation AUIAsyncImageGeneratorVideo

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if (self) {
        if (asset) {
            _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            _imageGenerator.appliesPreferredTrackTransform = YES;
            _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
            _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
            _imageGenerator.maximumSize = CGSizeMake(200, 200);
        }
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVAsset *asset = [AVAsset assetWithURL:url];
    return [self initWithAsset:asset];
}

- (void)generateImagesAsynchronouslyForTimes:(NSArray *)times duration:(NSTimeInterval)duration completed:(void (^)(NSTimeInterval, UIImage *))completed {
    if (!self.imageGenerator) {
        [times enumerateObjectsUsingBlock:^(NSNumber *second, NSUInteger idx, BOOL * _Nonnull stop) {
            if (completed) {
                completed(second.doubleValue, nil);
            }
        }];
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    [times enumerateObjectsUsingBlock:^(NSNumber *second, NSUInteger idx, BOOL * _Nonnull stop) {
        CMTime time = CMTimeMake(second.doubleValue * 1000, 1000);
        NSValue *value = [NSValue valueWithCMTime:time];
        [array addObject:value];
    }];
    NSLog(@"request times: %@", array);
    if (array.count > 0) {
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:array completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable cgimage, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            NSLog(@"request time return: %f", CMTimeGetSeconds(requestedTime));
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (result == AVAssetImageGeneratorSucceeded) {
                    UIImage *thumb = [[UIImage alloc] initWithCGImage:cgimage];
                    if (completed) {
                        completed(CMTimeGetSeconds(requestedTime), thumb);
                    }
                }
                else {
                    if (completed) {
                        completed(CMTimeGetSeconds(requestedTime), nil);
                    }
                }
            });
        }];
    }
}

@end
