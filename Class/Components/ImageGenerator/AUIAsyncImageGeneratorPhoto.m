//
//  AUIAsyncImageGeneratorPhoto.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/4.
//

#import "AUIAsyncImageGeneratorPhoto.h"

@interface AUIAsyncImageGeneratorPhoto ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) UIImage *image;

@end

@implementation AUIAsyncImageGeneratorPhoto

- (instancetype)initWithPath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
        _image = [UIImage imageWithContentsOfFile:_filePath];
    }
    return self;
}

- (void)generateImagesAsynchronouslyForTimes:(NSArray *)times duration:(NSTimeInterval)duration completed:(void (^)(NSTimeInterval, UIImage *))completed {
    [times enumerateObjectsUsingBlock:^(NSNumber *second, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(second.doubleValue, self.image);
            }
        });
    }];
}

@end
