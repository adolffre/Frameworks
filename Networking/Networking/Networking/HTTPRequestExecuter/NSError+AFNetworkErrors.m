//
//  NSError+AFNetworkErrors.m
//  Volo
//
//  Created by Peter Mosaad on 3/29/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "NSError+AFNetworkErrors.h"
#import <AFNetworking/AFNetworking.h>

@implementation NSError (AFNetworkErrors)

- (NSData *_Nullable)urlFailureResponseData {
    return self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
}

- (NSHTTPURLResponse *_Nullable)httpResponse {
    return self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
}


@end
