//
//  JCCoordinates.mm
//  Fux
//
//  Created by Joel Chapman on 3/4/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#include "JCCoordinates.h"
#import "mo-fun.h"

static const GLfloat tempSquare[] = {
    -0.5f,  -0.5f,
    0.5f,  -0.5f,
    -0.5f,   0.5f,
    0.5f,   0.5f,
};

static const GLfloat tempNormals[] = {
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,
    0, 0, 1
};

static const GLfloat tempTexCoords[] = {
    0, 1,
    1, 1,
    0, 0,
    1, 0
};

JCCoordinates::JCCoordinates()
{
    
    squareVertices = (GLfloat*)malloc(8*sizeof(float));
    memcpy(squareVertices, &tempSquare, 8*sizeof(float));
    
    normals = (GLfloat*)malloc(12*sizeof(float));
    memcpy(normals, &tempNormals, 8*sizeof(float));
    
    texCoords = (GLfloat*)malloc(8*sizeof(float));
    memcpy(texCoords, &tempTexCoords, 8*sizeof(float));
    

};

