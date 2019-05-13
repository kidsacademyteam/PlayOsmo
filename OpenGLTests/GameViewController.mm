//
//  GameViewController.m
//  OpenGLTests
//
//  Created by vm-macos on 4/19/16.
//  Copyright © 2016 vm-macos. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

static GameViewController *g_GameViewController = nil;
static void (^g_onTapBlock)(void) = nil;
static EAGLContext *g_prevContext = nil;

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_COLOR_VECTOR3,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    ATTRIB_TEXTURE,
    NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[288] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,      texX, texY
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,        0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,        1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.0f, 1.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,        1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,        1.0f, 1.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,        1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,        0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,        1.0f, 1.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,        1.0f, 1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,        0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,        0.0f, 1.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,       1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,       1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,       0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,       0.0f, 1.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,       0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,       1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,       0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,       0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,       1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,       1.0f, 1.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,        1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,        0.0f, 0.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,       1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,       0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,       1.0f, 1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,       1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,       0.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f,       0.0f, 1.0f,
};

@interface GameViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix[3];
    GLKMatrix3 _normalMatrix[3];
    GLuint _textures[3];
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

- (void)setupGL;
- (void)tearDownGL;

- (NSBundle *)resBundle;
- (BOOL)loadShaders;
- (BOOL)loadTextures;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(NSString *)source;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.contentScaleFactor = [[UIScreen mainScreen] scale];
    
    [self setupGL];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClick:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 200)] autorelease];
    label.textColor = [UIColor redColor];
    label.text = @"Tap the screen";
    [self.view addSubview:label];
}

- (void)dealloc
{
    [self tearDownGL];
    g_GameViewController = nil;
    [super dealloc];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

+ (GameViewController *)makeVC:(void (^)(void))onTapBlock
{
    if (g_onTapBlock) {
        [g_GameViewController release];
    }
    g_onTapBlock = [onTapBlock copy];
    GameViewController *vc = [[GameViewController alloc] init];
    
    vc->m_shouldAutoClose = false;
    
    return [vc autorelease];
}

+ (void)show:(void (^)(void))onTapBlock {
    g_onTapBlock = onTapBlock;
    g_GameViewController = [[GameViewController alloc] init];
    
    id delegate = [[UIApplication sharedApplication] delegate];
    // CGRect rect = CGRectMake(x,y,w,h);
    // init the view position some how  myViewController.viewFrame = rect;
    UIWindow * win = [delegate window];
    [win addSubview:g_GameViewController.view];
    
    g_GameViewController->m_shouldAutoClose = true;
}

- (IBAction)onClick:(id)sender {
    NSLog(@"CLick");
    if (m_shouldAutoClose) {
        [self.view removeFromSuperview];
        [g_GameViewController release];
        g_GameViewController = nil;
    }
    
    if (g_onTapBlock) {
        g_onTapBlock();
    }
    if (m_shouldAutoClose) {
        [g_onTapBlock release];
        g_onTapBlock = nil;
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)setupGL
{
    [self loadShaders];
    [self loadTextures];
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    glDeleteTextures(3, _textures);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }

    if (g_prevContext) {
        [EAGLContext setCurrentContext:g_prevContext];
        g_prevContext = nil;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Cube 1
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    _normalMatrix[0] = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix[0] = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    // Cube 2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 1.5f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    _normalMatrix[1] = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix[1] = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    // Cube 3
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, -1.5f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);

    _normalMatrix[2] = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _modelViewProjectionMatrix[2] = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    glUseProgram(_program);

    // Render cube 1
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix[0].m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix[0].m);
    glUniform3f(uniforms[UNIFORM_COLOR_VECTOR3], 1, 0, 0);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textures[0]);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render cube 2
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix[1].m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix[1].m);
    glUniform3f(uniforms[UNIFORM_COLOR_VECTOR3], 0, 1, 0);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textures[1]);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // Render cube 3
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix[2].m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix[2].m);
    glUniform3f(uniforms[UNIFORM_COLOR_VECTOR3], 0, 0, 1);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textures[2]);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);

}

#pragma mark -  OpenGL ES 2 shader compilation

- (NSBundle *)resBundle
{
    NSBundle *bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"opengl_tests.bundle"]];
    return bundle;
}

- (GLuint)setupTexture:(NSString *)filePath {
    CGImageRef spriteImage = [UIImage imageWithContentsOfFile:filePath].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", filePath);
        exit(1);
    }
    
    GLsizei width = (GLsizei)CGImageGetWidth(spriteImage);
    GLsizei height = (GLsizei)CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;    
}

- (BOOL)loadTextures
{
    _textures[0] = [self setupTexture:[[self resBundle] pathForResource:@"atlas_1" ofType:@"png"]];
    _textures[1] = [self setupTexture:[[self resBundle] pathForResource:@"atlas_2" ofType:@"png"]];
    _textures[2] = [self setupTexture:[[self resBundle] pathForResource:@"atlas_3" ofType:@"png"]];
    
    return YES;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    NSString *vertShaderPathname = [[self resBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    NSString *fragShaderPathname = [[self resBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "tex");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_COLOR_VECTOR3] = glGetUniformLocation(_program, "colorVect");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "textureSampler");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    return [self compileShader:shader type:type source:[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil]];
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(NSString *)source
{
    GLint status;
    const GLchar *glSource = NULL;
    
    glSource = (GLchar *)[source UTF8String];
    if (!glSource) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &glSource, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
