//
//  EsteFemeieViewController.m
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 03/11/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import "EsteFemeieViewController.h"

@interface EsteFemeieViewController ()
@property (strong, nonatomic) IBOutlet UIButton *urbanButton;
@property (strong, nonatomic) IBOutlet UIButton *ruralButton;
@property (strong, nonatomic) IBOutlet UIButton *femeieButton;
@property (strong, nonatomic) IBOutlet UIButton *barbatButton;
@property (strong, nonatomic) IBOutlet UIButton *sosireButton;
@property (strong, nonatomic) IBOutlet UIButton *plecareButton;
@property (strong, nonatomic) IBOutlet UIButton *schimbaSectieButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsCollection;

@end

@implementation EsteFemeieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for(UIButton *button in self.buttonsCollection) {
        [self setupLayoutForButton:button];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupLayoutForButton:(UIButton *)button {
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithRed:172.0/255.0 green:180.0/255.0 blue:190.0/255.0 alpha:1].CGColor;
    if (button.tag > 0 && button.tag< 5) {
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowRadius = 4;
        button.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        button.layer.shadowOpacity = 0.07;
    }
}
- (IBAction)schimbaSectie:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
