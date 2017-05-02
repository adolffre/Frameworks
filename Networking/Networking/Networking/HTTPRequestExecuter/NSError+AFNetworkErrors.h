//
//  NSError+AFNetworkErrors.h
//  Volo
//
//  Created by Peter Mosaad on 3/29/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (AFNetworkErrors)

- (NSData *_Nullable)urlFailureResponseData;

- (NSHTTPURLResponse *_Nullable)httpResponse;

@end
