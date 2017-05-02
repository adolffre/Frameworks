//
//  VCRequestHandlerParameters.m
//  Volo
//
//  Created by Peter Mosaad on 3/21/16.
//  Copyright © 2016 Foodora. All rights reserved.
//

#import "VCRequestHandlerParameters.h"

#define kServiceEndPoint @"service-end-point"
#define kServicePath @"service-path"
#define kRequestBodyParameters @"request-body-params"
#define kreqeustSpecialHeaders @"request-special-headers"
#define kIsRequestNeedsAuthentication @"request-needs-authentication"
#define kRequestMethod @"request-method"
#define kPostBodyFormat @"post-body-format"
#define kRequestTimeOutInterval @"request-time-interval"
#define kRequestHttpHeaders @"request-http-headers"


@implementation VCRequestHandlerParameters

+ (instancetype _Nonnull)requestHandlerParametersForServiceEndPoint:(WebServiceEndPoint * _Nonnull)serviceEndPoint
                                                        servicePath:(NSString * _Nonnull)servicePath
                                                       forClassType:(Class _Nullable)classType {
    
    VCRequestHandlerParameters* requestParameters = [[VCRequestHandlerParameters alloc] init];
    requestParameters.serviceEndPoint = serviceEndPoint;
    requestParameters.servicePath = servicePath;
    requestParameters.expectedModelClass = classType;
	requestParameters.requestHttpHeaders = [NSMutableDictionary dictionaryWithDictionary:serviceEndPoint.defaultHTTPHeadaers];
    return requestParameters;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestTimeOutInterval = kDefaultTimeOutInterval;
    }
    return self;
}

+ (NSString *)encodedURLForURL:(NSString *)url {
    // Basically make sure that if some of URL parameters are encoded and others are not, make sure that all parameters are decoded and encoded back, so its sure that all URL parameters are well encoded.
    NSString *decoded = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    if ([url isEqualToString:decoded]) {// No encoded was applied already, so just encode the URL and that's it
        return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else {// So may be some parameters were encoded and others are not, so make sure it's all encoded correctly.
        // The URL was already encoded
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:url];
        NSArray *queryItems = urlComponents.queryItems;
        if (queryItems.count) {
            for (NSURLQueryItem *item in queryItems) {
                NSString *decodedValue = [item.value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSString *encodedValue = [decodedValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                url = [url stringByReplacingOccurrencesOfString:item.value withString:encodedValue];
            }
        } else {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        return url;
    }
}

- (NSString *)requestURL {
    if (self.servicePath.length) {
        BOOL shouldAddSlash = ![self.serviceEndPoint.baseServiceURL hasSuffix:@"/"] && ![self.servicePath hasPrefix:@"/"];
        BOOL bothHaveSlashes = [self.serviceEndPoint.baseServiceURL hasSuffix:@"/"] && [self.servicePath hasPrefix:@"/"];
        if (bothHaveSlashes) {
            self.servicePath = [self.servicePath substringFromIndex:1];
        }
        NSString* urlFormat = (shouldAddSlash)? @"%@/%@" : @"%@%@";
        NSString *url =  [NSString stringWithFormat:urlFormat, self.serviceEndPoint.baseServiceURL, self.servicePath];
        url = [VCRequestHandlerParameters encodedURLForURL:url];
        return url;
    } else {
        return [VCRequestHandlerParameters encodedURLForURL:self.serviceEndPoint.baseServiceURL];
    }
}

#pragma mark - NSCoder methods

- (void)encodeWithCoder:(NSCoder *)aCoder {
	
	
	 [aCoder encodeObject:self.serviceEndPoint forKey:kServiceEndPoint];
	 [aCoder encodeObject:self.servicePath forKey:kServicePath];
	 [aCoder encodeObject:self.requestBodyParameters forKey:kRequestBodyParameters];
	 [aCoder encodeBool:self.isRequestNeedsAuthentication forKey:kIsRequestNeedsAuthentication];
	 [aCoder encodeDouble:self.requestMethod forKey:kRequestMethod];
	 [aCoder encodeDouble:self.postBodyFormat forKey:kPostBodyFormat];
	 [aCoder encodeInteger:self.requestTimeOutInterval forKey:kRequestTimeOutInterval];
	 [aCoder encodeObject:self.requestHttpHeaders forKey:kRequestHttpHeaders];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super init];
	if (self) {
		
		 self.serviceEndPoint = [aDecoder decodeObjectForKey:kServiceEndPoint];
		 self.servicePath = [aDecoder decodeObjectForKey:kServicePath];
		 self.requestBodyParameters = [aDecoder decodeObjectForKey:kRequestBodyParameters];
		 self.isRequestNeedsAuthentication = [aDecoder decodeBoolForKey:kIsRequestNeedsAuthentication];
		 self.requestMethod = [aDecoder decodeDoubleForKey:kRequestMethod];
		 self.postBodyFormat = [aDecoder decodeDoubleForKey:kPostBodyFormat];
		 self.requestTimeOutInterval = [aDecoder decodeIntegerForKey:kRequestTimeOutInterval];
		 self.requestHttpHeaders = [aDecoder decodeObjectForKey:kRequestHttpHeaders];
	}
	return self;
	
}

+ (NSString *)appendLanguageAndSerializationAttributesToURL:(NSString * _Nonnull)url langID:(NSNumber * _Nonnull)langID {
    if ([url rangeOfString:@"?"].location == NSNotFound) {
        url = [url stringByAppendingString:@"?"];
    } else {
        url = [url stringByAppendingString:@"&"];
    }
    url = [url stringByAppendingString:@"serialize_null=false"];
    if (langID) {
        url = [url stringByAppendingFormat:@"&language_id=%@", langID];
    }
    return url;
}

@end
