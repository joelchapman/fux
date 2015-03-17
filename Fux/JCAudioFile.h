//
//  JCAudioFile.h
//  Fux
//
//  Created by Joel Chapman on 3/2/15.
//  Copyright (c) 2015 Joel Chapman. All rights reserved.
//

#ifndef __Fux__JCAudioFile__h
#define __Fux__JCAudioFile__h

#import <stdio.h>
#import <stdlib.h>
#import <MacTypes.h>

class JCAudioFile
{
public:
    JCAudioFile();

    void setRecording ( Float32 tempBuffer[], int TRACKS );
    float * getRecording( Float32 tempBuffer[], int TRACKS );
    static int bufferSize();
    void writeBufferToAudioFile(Float32 buffer[], const char * fName, int mChannels, bool compress_with_m4a);
    
private:
    float * recording;
};

#endif
