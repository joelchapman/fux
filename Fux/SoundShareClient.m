//
//  SoundShareClient.m
//  SoundShare
//
//  Created by Michael Rotondo on 2/21/12.
//  Copyright (c) 2012 Rototyping. All rights reserved.
//

#import "SoundShareClient.h"
//#import "AFJSONRequestOperation.h"

NSString * const kSoundShareBaseURLString = @"http://127.0.0.1:8080/";

@implementation SoundShareClient

+ (SoundShareClient *)sharedClient
{
    static SoundShareClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kSoundShareBaseURLString]];
        _sharedClient.securityPolicy.allowInvalidCertificates = YES;
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
//    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    self.requestSerializer = [AFJSONRequestSerializer new];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
//	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self.requestSerializer setValue:@"Accept" forHTTPHeaderField:@"application/json"];
    
	// X-UDID HTTP Header
//	[self setDefaultHeader:@"X-UDID" value:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    [self.requestSerializer setValue:@"X-UDID" forHTTPHeaderField:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    
    return self;
}

@end
