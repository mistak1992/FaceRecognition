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
    conf.scaleType = FaceRecognizeViewScaleTypePreviewWidth;
    conf.scale = 1.5;
    FaceRecognizeView *captureV = [[FaceRecognizeView alloc] initWithFrame:previewRect configuration:conf];
    captureV.layer.cornerRadius = 100;
    captureV.delegate = self;
    [self.view addSubview:captureV];
    [captureV start];
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
