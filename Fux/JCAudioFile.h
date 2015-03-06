//
//  JCAudioFile.h
//  Fux
//
//  Created by Joel Chapman on 3/2/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#ifndef __JCAudioFile__h
#define __JCAudioFile__h

#import <stdio.h>
#import <stdlib.h>
#import <MacTypes.h>

class JCAudioFile
{
public:
    JCAudioFile();

    void setRecording ( float tempBuffer[], int TRACKS );
    static int bufferSize();
    
private:
    float * recording;
};

#endif
