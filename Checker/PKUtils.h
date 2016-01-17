//
//  PKUtils.h
//
//  Created by poukoute on 1/5/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKUtils : NSObject

+ (NSMutableArray*)getWhitelist;

+ (void)addWord:(NSString*)word;

@end
