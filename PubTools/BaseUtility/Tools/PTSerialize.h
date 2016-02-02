//
//  PBObjectCoding.h
//  PubTools
//
//  Created by kyao on 14-4-1.
//
//

#import <Foundation/Foundation.h>

@interface PTSerialize : NSObject <NSCoding>

@end

@interface NSObject (PTSerialize)

- (void)decode:(NSCoder*)aDecoder;
- (void)encode:(NSCoder*)aEncoder;

@end
