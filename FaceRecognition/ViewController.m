#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人脸检测";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"人脸检测" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(click1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
}

// 人脸检测
- (void)click1
{
    DemoViewController *VC = [[DemoViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
