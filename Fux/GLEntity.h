//
//  GLEntity.h
//  Fux
//
//  Created by Joel Chapman on 3/4/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#ifndef __Fux__GLEntity__
#define __Fux__GLEntity__

#include <stdio.h>
#import "mo-gfx.h"

//-----------------------------------------------------------------------------
// class: Entity
// desc: stores information for entities drawn to screen
//-----------------------------------------------------------------------------
class GLEntity
{
public:
    GLEntity() { bounce = 0.0f; }
    
    Vector3D loc;
    Vector3D ori;
    Vector3D sca;
    Vector3D vel;
    Vector3D col;
    
    GLfloat bounce;
    GLfloat bounce_rate;
    
    
    void setProgressCoords();
    void setButtonCoords();
    void setRandomCoords();
    
};

#endif /* defined(__Fux__GLEntity__) */
