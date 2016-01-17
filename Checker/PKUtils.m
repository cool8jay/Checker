//
//  PKUtils.m
//
//  Created by poukoute on 1/5/16.
//  Copyright © 2016 poukoute. All rights reserved.
//

#import "PKUtils.h"

@implementation PKUtils

+ (NSMutableArray*)getWhitelist{
    NSMutableArray *_wordArray;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *savedData = [defaults objectForKey:K_USER_DEFAULTS_KEY_WHITELIST];
    
    if (nil == savedData) {
        _wordArray = [NSMutableArray arrayWithArray:@[@" I",
                                                      @" II",
                                                      @" III",
                                                      @" IV",
                                                      @" V",
                                                      @"- I",
                                                      @"- II",
                                                      @"- III",
                                                      @"- IV",
                                                      @"- V",
                                                      @"- VI",
                                                      @"- VII",
                                                      @"- VIII",
                                                      @"android",
                                                      @"App Store",
                                                      @"BH-0872",
                                                      @"bug",
                                                      @"emoji",
                                                      @"facebook",
                                                      @"faq",
                                                      @"full",
                                                      @"Google Play",
                                                      @"HK-71",
                                                      @"hp",
                                                      @"I-V",
                                                      @"III레벨",
                                                      @"III型",
                                                      @"III級",
                                                      @"III级",
                                                      @"II레벨",
                                                      @"II型",
                                                      @"II級",
                                                      @"II级",
                                                      @"ios",
                                                      @"IV레벨",
                                                      @"IV型",
                                                      @"IV級",
                                                      @"IV级",
                                                      @"I레벨",
                                                      @"I型",
                                                      @"I級",
                                                      @"I级",
                                                      @"K조직",
                                                      @"K組織",
                                                      @"K组织",
                                                      @"lv.",
                                                      @"mod",
                                                      @"new",
                                                      @"OR-34Z",
                                                      @"PKT-118",
                                                      @"pt",
                                                      @"pve",
                                                      @"pvp",
                                                      @"Q&A",
                                                      @"R-318",
                                                      @"SNS",
                                                      @"SY983",
                                                      @"twitter",
                                                      @"UX395",
                                                      @"vip",
                                                      @"V레벨",
                                                      @"V型",
                                                      @"V級",
                                                      @"X98-U",
                                                      @"№",
                                                      @"K組"
                                                      ]];
    }else{
        _wordArray = (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:savedData];
    }
    
    return _wordArray;
}

+ (void)addWord:(NSString*)word{
    NSMutableArray *_wordArray = [PKUtils getWhitelist];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (NSNotFound==[_wordArray indexOfObject:word]){
        [_wordArray addObject:word];
        
        NSArray* newArray = [NSMutableArray arrayWithArray:[_wordArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
        
        NSData *encodeData = [NSKeyedArchiver archivedDataWithRootObject:newArray];
        
        [defaults setObject:encodeData forKey:K_USER_DEFAULTS_KEY_WHITELIST];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATION_CONFIG_WHITELIST_UPDATE object:nil userInfo:nil];
    }
}

@end
