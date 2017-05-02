//
//  AbstractModel.m
//  FoodPanda
//
//  Created by Lukasz Lenkiewicz on 3/26/14.
//  Copyright (c) 2014 foodpanda. All rights reserved.
//

#import "AbstractModel.h"

@implementation AbstractModel

- (NSString *)description {
    //NSDictionary *permanentProperties = [self dictionaryWithValuesForKeys:self.class.permanentPropertyKeys.allObjects];
    
    return [NSString stringWithFormat:@"<%@: %p> ", self.class, self];
}
@end
