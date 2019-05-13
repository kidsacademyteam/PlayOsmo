//
//  GameViewController.m
//  IntegrationDemoLib
//
//  Created by mac-073-71 on 5/13/19.
//  Copyright © 2019 mac-073-71. All rights reserved.
//

#import "DemoGameViewController.h"

#include "IntegrationDemo_lib.h"

static NSString *g_resourcesFolder = nil;
static EAGLContext *g_prevContext = nil;


@implementation DemoGameViewController

+ (void)setupRecourcesFolder:(NSString *)resourcesFolder {
    g_resourcesFolder = resourcesFolder;
}

-(void)onBackPressed:(id)sender{
    if (self.onBackBlock) {
        if (g_prevContext) {
            [EAGLContext setCurrentContext:g_prevContext];
            g_prevContext = nil;
        }
        
        self.onBackBlock();
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Every new instance of the EAGLContext should be created with sharegroup of previous context. It will avoid destruction of the previous context.
    EAGLContext *context;
    if (!g_prevContext) {
        g_prevContext = [EAGLContext currentContext];
        context = [[EAGLContext alloc] initWithAPI:g_prevContext.API sharegroup:g_prevContext.sharegroup];
        [EAGLContext setCurrentContext:context];
    } else {
        context = g_prevContext;
    }
    
    if (!context) {
        NSLog(@"Failed to create ES context");
    }
    
    // create a new scene
    NSURL *url = [NSURL fileURLWithPath:[g_resourcesFolder stringByAppendingPathComponent:@"ship.scn"]];
    SCNScene *scene = [SCNScene sceneWithURL:url options:nil error:nil];

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    SCNNode *ship = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    
    // animate the 3d object
    [ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    // retrieve the SCNView
    self.view = [[SCNView alloc] initWithFrame:self.view.frame options:@{SCNPreferredRenderingAPIKey: @(SCNRenderingAPIOpenGLES2)}];
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 200, 80)];
    backButton.backgroundColor = [UIColor redColor];
    [backButton setTitle:@"Tap to Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
