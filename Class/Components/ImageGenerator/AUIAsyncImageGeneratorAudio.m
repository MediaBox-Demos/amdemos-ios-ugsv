//
//  AUIAsyncImageGeneratorAudio.m
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/30.
//

#import "AUIAsyncImageGeneratorAudio.h"
#import <AVFoundation/AVFoundation.h>

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))

@interface AUIAsyncImageGeneratorAudio ()

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, strong) NSData *dbData;
@property (nonatomic, assign) UInt32 dbRate;
@property (nonatomic, assign) Float32 normalizeMax;
@property (nonatomic, assign) UInt32 channelCount;
@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) BOOL fetchingDBData;
@property (nonatomic, strong) NSMutableArray *inputTimes;

@end

@implementation AUIAsyncImageGeneratorAudio

- (instancetype)initWithPath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _filePath = filePath;
        _fetchingDBData = NO;
        _inputTimes = [NSMutableArray array];
    }
    return self;
}

- (void)generateImagesAsynchronouslyForTimes:(NSArray *)times duration:(NSTimeInterval)duration completed:(void (^)(NSTimeInterval, UIImage *))completed {
    [self.inputTimes addObjectsFromArray:times];
    self.duration = duration;
    if (self.dbData) {
        [self generateImagesAsynchronously:completed];
    }
    else {
        if (self.fetchingDBData) {
            return;
        }
        self.fetchingDBData = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @autoreleasepool {
                [AUIAsyncImageGeneratorAudio fetchAudioDBData:[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.filePath] options:nil] completed:^(NSData *dbData, UInt32 dbRate, Float32 normalizeMax, UInt32 channelCount, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.dbData = dbData;
                        self.dbRate = dbRate;
                        self.normalizeMax = normalizeMax;
                        self.channelCount = channelCount;
                        self.fetchingDBData = NO;
                        [self generateImagesAsynchronously:completed];
                    });
                }];
            }
        });
    }
}

- (void)generateImagesAsynchronously:(void (^)(NSTimeInterval, UIImage *))completed {
    NSArray *inputTimes = [self.inputTimes copy];
    Float32 *samples = (Float32 *)self.dbData.bytes;
    Float32 normalizeMax = self.normalizeMax;
    UInt32 dbRate = self.dbRate;
    UInt32 channelCount = self.channelCount;
    NSInteger sampleCount = self.duration * dbRate;
    NSInteger allSampleCount = self.dbData.length / (sizeof(Float32) * channelCount);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [inputTimes enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSTimeInterval time = [obj doubleValue];
            NSInteger sampleStart = time * dbRate;
            if (sampleStart < allSampleCount) {
                UIImage *image = [AUIAsyncImageGeneratorAudio drawImageDBData:samples normalizeMax:normalizeMax sampleStart:sampleStart sampleCount:MIN(sampleCount, allSampleCount - sampleStart) channelCount:channelCount imageHeight:100];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed) {
                        completed(time, image);
                    }
                });
            }
            else {
                if (completed) {
                    completed(time, nil);
                }
            }
        }];
    });
    [self.inputTimes removeAllObjects];
}

+ (UIImage *)drawImageDBData:(Float32 *)samples
                normalizeMax:(Float32)normalizeMax
                 sampleStart:(NSInteger)sampleStart
                 sampleCount:(NSInteger)sampleCount
                channelCount:(NSInteger)channelCount
                 imageHeight:(CGFloat)imageHeight {

    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();

//    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
//    CGContextSetAlpha(context,1.0);
//    CGRect rect;
//    rect.size = imageSize;
//    rect.origin.x = 0;
//    rect.origin.y = 0;
//    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);

    CGFloat center = imageHeight / 2;
    CGFloat factor = imageHeight / (normalizeMax - noiseFloor) / 2;
    NSInteger sampleIndex = sampleStart * channelCount;
    for (NSInteger position = 0; position < sampleCount; position++) {
        Float32 db = samples[sampleIndex++];
        if (channelCount == 2) {
            db = (db + samples[sampleIndex++]) / 2.0;
        }
        float pixels = (db - noiseFloor) * factor;
        CGContextMoveToPoint(context, position, center - pixels);
        CGContextAddLineToPoint(context, position, center + pixels);
        CGContextStrokePath(context);
    }

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

+ (void)fetchAudioDBData:(AVURLAsset *)audioAsset completed:(void(^)(NSData *dbData, UInt32 dbRate, Float32 normalizeMax, UInt32 channelCount, NSError *error))completed {
    return [self fetchAudioDBData:audioAsset sampleRate:50 completed:completed];
}
    
+ (void)fetchAudioDBData:(AVURLAsset *)audioAsset
              sampleRate:(UInt32)targetSampleRate
               completed:(void(^)(NSData *dbData,
                                  UInt32 dbRate,
                                  Float32 normalizeMax,
                                  UInt32 channelCount,
                                  NSError *error))completed {
    NSError * error = nil;
    AVAssetReader * reader = [[AVAssetReader alloc] initWithAsset:audioAsset error:&error];
    if (error) {
        if (completed) {
            completed(nil, 0, 0, 0, [NSError errorWithDomain:@"" code:-1 userInfo:@{
                NSUnderlyingErrorKey:error
            }]);
        }
        return;
    }
    
    NSArray *audioTracks = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count == 0) {
        if (completed) {
            completed(nil, 0, 0, 0, [NSError errorWithDomain:@"" code:-2 userInfo:nil]);
        }
        return;
    }
    AVAssetTrack * audioTrack = [audioTracks objectAtIndex:0];
    
    
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];

    UInt32 sampleRate = 0,channelCount = 0;
    NSArray* formatDesc = audioTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        if(fmtDesc ) {
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
        }
    }

    UInt32 bytesPerSample = 2 * channelCount;
    Float32 normalizeMax = noiseFloor;
    NSMutableData * dBData = [[NSMutableData alloc] init];
    Float64 totalLeft = 0;
    Float64 totalRight = 0;
    Float32 sampleTally = 0;
    UInt32 samplesPerPixel = sampleRate / targetSampleRate;

    [reader startReading];
    while (reader.status == AVAssetReaderStatusReading){

        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        if (sampleBufferRef){
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            NSMutableData * data = [NSMutableData dataWithLength:length];
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);

            SInt16 * samples = (SInt16 *)data.mutableBytes;
            NSInteger sampleCount = (NSInteger)(length / bytesPerSample);
            for (NSInteger i = 0; i < sampleCount ; i ++) {

                Float32 left = (Float32)*samples++;
                left = decibel(left);
                left = minMaxX(left, noiseFloor, 0);
                totalLeft  += left;

                Float32 right;
                if (channelCount == 2) {
                    right = (Float32) *samples++;
                    right = decibel(right);
                    right = minMaxX(right, noiseFloor, 0);
                    totalRight += right;
                }

                sampleTally++;
                if (sampleTally > samplesPerPixel) {

                    left  = totalLeft / sampleTally;
                    if (left > normalizeMax) {
                        normalizeMax = left;
                    }
//                     NSLog(@"left average = %f, normalizeMax = %f",left,normalizeMax);
                    [dBData appendBytes:&left length:sizeof(left)];

                    if (channelCount == 2) {
                        right = totalRight / sampleTally;
                        if (right > normalizeMax) {
                            normalizeMax = right;
                        }
                        [dBData appendBytes:&right length:sizeof(right)];
                    }

                    totalLeft   = 0;
                    totalRight  = 0;
                    sampleTally = 0;
                }
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }

    if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown){
        if (completed) {
            completed(nil, 0, 0, 0, [NSError errorWithDomain:@"" code:-3 userInfo:nil]);
        }
        return;
    }

    if (completed) {
        completed(dBData, samplesPerPixel, normalizeMax, channelCount, nil);
    }
}

@end
