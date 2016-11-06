//
//  QuestionCollectionViewCell.m
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 02/10/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import "QuestionCollectionViewCell.h"

@implementation QuestionCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.cornerRadius = 4;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:172.0/255.0 green:180.0/255.0 blue:190.0/255.0 alpha:1].CGColor;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 4;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.layer.shadowOpacity = 0.07;
    
}

@end
