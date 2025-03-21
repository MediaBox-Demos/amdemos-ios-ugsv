//
//  AlivcUgsvSDKHeader.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2022/5/25.
//

#ifndef AlivcUgsvSDKHeader_h
#define AlivcUgsvSDKHeader_h

#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#elif __has_include(<AliVCSDK_ShortVideo/AliVCSDK_ShortVideo.h>)
#import <AliVCSDK_ShortVideo/AliVCSDK_ShortVideo.h>

#elif __has_include(<AliyunVideoSDKBasic/AliyunVideoSDKBasic.h>)
#import <AliyunVideoSDKBasic/AliyunVideoSDKBasic.h>
#define USING_SVIDEO_BASIC 1

#endif


#if __has_include("AUIBeautyManager.h")
#import "AUIBeautyManager.h"
#define ENABLE_BEAUTY
#endif

#endif /* AlivcUgsvSDKHeader_h */
