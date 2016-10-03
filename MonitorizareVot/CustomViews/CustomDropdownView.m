//
//  CustomDropdownView.m
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 30/09/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import "CustomDropdownView.h"

@interface CustomDropdownView() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;

@end

@implementation CustomDropdownView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
//        self.datasourceArray = [NSArray array];
    }
    return self;
}

#pragma mark - PublicMethods

-(void)hideDropdown {
    [self removeFromSuperview];
}
-(void)reloadData {
    [self.pickerView reloadAllComponents];
}

#pragma mark - PickerViewDelegate&Datasource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.datasourceArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.datasourceArray objectAtIndex:row];
}

@end
