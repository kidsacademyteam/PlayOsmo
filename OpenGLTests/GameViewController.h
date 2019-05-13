//
//  GameViewController.h
//  OpenGLTests
//
//  Created by vm-macos on 4/19/16.
//  Copyright © 2016 vm-macos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface GameViewController : GLKViewController
{
    bool m_shouldAutoClose;
}

+ (void)show:(void (^)(void))onTapBlock;
+ (GameViewController *)makeVC:(void (^)(void))onTapBlock;
- (IBAction)onClick:(id)sender;

@end
