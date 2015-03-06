//
//  JCCoordinates.h
//  Fux
//
//  Created by Joel Chapman on 3/4/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#ifndef __Fux__JCCoordinates__
#define __Fux__JCCoordinates__

#import <stdio.h>
#import "mo-gfx.h"

#define NUM_VERTICES 8
#define NUM_NORMALS 12
#define NUM_TEXCOORDS 8

class JCCoordinates
{
public:
    JCCoordinates();

    GLfloat * squareVertices;
    GLfloat * normals;
    GLfloat * texCoords;
};

#endif /* defined(__Fux__JCCoordinates__) */
