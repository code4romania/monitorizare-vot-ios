//
//  AlegeFormularViewController.m
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 30/09/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import "AlegeFormularViewController.h"

@interface AlegeFormularViewController ()

@property (strong, nonatomic) IBOutlet UIView *fDeschidereView;
@property (strong, nonatomic) IBOutlet UIView *fVotareView;
@property (strong, nonatomic) IBOutlet UIView *fInchidereView;
@property (strong, nonatomic) IBOutlet UIView *fNotaView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *formulareViewsArray;

@end

@implementation AlegeFormularViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFormulareViews];
    
    // Do any additional setup after loading the view.
}

-(void)setupFormulareViews {
    for(UIView *aView in self.formulareViewsArray) {
        aView.layer.cornerRadius = 4;
        aView.layer.borderWidth = 1;
        aView.layer.borderColor = [UIColor colorWithRed:172.0/255.0 green:180.0/255.0 blue:190.0/255.0 alpha:1].CGColor;
        aView.layer.shadowColor = [UIColor blackColor].CGColor;
        aView.layer.shadowRadius = 4;
        aView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        aView.layer.shadowOpacity = 0.07;
    }
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
