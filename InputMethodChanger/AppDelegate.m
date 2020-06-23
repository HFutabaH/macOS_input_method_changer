//
//  AppDelegate.m
//  InputMethodChanger
//
//  Created by Futaba Apple on 16/03/16.
//  Copyright © 2019 Futaba. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize statusBar = _statusBar;
@synthesize appsDict = _appsDict;
@synthesize langToChangeTo = _langToChangeTo;
@synthesize currentLang = _currentLang;
@synthesize needToChangeLang = _needToChangeLang;

@synthesize debugCounter = _debugCounter;

@synthesize currentApp = _currentApp;

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    /*
     Maybe change to real icon in future
     //self.statusBar.image =
     */
    self.statusBar.title = @"✧";
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    self.appsDict = [[NSMutableDictionary alloc] init];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(appDeactivated:) name:NSWorkspaceDidDeactivateApplicationNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(foremostAppActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];

    self.debugCounter = 0;
//    NSLog(@"%@", [AppDelegate userInputSourcePreference]);
}

+ (NSString *) userInputSourcePreference {
    TISInputSourceRef source = TISCopyCurrentKeyboardInputSource();

    NSString *inputSourceID =(__bridge NSString *)(TISGetInputSourceProperty(source, kTISPropertyInputSourceID));
    
    return inputSourceID;
}

-(void)appDeactivated:(NSNotification *)notification
{
    if(self.needToChangeLang && self.langToChangeTo != nil){
        [self ChangeInputWithString:self.langToChangeTo];
    }
    
//        NSLog(@"App deactivated %@", currentAppbundleString);
//    [self DebugDisct];
}

-(void)DebugDisct
{
    NSLog(@"=================================");
    NSLog(@"%d Debug DICT with apps, current app %@", self.debugCounter, self.currentApp);
    if(self.appsDict != nil)
    {
        for(id key in self.appsDict)
            NSLog(@"key=%@ value=%@", key, [self.appsDict objectForKey:key]);
    }
    self.debugCounter++;
    NSLog(@"=================================");
}

-(void)foremostAppActivated:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    
    NSRunningApplication *activeApp =[userInfo objectForKey:@"NSWorkspaceApplicationKey"];

    if([activeApp.bundleIdentifier isEqualToString:@"com.futaba.InputMethodChanger"])
    {
            return;
    }
    NSString *currentAppbundleString =  self.currentApp;//activeApp.bundleIdentifier;
    
    //store current app key
    if(currentAppbundleString != nil)
    {
        NSString *inputString = [AppDelegate userInputSourcePreference];
        if([self.appsDict objectForKey:currentAppbundleString] != nil){
            //has that app, update
            [self.appsDict removeObjectForKey:currentAppbundleString];
            [self.appsDict setValue:inputString forKey:currentAppbundleString];
        }else{
            //add app
            [self.appsDict setValue:inputString forKey:currentAppbundleString];
        }
    }
    //get lang for activated app
    if([self.appsDict objectForKey:activeApp.bundleIdentifier] != nil){
        NSString *inputString = [self.appsDict objectForKey:activeApp.bundleIdentifier];
        self.needToChangeLang = true;
        self.langToChangeTo = inputString;
//        NSLog(@"App %@ has lang in array with %@", currentAppbundleString, inputString);
    }else{
        self.needToChangeLang = false;
        self.langToChangeTo = nil;
    }
    
    self.currentApp = activeApp.bundleIdentifier;
    
//    NSLog(@"App activated %@", activeApp.bundleIdentifier);
    [self DebugDisct];
}

-(void)ChangeInputWithString:(NSString*) inputString
{
    if([inputString isEqualToString:self.currentLang])
    {
//        return;//i guess this is not necessary
    }
    
    self.currentLang = [[NSString alloc]initWithString:inputString];
    
    CFStringRef tID = (__bridge CFStringRef)(inputString);
    TISInputSourceRef inputSource = NULL;
    CFArrayRef allInputs = TISCreateInputSourceList(NULL, true);
    NSUInteger count = CFArrayGetCount(allInputs);
    for (int i = 0; i < count; i++) {
        inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(allInputs, i);
        if (!CFStringCompare(tID, TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID), 0)) {
            TISSelectInputSource(inputSource);
//            NSLog(@"ChangeTo %@", inputSource);
        }
    }
    CFRelease(allInputs);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
