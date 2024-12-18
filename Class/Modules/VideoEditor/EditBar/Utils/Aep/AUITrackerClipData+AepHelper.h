//
//  AUITrackerClipData+AepHelper.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/6/23.
//

#import "AlivcUgsvSDKHeader.h"
#import "AUITimelineView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUITrackerClipData (AepHelper)

- (void)setAepObject:(id)aepObject;
- (id)getAepObject;

- (AEPVideoTrackClip *)aepVideoTrackClipObj;
- (AEPCaptionTrack *)aepCaptionTrackObj;
- (AEPGifStickerTrack *)aepStickerTrackObj;
- (AEPEffectAnimationFilterTrack *)aepAnimationFilterTrackObj;

@end

NS_ASSUME_NONNULL_END
