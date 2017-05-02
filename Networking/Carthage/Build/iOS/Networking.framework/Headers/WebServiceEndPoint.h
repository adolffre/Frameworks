//
//  WebServiceEndPoint.h
//  Volo
//
//  Created by Hany Nady on 8/11/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceEndPoint : NSObject <NSCoding>

@property(nonatomic, strong) NSString * _Nonnull baseServiceURL;
@property(nonatomic, strong) NSDictionary * _Nullable defaultHTTPHeadaers;

+ (instancetype _Nonnull)serviceEndPointForURL:(NSString * _Nonnull)url defaultHttpHeaders:(NSDictionary * _Nullable)headers;

@end
