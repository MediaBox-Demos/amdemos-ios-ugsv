//
//  AUIUgsvModuleHeader.h
//  AlivcUgsvDemo
//
//  Created by Bingo on 2024/9/5.
//

#ifndef AUIUgsvModuleHeader_h
#define AUIUgsvModuleHeader_h


#if __has_include("AUIUgsvOpenModuleHelper+Recorder.h")
#import "AUIUgsvOpenModuleHelper+Recorder.h"
#define ENABLE_UGSV_RECORDER
#endif

#if __has_include("AUIUgsvOpenModuleHelper+Editor.h")
#import "AUIUgsvOpenModuleHelper+Editor.h"
#define ENABLE_UGSV_EDITOR
#endif

#if __has_include("AUIUgsvOpenModuleHelper+Clipper.h")
#import "AUIUgsvOpenModuleHelper+Clipper.h"
#define ENABLE_UGSV_CLIPPER
#endif

#if __has_include("AUIUgsvOpenModuleHelper+Template.h")
#import "AUIUgsvOpenModuleHelper+Template.h"
#define ENABLE_UGSV_TEMPLATE
#endif

#if defined(ENABLE_UGSV_RECORDER) || defined(ENABLE_UGSV_EDITOR) || defined(ENABLE_UGSV_CLIPPER) || defined(ENABLE_UGSV_TEMPLATE)
#import "AUIUgsvMacro.h"
#import "AUIUgsvPath.h"
#import "AlivcUgsvSDKHeader.h"
#define ENABLE_UGSV_COMMON

#endif

#endif /* AUIUgsvModuleHeader_h */
