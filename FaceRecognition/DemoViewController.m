//
//  DemoViewController.m
//  FaceRecognition
//
//  Created by mist on 2020/6/19.
//  Copyright © 2020 kosienDGL. All rights reserved.
//

#import "DemoViewController.h"

#include "FaceRecognizeView.h"

@interface DemoViewController () <FaceRecognizeViewDelegate>

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect previewRect = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 150, [UIScreen mainScreen].bounds.size.height / 2 - 200, 200, 200);
    
    FaceRecognizeConfiguration conf;
    conf.devicePosition = AVCaptureDevicePositionFront;
    conf.previewFrame = previewRect;
    conf.scaleType = FaceRecognizeViewScaleTypeScreenWidth;
//    conf.offsetY = -100;
//    conf.scale = 1.5;
    FaceRecognizeView *captureV = [[FaceRecognizeView alloc] initWithFrame:previewRect configuration:conf];
    captureV.delegate = self;
    [self.view addSubview:captureV];
    [captureV start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}

- (void)faceRecognizeView:(FaceRecognizeView *)faceRecognizeView didGetFaceImage:(UIImage *)image{
    
}

- (BOOL)faceRecognizeView:(FaceRecognizeView *)faceRecognizeView canGetFaceImageFromFaceDetectRect:(CGRect)faceDetectRect{
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
