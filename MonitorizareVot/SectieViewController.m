//
//  SectieViewController.m
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 30/09/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import "SectieViewController.h"

@interface SectieViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
//Outlets
@property (strong, nonatomic) IBOutlet UIButton *judetButton;
@property (strong, nonatomic) IBOutlet UIButton *sectieButton;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolBar;

//Views
@property (strong, nonatomic) IBOutlet UIPickerView *inputPicker;

//Other
@property (strong, nonatomic) NSMutableDictionary *judeteDictionary;
@property (strong, nonatomic) NSArray *numereSectiiArray;
@property (strong, nonatomic) NSArray *numeSectiiArray;
@property (strong, nonatomic) NSString *judetSelected;
@property (nonatomic) BOOL judetTapped;
@property (nonatomic) BOOL numarTapped;

@end

@implementation SectieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputPicker.hidden = YES;
    self.pickerToolBar.hidden = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Judete" ofType:@"plist"];
    self.judeteDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.numeSectiiArray = [self.judeteDictionary allKeys];
    self.numeSectiiArray = [[self.judeteDictionary allKeys] sortedArrayUsingSelector:
                            @selector(localizedCaseInsensitiveCompare:)];
    self.numereSectiiArray  = [self.judeteDictionary allValues];
    self.judetTapped = NO;
    self.numarTapped = NO;
    
}

#pragma mark - IBActions

- (IBAction)judetButtonTapped:(UIButton *)sender {
    [self.inputPicker reloadAllComponents];
    self.inputPicker.hidden = NO;
    self.pickerToolBar.hidden = NO;
    self.judetTapped = YES;
}
- (IBAction)sectieButtonTapped:(UIButton *)sender {
    if([self.judetButton.titleLabel.text isEqualToString:@"Alege"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Selectati judetul" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.inputPicker reloadAllComponents];
        self.inputPicker.hidden = NO;
        self.pickerToolBar.hidden = NO;
        self.numarTapped = YES;        
    }
}
- (IBAction)selecteazaButtonTapped:(UIBarButtonItem *)sender {
    self.pickerToolBar.hidden = YES;
    self.inputPicker.hidden = YES;
    if (self.judetTapped) {
        self.judetSelected = [self.numeSectiiArray objectAtIndex:[self.inputPicker selectedRowInComponent:0]];
        [self.judetButton setTitle:self.judetSelected forState:UIControlStateNormal];
        self.judetTapped = NO;
    } else if (self.numarTapped) {
        [self.sectieButton setTitle:[NSString stringWithFormat:@"%ld", [self.inputPicker selectedRowInComponent:0]] forState:UIControlStateNormal];
        self.numarTapped = NO;
    }
    
}

#pragma mark - UIPickerViewDelegate&DatasourceMethods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.judetTapped) {
        return self.judeteDictionary.count;
    } else {
        NSString *selected = [self.judeteDictionary objectForKey:self.judetSelected];
        return selected.intValue;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.judetTapped) {
        return [self.numeSectiiArray objectAtIndex:row];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)row+1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
