//
//  IntegrationDemo_lib.h
//  IntegrationDemo_lib
//
//  Created by mac-073-71 on 5/13/19.
//  Copyright © 2019 mac-073-71. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

    void StartDemo(NSString* resPath, void (^preCallback)(void), void (^postCallback)(void));

#ifdef __cplusplus
}
#endif
