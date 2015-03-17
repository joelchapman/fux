//
//  JCAudioCallback.h
//  Fux
//
//  Created by Joel Chapman on 3/16/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#ifndef __Fux__JCAudioCallback__
#define __Fux__JCAudioCallback__

#include <stdio.h>
#import "mo-audio.h"

class JCAudioCallback
{
public:
    JCAudioCallback();
    static void audioCallback( Float32 * buffer, UInt32 numFrames, void * userData );
    int getJ();
    int getK();
    
private:
    static int j;
    static int k;
};

#endif /* defined(__Fux__JCAudioCallback__) */
