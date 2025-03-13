# AUIUgsv
阿里云 · AUI Kits 短视频生产场景

## 代码结构
```
├── AUIUgsv                                    // AUI短视频
│   ├── AUIBaseKits                            // 依赖的AUI基础组件源码文件
│       ├── AUIBeauty                          // 依赖美颜组件
│       ├── AUIFoundation                      // 依赖基础UI组件
│   ├── Class                                  // 源码文件
│   ├── framework                              // 依赖的其他库
│   ├── Resources                              // 资源文件
│   ├── AUIUgsv.podspec                        // 客户可以通过该podspec自动集成短视频AUI组件
│   ├── Example                                // AUI短视频组件的Demo
│       ├── AUIUgsvDemo                        // Demo源码
│       ├── AUIUgsvDemo.xcodeproj              // Demo的Project
│       ├── AUIUgsvDemo.xcworkspace            // Demo的workspace
│       ├── Podfile                            // Demo的podfile文件
│   ├── README.md                              // Readme
```


## 跑通demo

1. 源码下载后，进入目录Example
2. 在根目录下执行“pod install  --repo-update”，自动安装依赖SDK
3. 打开工程文件“AUIUgsvDemo.xcworkspace”，修改包Id
4. 在控制台上申请试用License，获取License文件和LicenseKey，如果已有直接进入下一步
5. 把License文件放到AUIUgsvDemo/目录下，并修改文件名为“license.crt”
6. 把“LicenseKey”（如果没有，请在控制台拷贝），打开“AUIUgsvDemo/Info.plist”，填写到字段“AlivcLicenseKey”的值中
7. 编译运行


## 集成组件说明
根据自己的功能需求，选择合适的组件依赖，快速开发与上线

> 注意：下面的涉及到的版本号，推荐使用官网发布的最新版本，参考[短视频SDK](https://help.aliyun.com/zh/vod/developer-reference/short-video-sdk-for-ios-1)  [组合包SDK](https://help.aliyun.com/zh/apsara-video-sdk/developer-reference/fast-integration-of-apsaravideo-mediabox-sdk-for-ios)

业务场景：
- 短视频全功能，使用专业版包
  - 功能说明：拍摄（包含人脸贴纸）+合拍+编辑+裁剪+高级美颜（可选）
  - 前提条件：开通专业版License，开通对应的增值服务（动图贴纸+字幕），开通Queen License（可选）
  - pod集成方式：
  ```ruby
    def aliyun_ugsv_pro
        # 【必须】短视频专业版SDK
        pod 'AliVCSDK_ShortVideo', '7.0.0'
        
        # 【必须】短视频全功能UI组件
        pod "AUIUgsv/AliVCSDK_ShortVideo", :path => "../"
        pod 'AUIUgsv/Recorder', :path => "../"
        pod 'AUIUgsv/Editor', :path => "../"
        pod 'AUIUgsv/Clipper', :path => "../"
        
        # 【必须】集成基础UI组件
        pod "AUIFoundation/All", :path => "../AUIBaseKits/AUIFoundation"
        
        # 【可选】使用Queen专业版美颜
        pod "AUIBeauty/Queen", :path => "../AUIBaseKits/AUIBeauty"
    end
  ```
---

- 短视频全功能，使用UGC组合包
  - 功能说明：包含短视频全功能+美颜（可选）
  - 前提条件：开通短视频专业版License，开通对应的增值服务（动图贴纸+字幕），开通Queen License（可选）
  - 其他说明：如果你的APP还需要使用到阿里云的播放器SDK，那么需要使用这种集成方式
  - pod集成方式：
  ```ruby
    def aliyun_ugsv_ugc
        # 【必须】Standard组合包
        pod 'AliVCSDK_UGC', '7.0.0'
        
        # 【可选】拍摄功能如果需要人脸贴纸，需要引入，否则无需引入
        pod 'AliVCSDK_UGC/AlivcUgsvBundle'

        # 【必须】短视频全功能UI组件
        pod "AUIUgsv/AliVCSDK_UGC", :path => "../"
        pod 'AUIUgsv/Recorder', :path => "../"
        pod 'AUIUgsv/Editor', :path => "../"
        pod 'AUIUgsv/Clipper', :path => "../"
        
        # 【必须】集成基础UI组件
        pod "AUIFoundation/All", :path => "../AUIBaseKits/AUIFoundation"
        
        # 【可选】集成美颜UI组件，有以下3种可选形式，请根据自己业务选择
        # 1、使用Queen专业版美颜（下面代码使用第一种，无需修改AUIBeauty的集成方式）
        # 2、使用基础美颜，SDK使用组合包才可以使用这种方式，把下面的“Queen”替换为“AliVCSDK_UGC”
        # 3、不需要使用美颜，则无需集成，注掉下面代码
        pod "AUIBeauty/Queen", :path => "../AUIBaseKits/AUIBeauty"
        
    end
  ```
---

- 短视频全功能，使用Standard组合包
  - 功能说明：包含短视频全功能+美颜（可选）
  - 前提条件：开通短视频专业版License，开通对应的增值服务（动图贴纸+字幕），开通Queen License（可选）
  - 其他说明：如果你的APP还需要使用到阿里云的播放器SDK/直播推流SDK/RTC SDK，那么需要使用这种集成方式
  - pod集成方式：
  ```ruby
    def aliyun_ugsv_full
        # 【必须】Standard组合包
        pod 'AliVCSDK_Standard', '7.0.0'
        
        # 【可选】拍摄功能如果需要人脸贴纸，需要引入，否则无需引入
        pod 'AliVCSDK_Standard/AlivcUgsvBundle'

        # 【必须】短视频全功能UI组件
        pod "AUIUgsv/AliVCSDK_Standard", :path => "../"
        pod 'AUIUgsv/Recorder', :path => "../"
        pod 'AUIUgsv/Editor', :path => "../"
        pod 'AUIUgsv/Clipper', :path => "../"
        
        # 【必须】集成基础UI组件
        pod "AUIFoundation/All", :path => "../AUIBaseKits/AUIFoundation"
        
        # 【可选】集成美颜UI组件，有以下3种可选形式，请根据自己业务选择
        # 1、使用Queen专业版美颜（下面代码使用第一种，无需修改AUIBeauty的集成方式）
        # 2、使用基础美颜，SDK使用组合包才可以使用这种方式，把下面的“Queen”替换为“AliVCSDK_Standard”
        # 3、不需要使用美颜，则无需集成，注掉下面代码
        pod "AUIBeauty/Queen", :path => "../AUIBaseKits/AUIBeauty"
    end
  ```

