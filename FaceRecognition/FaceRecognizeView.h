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
    CGFloat offsetX; // capture screen center relate to preview center, horizontal
    CGFloat offsetY; // capture screen center relate to preview center, vertical
    FaceRecognizeViewScaleType scaleType;
    CGFloat scale; // only work for FaceRecognizeViewScaleTypeCustom, relate to preview width
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
