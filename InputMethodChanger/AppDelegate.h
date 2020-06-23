//
//  AppDelegate.h
//  InputMethodChanger
//
//  Created by Futaba Apple on 16/03/16.
//  Copyright © 2019 Futaba. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusBar;
@property (strong) NSMutableDictionary *appsDict;
@property bool needToChangeLang;
@property int debugCounter;

@property (strong) NSString *langToChangeTo;
@property (strong) NSString *currentLang;

@property (strong) NSString *currentApp;

@end

