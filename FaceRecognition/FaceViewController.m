//
//  FaceViewController.m
//  FaceRecognition
//
//  Created by liyang on 17/2/29.
//  Copyright © 2017年 kosienDGL. All rights reserved.
//

#import "FaceViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "UIImage+FaceRecognition.h"

dispatch_semaphore_t semaphore;

@interface FaceViewController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIAlertViewDelegate>
// 硬件设备
@property (nonatomic, strong) AVCaptureDevice *device;
// 输入流
@property (nonatomic, strong) AVCaptureDeviceInput *input;
// meta输出流
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;      //用于二维码识别以及人脸识别
// video输出流
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
// 会话
@property (nonatomic, strong) AVCaptureSession *session;
// 预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
// 脸框框
@property (nonatomic, strong) UIView *faceRectView;

@property (nonatomic, strong) UIImageView *imageV;

@property (nonatomic, assign) BOOL isGetFaceImage;

@end

@implementation FaceViewController


#pragma mark - 获取硬件设备
- (AVCaptureDevice *)device
{
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([_device lockForConfiguration:nil]) {   //上锁（调整device属性的时候需要上锁）
            //自动闪光灯
            if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [_device setFlashMode:AVCaptureFlashModeAuto];
            }
            //自动白平衡
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
                [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            }
            //自动对焦
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            }
            //自动曝光
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [_device unlockForConfiguration];//解锁
        }
    }
    return _device;
}

#pragma mark - 获取硬件的输入流
- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}

#pragma mark - meta输出流
- (AVCaptureMetadataOutput *)metadataOutput
{
    if (_metadataOutput == nil) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        _metadataOutput.rectOfInterest = self.view.bounds;  //设置扫描区域
    }
    return _metadataOutput;
}

#pragma mark - video输出流
- (AVCaptureVideoDataOutput *)videoDataOutput{
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        dispatch_queue_t queue = dispatch_queue_create("video_buffer_handle_queue", NULL);
        [_videoDataOutput setSampleBufferDelegate:self queue:queue];
    }
    return _videoDataOutput;
}

#pragma mark - 协调输入和输出数据的会话
- (AVCaptureSession *)session
{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.metadataOutput]) {
            [_session addOutput:self.metadataOutput];
            //设置扫描类型
            if ([self.metadataType isEqualToString:@"1"]) {
                //人脸识别
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
            } else if ([self.metadataType isEqualToString:@"2"]) {
                //二维码识别
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                                            AVMetadataObjectTypeEAN13Code,
                                                            AVMetadataObjectTypeEAN8Code,
                                                            AVMetadataObjectTypeCode128Code];
            }
        }
        if ([_session canAddOutput:self.videoDataOutput]) {
            [_session addOutput:self.videoDataOutput];
        }
    }
    return _session;
}

#pragma mark - 预览图像的层
- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.view.layer.bounds;
    }
    return _previewLayer;
}

#pragma mark - 生命周期
- (void)start{
    [self.session startRunning];
}

- (void)stop{
    [self.session stopRunning];
    self.session = nil;
//    [self.previewLayer removeFromSuperlayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stop];
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 信号量
    semaphore = dispatch_semaphore_create(1);
    
    self.view.backgroundColor = [UIColor whiteColor];
    //把previewLayer添加到self.view.layer上
    [self.view.layer addSublayer:self.previewLayer];
    
    //设置导航栏右边按钮
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(switchCamera)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - 切换前后置摄像头
- (void)switchCamera
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            self.faceRectView.hidden = YES;
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
            } else {
                [self.session addInput:self.input];
            }
            [self.session commitConfiguration];
        }
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

#pragma mark - 脸框框
- (UIView *)faceRectView{
    if (_faceRectView == nil) {
        _faceRectView = [UIView new];
        _faceRectView.layer.cornerRadius = 5;
        _faceRectView.layer.borderColor = [UIColor orangeColor].CGColor;
        _faceRectView.layer.borderWidth = 2;
        [self.view addSubview:_faceRectView];
        _faceRectView.hidden = YES;
    }
    return _faceRectView;
}

- (UIImageView *)imageV{
    if (_imageV == nil) {
        _imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 88, 120, 120)];
        _imageV.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageV];
    }
    return _imageV;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"扫描完成 = %zd个 == %@", metadataObjects.count, metadataObjects);
    // 用于获取人脸图片信号量
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    self.isGetFaceImage = NO;
    dispatch_semaphore_signal(semaphore);
    // 判断metaData
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if ([self.metadataType isEqualToString:@"1"]) {
            //人脸识别结果
            AVMetadataObject *faceData = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            NSLog(@"faceData == %@", faceData);
            self.faceRectView.frame = faceData.bounds;
            self.faceRectView.hidden = NO;
            // 用于获取人脸图片信号量
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            self.isGetFaceImage = YES;
            dispatch_semaphore_signal(semaphore);
        }else if ([self.metadataType isEqualToString:@"2"]) {
            //二维码识别结果
            [self.session stopRunning];
            NSLog(@"QRCode is : %@", metadataObject.stringValue);
        }
    } else {
        //
        self.faceRectView.hidden = YES;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (self.isGetFaceImage == YES) {
        NSLog(@"%@", [NSThread currentThread]);
        UIImage* sampleImage = [UIImage faceRecognition_imageFromSampleBuffer:sampleBuffer];
        NSLog(@"调用了%@", sampleImage);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageV.backgroundColor = [UIColor redColor];
            self.imageV.image = sampleImage;
            // callback
            if ([self.delegate respondsToSelector:@selector(faceViewController:didGetFaceImage:)] == YES) {
                [self.delegate faceViewController:self didGetFaceImage:sampleImage];
            }
        });
        // 下一张
        self.isGetFaceImage = NO;
    }
    dispatch_semaphore_signal(semaphore);
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

-(BOOL)locationFilter:(AVMetadataObject*)faceData{
    CGFloat imgViewX = _faceRectView.frame.origin.x;
    CGFloat imgViewY = _faceRectView.frame.origin.y;
    CGFloat imgViewWidth = _faceRectView.frame.size.width;
    
    CGFloat faceX = faceData.bounds.origin.x;
    CGFloat faceY = faceData.bounds.origin.y;
    CGFloat faceWidth = faceData.bounds.size.width;
    if (imgViewY-50 < faceY && faceY < imgViewY + 90) {
        if (imgViewX-50 < faceX && faceX < imgViewX+50) {
            if (imgViewWidth-50 < faceWidth && faceWidth < imgViewWidth+50) {
                return YES;
                //self.faceImageView.frame = faceData.bounds;
                //self.faceImageView.hidden = NO;
            }
        }
    }
    return NO;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
