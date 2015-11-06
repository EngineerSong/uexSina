//
//  EUExSina.m
//  WBPlam
//
//  Created by AppCan on 13-3-25.
//  Copyright (c) 2013年 AppCan. All rights reserved.
//

#import "EUExSina.h"
#import "EUtility.h"
#import "EUExBaseDefine.h"
#import "JSON.h"

@implementation EUExSina

-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    if (self=[super initWithBrwView:eInBrwView]) {
        isResignCallBack = NO;
    }
    return self;
}

-(void)clean{
    self.shareContent = nil;
    self.shareImgDes = nil;
    self.shareImgPath = nil;
}

-(void)dealloc{
    self.shareContent = nil;
    self.shareImgDes = nil;
    self.shareImgPath = nil;
    [super dealloc];
}

-(void)cleanUserInfo:(NSMutableArray*)inArguments
{
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    id userId = [ud objectForKey:oauth2SianUserID];
    id tokenkey = [ud objectForKey:oauth2SinaTokenKey];
    if (tokenkey)
    {
        [ud removeObjectForKey:oauth2SinaTokenKey];
    }
    if (userId)
    {
        [ud removeObjectForKey:oauth2SianUserID];
    }
}
#pragma mark
#pragma mark - 新浪微博登陆,获取access_tocken和uid
#pragma mark

-(void)login:(NSMutableArray*)inArguments{
    
    NSString *appKey = [inArguments objectAtIndex:0];
    NSString *appSecret = [inArguments objectAtIndex:1];
    NSString *registerUrl = [inArguments objectAtIndex:2];
    
    if(_ssCtrl) {
        
    }else {
        _ssCtrl =[[SinaShareController alloc] init];
    }
    _ssCtrl.loginType = @"login";
    _ssCtrl.delegate = self;
    _ssCtrl.appSecret = appSecret;
    _ssCtrl.appKey = appKey;
    _ssCtrl.registerUrl = registerUrl;
    if (_ssCtrl.appKey && _ssCtrl.appSecret && _ssCtrl.registerUrl)
    {
        [_ssCtrl logIn];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_ssCtrl];
        [EUtility brwView:meBrwView presentModalViewController:nav animated:YES];
        [nav release];
    }
}
-(void)registerApp:(NSMutableArray*)inArguments{
    isResignCallBack = YES;
    NSString *appKey = [inArguments objectAtIndex:0];
    NSString *appSecret = [inArguments objectAtIndex:1];
    NSString *registerUrl = [inArguments objectAtIndex:2];
    /*if ([EUtility appCanDev]) {
     appKey =@"3845409824";
     appSecret = @"6baa661d49374c9da3ea9cab1c406ab6";
     registerUrl = @"http://www.3g2win.com/tiaozhuan/index.html";
     }*/
    if (!_ssCtrl) {
        _ssCtrl =[[SinaShareController alloc] init];
        _ssCtrl.delegate = self;
        _ssCtrl.appSecret = appSecret;
        _ssCtrl.appKey = appKey;
        _ssCtrl.registerUrl = registerUrl;
        if (_ssCtrl.appKey && _ssCtrl.appSecret && _ssCtrl.registerUrl)
        {
            if ([SinaShareController isValid])
            {
                NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
                id userId = [ud objectForKey:oauth2SianUserID];
                id tokenkey = [ud objectForKey:oauth2SinaTokenKey];
                //回调callback
               // NSString *jsString = [NSString stringWithFormat:@"uexSina.registerCallBack('%@','%@',%d);",userId,tokenkey,UEX_CSUCCESS];
                //20140901xrg增加uexSina.cbRegister回调方法
                NSString *jsStringCB = [NSString stringWithFormat:@"uexSina.cbRegisterApp('%@','%@',%d);",userId,tokenkey,UEX_CSUCCESS];
                //[self.meBrwView stringByEvaluatingJavaScriptFromString:jsString];
                [self.meBrwView stringByEvaluatingJavaScriptFromString:jsStringCB];
            }else
            {
                [_ssCtrl logIn];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_ssCtrl];
                [EUtility brwView:meBrwView presentModalViewController:nav animated:YES];
                [nav release];
            }
        }
        else
        {
            //回调callback
            //[self jsSuccessWithName:@"uexSina.registerCallBack" opId:0 dataType:1 intData:UEX_CFALSE];
            [self jsSuccessWithName:@"uexSina.cbRegisterApp" opId:0 dataType:1 intData:UEX_CFALSE];
        }
    }else
    {
        if ([SinaShareController isValid])
        {
            NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
            id userId = [ud objectForKey:oauth2SianUserID];
            id tokenkey = [ud objectForKey:oauth2SinaTokenKey];
            //回调callback
            //NSString *jsString = [NSString stringWithFormat:@"uexSina.registerCallBack('%@','%@',%d);",userId,tokenkey,UEX_CSUCCESS];
            NSString *jsString = [NSString stringWithFormat:@"uexSina.cbRegisterApp('%@','%@',%d);",userId,tokenkey,UEX_CSUCCESS];
            [self.meBrwView stringByEvaluatingJavaScriptFromString:jsString];
        }else
        {
            [_ssCtrl logIn];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_ssCtrl];
            [EUtility brwView:meBrwView presentModalViewController:nav animated:YES];
            [nav release];
        }
    }
}
-(void)getUserInfo:(NSMutableArray*)inArguments{
    if(inArguments.count <3){
        return;
    }
    NSString *source=inArguments[0];
    NSString *access_token=inArguments[1];
    NSString *uid=inArguments[2];
    NSString *url =[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?source=%@&access_token=%@&uid=%@",source,access_token,uid];
    NSURL *zoneUrl = [NSURL URLWithString:url];
    NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSMutableDictionary *userInfoDict=[NSMutableDictionary alloc];
        userInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //NSLog(@"userInfoDict------>>>>%@",userInfoDict);
        [self cbGetUserInfo:[userInfoDict JSONFragment]];
    }
}

- (void)cbGetUserInfo:userInfo{
    [self jsSuccessWithName:@"uexSina.cbGetUserInfo"opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:userInfo];
}
-(void)sendTextContent:(NSMutableArray*)inArguments{
    currentStatus =1;
    NSString *content = [inArguments objectAtIndex:0];
    self.shareContent = content;
    
    if ([SinaShareController isValid]) {
        [_ssCtrl shareWithContent:self.shareContent];
    }else {
        if (!_ssCtrl) {
            return;
        }
        
        [_ssCtrl logIn];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_ssCtrl];
        [EUtility brwView:meBrwView presentModalViewController:nav animated:YES];
        [nav release];
    }
}

-(void)sendImageContent:(NSMutableArray*)inArguments{
    if ([inArguments isKindOfClass:[NSMutableArray class]] && [inArguments count]>0) {
        currentStatus = 2;
        NSLog(@"hui-->uexSina-->sendImageContent");
        NSString *realImgPath = [self absPath:[inArguments objectAtIndex:0]];
        NSLog(@"hui-->uexSina-->sendImageContent realImgPath is %@",realImgPath);
        self.shareImgPath = realImgPath;
        if ([inArguments count]>1) {
            self.shareImgDes = [inArguments objectAtIndex:1];
        }else{
            self.shareImgDes = @"";
        }
        if ([SinaShareController isValid]) {
            if ([self.shareImgPath hasPrefix:@"http"]) {
                [_ssCtrl shareWithImgUrl:self.shareImgPath andContent:self.shareImgDes];
            }else{
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.shareImgPath];
                if (!fileExists) {
                    [self jsSuccessWithName:@"uexSina.cbShare" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@"图片不存在"];
                    return;
                }
                [_ssCtrl shareWithImage:self.shareImgPath andContent:self.shareImgDes];
            }
        }else {
            if (!_ssCtrl) {
                return;
            }
            [_ssCtrl logIn];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_ssCtrl];
            UIViewController *vc = [EUtility brwCtrl:meBrwView];
            [vc presentModalViewController:nav animated:YES];
            //[_ssCtrl release];
            [nav release];
            //_ssCtrl = nil;
        }
    }
}

#pragma mark - private

-(void)doSendContent{
    [_ssCtrl shareWithContent:self.shareContent];
}

-(void)doSendImg{
    if ([self.shareImgPath hasPrefix:@"http"]) {
        [_ssCtrl shareWithImgUrl:self.shareImgPath andContent:self.shareImgDes];
    }else{
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.shareImgPath];
        if (!fileExists) {
            [self jsSuccessWithName:@"uexSina.cbShare" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@"图片不存在"];
            return;
        }
        [_ssCtrl shareWithImage:self.shareImgPath andContent:self.shareImgDes];
    }
}

#pragma mark for delegate
#pragma mark -
#pragma mark SinaShareDelegate

-(void)requestDidSucceedWithResult:(id)result{
    [_ssCtrl release];
    _ssCtrl = nil;
    [self jsSuccessWithName:@"uexSina.cbShare" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
}

-(void)requestDidFailedWithResult:(id)result{
    [_ssCtrl release];
    _ssCtrl = nil;
    [self jsSuccessWithName:@"uexSina.cbShare" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
}
- (void)sinaLogin {
    
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    id userId = [ud objectForKey:oauth2SianUserID];
    id tokenkey = [ud objectForKey:oauth2SinaTokenKey];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[ud objectForKey:@"expires_in"] forKey:@"expires_in"];
    [dict setObject:userId forKey:oauth2SianUserID];
    [dict setObject:tokenkey forKey:oauth2SinaTokenKey];
    
    [dict setObject:[ud objectForKey:@"remind_in"] forKey:@"remind_in"];
    NSString *jsData = [dict JSONFragment];
    //回调callback
    [self jsSuccessWithName:@"uexSina.cbLogin" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsData];
}

-(void)SinaLoginSuccess{
    //授权关注
    ///  [NSThread detachNewThreadSelector:@selector(attendAppCan) toTarget:self withObject:nil];
    if (currentStatus==1) {
        [self doSendContent];
    }else if (currentStatus==2){
        [self doSendImg];
    }
    if (isResignCallBack)
    {
        NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
        id userId = [ud objectForKey:oauth2SianUserID];
        id tokenkey = [ud objectForKey:oauth2SinaTokenKey];
        //回调callback
        //NSString *jsString = [NSString stringWithFormat:@"uexSina.registerCallBack('%@','%@',%d);",userId,tokenkey,UEX_CSUCCESS];
        NSString *jsString = [NSString stringWithFormat:@"uexSina.cbRegisterApp('%@','%@',%d);",userId,tokenkey,UEX_CSUCCESS];
        [self.meBrwView stringByEvaluatingJavaScriptFromString:jsString];
        isResignCallBack = NO;
    }
}

-(void)attendAppCan{
    @autoreleasepool {
        NSString *attendUrl = @"https://api.weibo.com/2/friendships/create.json";
        NSMutableString *paramsStr =[[[NSMutableString alloc] initWithString:@""] autorelease];
        NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
        id tokenkey = [ud objectForKey:oauth2SinaTokenKey];
        if (!tokenkey) {
            return;
        }
        [paramsStr appendFormat:@"access_token=%@",tokenkey];
        [paramsStr appendFormat:@"&uid=2549872882"];
        NSError *error;
        NSURLResponse *theResponse;
        NSMutableURLRequest *request =[[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:attendUrl]] autorelease];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramsStr dataUsingEncoding:NSUTF8StringEncoding]];
        [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [NSURLConnection sendSynchronousRequest:request returningResponse:&theResponse error:&error];
    }
}
@end