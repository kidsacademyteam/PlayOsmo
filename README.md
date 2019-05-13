# Play Osmo integration example

This is a demo application which shows how to make a new game into a static library.
There is a limitation that this static library will be integrated into the Adobe AIR.
Adobe AIR uses own OpenGL ES 2 context and any integrated game should reuse it with sharegroup.

### Example structure

1. `IntegrationDemo.xcworkspace` - workspace with 2 projects
2. `OpenGLTests.xcodeproj` - project to test static library
3. `IntegrationDemo.xcodeproj` - project to test game before integration into static IS_ANE_LIBRARY


### Testing

You should test your static library by running it from the `OpenGLTests` where you should integrate it.
App will show test screen, after taping on the screen will be opened your game. You should be able to return to the previous screen by some exit button on the your UI.

App should be possible to go froward and backward many times without crashes, memory leaks and corruption of the first OpenGL ES context.

### Important blocks

#### Library

The game are implemented inside the project IntegrationDemo. It has 2 targets:
application for testing and static library.

Your code with game should be placed in this project or in a similar project.

#### Entry point

Static library will create a new ViewController inside the file `IntegrationDemo_lib.m`
in function `void StartDemo(NSString* resPath, void (^preCallback)(void), void (^postCallback)(void));`.

You could provide only compiled binary of the static library with a single export `StartDemo`.
We could use it to integrate in our application.

Also ViewController should able to call external block to notify that game will be closed.
Code inside `IntegrationDemo_lib.m` will revert previous ViewController when Game calling this block.

#### Game Resources

All resources should be placed in a single folder or bundle.
Our app will download resources from the CDN and extract them into the cache folder.
On starting process we will send path to this folder by the first parameter of the function `StartDemo`.

The static library should relay on this path to load all resources required by the game.

#### Sharing OpenGL ES 2 context

In the ViewController `DemoGameViewController.m` before creating context will be called this code to store previous context
and to create a new one with sharegroup.

```
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
```

It should be reverted on exit from the Game's ViewController:
```
-(void)onBackPressed:(id)sender{
    if (self.onBackBlock) {
        if (g_prevContext) {
            [EAGLContext setCurrentContext:g_prevContext];
            g_prevContext = nil;
        }

        self.onBackBlock();
    }
}
```


#### Distribution of the ready game

1. It should be distributed as static library file.
2. Header with function to start this game.
3. Zip archive with all required resources.
