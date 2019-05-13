//
//  GameViewController.h
//  IntegrationDemoLib
//
//  Created by mac-073-71 on 5/13/19.
//  Copyright © 2019 mac-073-71. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

@interface DemoGameViewController : UIViewController

+(void)setupRecourcesFolder:(NSString *)resourcesFolder;

@property (nonatomic, copy) void (^onBackBlock)(void);

-(void)onBackPressed:(id)sender;

@end
