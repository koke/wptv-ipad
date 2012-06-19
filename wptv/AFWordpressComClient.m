//
//  AFWordpressComClient.m
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "AFWordpressComClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFWordpressComBaseURLString = @"https://public-api.wordpress.com/rest/v1/";

@implementation AFWordpressComClient

+ (AFWordpressComClient *)sharedClient {
    static AFWordpressComClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFWordpressComClient alloc] initWithBaseURL:[NSURL URLWithString:kAFWordpressComBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

@end
