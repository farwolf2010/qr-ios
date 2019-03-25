//
//  WXQRComponent.h
//  AFNetworking
//
//  Created by 郑江荣 on 2019/3/2.
//

#import <Foundation/Foundation.h>
#import <WeexSDK/WeexSDK.h>
#import "WQCodeScanner.h"

@interface WXQRComponent : WXComponent
@property(nonatomic,strong)WQCodeScanner *scanner;
@end


