//
//  AUITrackerThumbnailRequest.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/3.
//

#import "AUITrackerThumbnailRequest.h"

@interface AUITrackerThumbnailRequest ()

@property (nonatomic, strong) id<AUIAsyncImageGeneratorProtocol> imageGenerator;


@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *imageCache;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *currentRequest;

@end

@implementation AUITrackerThumbnailRequest

- (instancetype)initWithGenerator:(id<AUIAsyncImageGeneratorProtocol>)generator {
    self = [super init];
    if (self) {
        _imageGenerator = generator;
    }
    return self;
}

-  (NSMutableDictionary<NSNumber *,UIImage *> *)imageCache {
    if (!_imageCache) {
        _imageCache = [NSMutableDictionary dictionary];
    }
    return _imageCache;
}

- (NSMutableArray<NSNumber *> *)currentRequest {
    if (!_currentRequest) {
        _currentRequest = [NSMutableArray array];
    }
    return _currentRequest;
}

- (void)requestTimes:(NSArray *)times duration:(NSTimeInterval)duration completed:(void (^)(NSTimeInterval, UIImage *))completed {

    NSMutableArray *requestTimes = [NSMutableArray array];
    [times enumerateObjectsUsingBlock:^(NSNumber *second, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL find = NO;
        [self.imageCache enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
            if (ABS(second.doubleValue - key.doubleValue) < 0.001) {
                UIImage *thumb = [self.imageCache objectForKey:key];
                if (completed) {
                    completed(second.doubleValue, thumb);
                }
                find = YES;
                *stop = YES;
            }
        }];
        if (!find) {
            [requestTimes addObject:second];
        }
    }];

    NSMutableArray *array = [NSMutableArray arrayWithArray:requestTimes];
    [array enumerateObjectsUsingBlock:^(NSNumber *second, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.currentRequest enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (second.doubleValue == obj.doubleValue) {
                // already in requesting, so remove from request list
                [requestTimes removeObject:second];
            }
        }];
    }];

    if (requestTimes.count > 0) {
        __weak typeof(self) weakSelf = self;
        NSLog(@"imageGenerator all:%@", requestTimes);
        [self.currentRequest addObjectsFromArray:requestTimes];
        [self.imageGenerator generateImagesAsynchronouslyForTimes:requestTimes duration:duration completed:^(NSTimeInterval time, UIImage *image) {
            if (image) {
                NSLog(@"imageGenerator time:%f", time);
                [weakSelf.imageCache setObject:image forKey:@(time)];
                if (completed) {
                    completed(time, image);
                }
            }
            [weakSelf.currentRequest removeObject:@(time)];
            NSLog(@"imageGenerator remove:%zd", weakSelf.currentRequest.count);
            if (weakSelf.currentRequest == 0) {
                // all completed
            }
        }];
    }
}

@end
