//
//  GZGDCThreadManager.h
//  test-mutilThread
//
//  Created by 高召葛 on 2019/5/15.
//  Copyright © 2019 高召葛. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GZGDCThreadManager : NSObject
+ (instancetype) shareInstence;
- (void) execute;
@end

NS_ASSUME_NONNULL_END
