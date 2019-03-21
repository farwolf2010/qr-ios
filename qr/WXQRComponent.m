//
//  WXQRComponent.m
//  AFNetworking
//
//  Created by 郑江荣 on 2019/3/2.
//

#import "WXQRComponent.h"
#import "CCQrCode.h"

#import <WeexPluginLoader/WeexPluginLoader.h>
WX_PlUGIN_EXPORT_COMPONENT(qr, WXQRComponent)

@implementation WXQRComponent
WX_EXPORT_METHOD(@selector(scan:))
WX_EXPORT_METHOD(@selector(stop))
-(CCQrCode*)loadView{
    CCQrCode *code = [CCQrCode new];
    code.empty=true;
    return code;
    
}


-(void)scan:(WXModuleKeepAliveCallback)callback
{
    CCQrCode *code=(CCQrCode*)self.view;
    __weak typeof (self) weakself=self;
    [code startReading:^(AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection, AVMetadataMachineReadableCodeObject *metadataObj, NSString *stringValue) {
        
        callback(@{@"res":stringValue},true);
        NSLog(@"%@",stringValue);
//        [code stopReading];
    }];
}


-(void)stop{
     CCQrCode *code=(CCQrCode*)self.view;
      [code stopReading];
}

@end
