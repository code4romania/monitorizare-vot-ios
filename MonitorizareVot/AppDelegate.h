//
//  AppDelegate.h
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 29/09/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

