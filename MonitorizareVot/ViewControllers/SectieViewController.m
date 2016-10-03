//
//  SectieViewController.m
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 30/09/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import "SectieViewController.h"

//Views


@interface SectieViewController () <UITextFieldDelegate>
//Outlets
@property (strong, nonatomic) IBOutlet UITextField *judetTextField;
@property (strong, nonatomic) IBOutlet UITextField *orasTextField;
@property (strong, nonatomic) IBOutlet UITextField *numarSectieTextField;
@property (strong, nonatomic) IBOutlet UITextField *oraSosireTextfield;
@property (strong, nonatomic) IBOutlet UITextField *oraPlecareTextField;
@property (strong, nonatomic) IBOutlet UITextField *zonaTextField;
@property (strong, nonatomic) IBOutlet UITextField *femeieTextField;
//Views
@property (strong, nonatomic) UIPickerView *inputPickerView;
@property (strong, nonatomic) UIDatePicker *datePickerInputView;
//Other
@property (strong, nonatomic) NSArray *datasourceArray;
@end

@implementation SectieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"SECTIE";
    [self setupTextFields];
    
    // Do any additional setup after loading the view.
}

-(void)setupTextFields {
    self.datePickerInputView = [[UIDatePicker alloc] init];
    self.inputPickerView = [[UIPickerView alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Judete" ofType:@"plist"];
    self.datasourceArray = [NSArray arrayWithContentsOfFile:path ];
    
    self.judetTextField.inputView = self.inputPickerView;
    self.numarSectieTextField.inputView = self.inputPickerView;
    self.zonaTextField.inputView = self.inputPickerView;
    self.femeieTextField.inputView = self.inputPickerView;
    self.oraPlecareTextField.inputView = self.datePickerInputView;
    self.oraSosireTextfield.inputView = self.datePickerInputView;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    
    return YES;
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
