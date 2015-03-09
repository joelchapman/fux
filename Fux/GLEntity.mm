//
//  GLEntity.mm
//  Fux
//
//  Created by Joel Chapman on 3/4/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#include "GLEntity.h"
#import "mo-fun.h"
#import "mo-gfx.h"

#define ALL 1
#define NOTHING 0

#define PROG_LOCX 0
#define PROG_LOCY 0.2
#define PROG_LOCZ 4
#define PROG_SCA 1.2

#define BUTT_LOCX 0
#define BUTT_LOCY -0.3
#define BUTT_LOCZ 4
#define BUTT_SCA 0.75

#define RAND_LOCX_LOW -1
#define RAND_LOCX_HIGH 1
#define RAND_LOCY_LOW -2.5
#define RAND_LOCY_HIGH 2.5
#define RAND_LOCZ_LOW -4
#define RAND_LOCZ_HIGH 1
#define ORI 0
#define RAND_SCALE_LOW 0.5
#define RAND_SCALE_HIGH 1
#define VEL 0
#define RAND_COL_LOW 0
#define RAND_COL_HIGH 1
#define BOUNCE 0
#define BOUNCE_RATE 0


void GLEntity::setProgressCoords()
{
    loc = Vector3D(PROG_LOCX, PROG_LOCY, PROG_LOCZ);
    ori = Vector3D(ORI, ORI, ORI);
    sca = Vector3D(PROG_SCA, PROG_SCA, PROG_SCA);
    vel = Vector3D(VEL, VEL, VEL);
    col = Vector3D(ALL, ALL, ALL);
    bounce = BOUNCE;
    bounce_rate = BOUNCE_RATE;
}


void GLEntity::setButtonCoords()
{
    loc = Vector3D(BUTT_LOCX, BUTT_LOCY, BUTT_LOCZ);
    ori = Vector3D(ORI, ORI, ORI);
    sca = Vector3D(BUTT_SCA, BUTT_SCA, BUTT_SCA);
    vel = Vector3D(VEL, VEL, VEL);
    col = Vector3D(ALL, NOTHING, NOTHING);
    bounce = BOUNCE;
    bounce_rate = BOUNCE_RATE;
    
}

void GLEntity::setRandomCoords()
{
    loc = Vector3D(MoFun::rand2f(RAND_LOCX_LOW, RAND_LOCX_HIGH), MoFun::rand2f(RAND_LOCY_LOW, RAND_LOCY_HIGH), MoFun::rand2f(RAND_LOCZ_LOW, RAND_LOCZ_HIGH));
    ori = Vector3D(ORI, ORI, ORI);
    sca = Vector3D(MoFun::rand2f(RAND_SCALE_LOW, RAND_SCALE_HIGH), MoFun::rand2f(RAND_SCALE_LOW, RAND_SCALE_HIGH), MoFun::rand2f(RAND_SCALE_LOW, RAND_SCALE_HIGH));
    vel = Vector3D(VEL, VEL, VEL);
    col = Vector3D(MoFun::rand2f(NOTHING, ALL), MoFun::rand2f(NOTHING, ALL), MoFun::rand2f(NOTHING, ALL));
    bounce = BOUNCE;
    bounce_rate = BOUNCE_RATE;
}