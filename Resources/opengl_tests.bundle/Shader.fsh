//
//  Shader.fsh
//  OpenGLTests
//
//  Created by macos on 4/19/16.
//  Copyright © 2016 vm-macos. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 texVarying;
varying lowp float light;

uniform sampler2D textureSampler;

void main()
{
    lowp vec4 color = texture2D(textureSampler, texVarying);
    gl_FragColor = light * (colorVarying * (1.0 - color.a) + color);
}
