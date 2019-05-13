//
//  Shader.vsh
//  OpenGLTests
//
//  Created by macos on 4/19/16.
//  Copyright © 2016 vm-macos. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec2 tex;

varying lowp vec4 colorVarying;
varying lowp vec2 texVarying;
varying lowp float light;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 colorVect;


void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(colorVect, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    light = nDotVP;
    colorVarying = diffuseColor;
    texVarying = tex;
    
    gl_Position = modelViewProjectionMatrix * position;
}
