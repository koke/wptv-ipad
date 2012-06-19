//
//  AFWordpressComClient.h
//  wptv
//
//  Created by Jorge Bernal on 6/19/12.
//  Copyright (c) 2012 Automattic. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFWordpressComClient : AFHTTPClient

+ (AFWordpressComClient *)sharedClient;

@end
