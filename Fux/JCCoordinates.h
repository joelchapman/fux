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

//class JCName
//{
//public:
//    JCName();
//    
//    static void setFirstName(NSString * first);
//    static void setLastName(NSString * first);
//    static NSString * getFirstName();
//    static NSString * getLastName();
//    
//private:
//    static NSString * first_name;
//    static NSString * last_name;
//};

#endif /* defined(__Fux__JCCoordinates__) */
