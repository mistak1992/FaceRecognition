#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (FaceRecognition)

+ (UIImage *)faceRecognition_imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (UIImage *)faceRecognition_imageCropRect:(CGRect)rect;

- (UIImage *)faceRecognition_imageScaledToSize:(CGSize)newSize;

- (UIImage *)faceRecognition_fixOrientation;

+ (UIImage *)faceRecognition_rotateImageEx:(CGImageRef)imgRef byDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

+ (UIImage *)faceRecognition_rotateImageEx:(CGImageRef)imgRef orientation:(UIImageOrientation) orient;

@end

NS_ASSUME_NONNULL_END
