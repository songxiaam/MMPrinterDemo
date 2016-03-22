//
//  ModifyViewController.m
//  MMPrinterDemo
//
//  Created by Mike on 16/3/20.
//  Copyright © 2016年 mikezhao. All rights reserved.
//

#import "ModifyViewController.h"

@interface ModifyViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ipAddrTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;

@end

@implementation ModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSFontAttributeName
}
- (IBAction)printTestContent:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
