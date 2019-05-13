//
//  IntegrationDemo_lib.m
//  IntegrationDemo_lib
//
//  Created by mac-073-71 on 5/13/19.
//  Copyright © 2019 mac-073-71. All rights reserved.
//

#import "IntegrationDemo_lib.h"

#import <UIKit/UIKit.h>

#import "DemoGameViewController.h"

static DemoGameViewController *g_demo_game = nil;
static UIViewController *g_rootvc = nil;
static EAGLContext *g_context = nil;

void StartDemo(NSString* resPath, void (^preCallback)(void), void (^postCallback)(void)) {
    if (!g_context) {
        g_context = [EAGLContext currentContext];
    }
    
    id delegate = [[UIApplication sharedApplication] delegate];
    UIWindow * win = [delegate window];
    
    [DemoGameViewController setupRecourcesFolder:resPath];
    
    g_demo_game = [[DemoGameViewController alloc]initWithNibName:nil bundle:nil];
    g_demo_game.onBackBlock = ^{
        win.rootViewController = g_rootvc;
        g_rootvc = nil;
        
        if (preCallback) preCallback();
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            g_demo_game = nil;
            
            if (g_context) {
                [EAGLContext setCurrentContext:g_context];
            }
            g_context = nil;
            
            if (postCallback) postCallback();            
        });
        
    };
    
    g_rootvc = win.rootViewController;
    win.rootViewController = g_demo_game;
}
