#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

@class FaceRecognizeView;

typedef NS_ENUM(NSUInteger, FaceRecognizeViewScaleType) {
    FaceRecognizeViewScaleTypeNone,
    FaceRecognizeViewScaleTypePreviewWidth,
    FaceRecognizeViewScaleTypeScreenWidth,
    FaceRecognizeViewScaleTypeCustom,
};

typedef struct FaceRecognizeConfigurationStruct {
    CGRect previewFrame; // relate to mainScreen
    AVCaptureDevicePosition devicePosition;
    FaceRecognizeViewScaleType scaleType;
    CGFloat scale; // only work for FaceRecognizeViewScaleTypeCustom, relate to preview width
    AVCaptureSessionPreset sessionPreset; // default is AVCaptureSessionPresetHigh
    AVLayerVideoGravity videoGravity; // default is AVLayerVideoGravityResizeAspect
} FaceRecognizeConfiguration;

@protocol FaceRecognizeViewDelegate <NSObject>

- (void)faceRecognizeView:(FaceRecognizeView *)faceRecognizeView didGetFaceImage:(UIImage *)image;

- (BOOL)faceRecognizeView:(FaceRecognizeView *)faceRecognizeView canGetFaceImageFromFaceDetectRect:(CGRect)faceDetectRect;

@end

@interface FaceRecognizeView : UIView

@property (nonatomic, copy) NSString *metadataType;

@property (nonatomic, weak) id<FaceRecognizeViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame configuration:(FaceRecognizeConfiguration)configure;

- (void)start;

- (void)stop;

@end
