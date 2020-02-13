//
//  BuyBitcoinViewController.h
//  Blockchain
//
//  Created by kevinwu on 1/27/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Wallet.h"

@interface BuyBitcoinViewController : UIViewController
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, weak) id<ExchangeAccountDelegate>delegate;
- (instancetype)initWithRootURL:(NSString *_Nullable)rootURL;
- (void)loginWithGuid:(NSString *)guid sharedKey:(NSString *)sharedKey password:(NSString *)password;
- (void)loginWithJson:(NSString *)guid externalJson:(NSString *)externalJson magicHash:(NSString *)magicHash password:(NSString *)password;
- (void)runScript:(NSString *)script;
- (void)runScriptWhenReady:(NSString *)script;
@end
