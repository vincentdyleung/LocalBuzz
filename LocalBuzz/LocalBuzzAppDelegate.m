//
//  LocalBuzzAppDelegate.m
//  LocalBuzz
//
//  Created by Vincent Leung on 10/1/12.
//  Copyright (c) 2012 Vincent Leung. All rights reserved.
//

#import "LocalBuzzAppDelegate.h"
#import "CurrentEventViewController.h"

@interface LocalBuzzAppDelegate ()

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic)  UITabBarController *mainViewController;
@property (strong, nonatomic) LoginViewController* loginViewController;
-(void)showLoginView;

@end

@implementation LocalBuzzAppDelegate
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;
@synthesize loginViewController = _loginViewController;
NSString *const FBSessionStateChangedNotification =
@"eecs441.info.vforvincent.Login:FBSessionStateChangedNotification";
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                  bundle:nil];
    self.mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    self.window.rootViewController = self.mainViewController;
    [self.window makeKeyAndVisible];
    //NSLog(@"didFinishWith#3");
    //if (![self openSessionWithAllowLoginUI:NO]) {
    if(![self.session isOpen]){
        // No? Display the login page.
        [self showLoginView];
    }
    [FBProfilePictureView class];
    return YES;
}

- (void)showLoginView
{
    UIStoryboard*  storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                          bundle:nil];
    LoginViewController* loginViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    self.window.rootViewController = (UIViewController*)loginViewController;
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:{
            NSLog(@"trace");
            //if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
               // NSLog(@"seesion loaded!");
            self.window.rootViewController = self.mainViewController;
                self.loginViewController = nil;//}else{
                    //NSLog(@"%d",FBSession.activeSession.state);
                //}
        }
            break;
        case FBSessionStateClosed:
            NSLog(@"close not failed");
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            if(error){
               [self openSessionWithAllowLoginUI:YES];
            }
            break;
        case FBSessionStateClosedLoginFailed:{
            NSLog(@" login failed");
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        }
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {

        NSLog(@"error reauthu#4");
        if( [session isOpen]){
            NSLog(@"is open");
        }else{
            NSLog(@"not open");
        }
      //  [self openSessionWithAllowLoginUI:YES];
        
        
        
        /*UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Login Failed"
                                  message:@"Please grant the app the required permission and retry"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        self.session = nil;
        [alertView show];*/
      //  [self.navController popToRootViewControllerAnimated:NO];
        
       // [FBSession.activeSession closeAndClearTokenInformation];
      ////
       // [self showLoginView];
    }
}


/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSLog(@"hjehehehehehehhe");
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"user_location",
                            @"user_birthday",
                            @"read_friendlists",
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             if (state == FBSessionStateClosedLoginFailed || state == FBSessionStateCreatedOpening) {
                                                 
                                                 // If so, just send them round the loop again
                                                 [[FBSession activeSession] closeAndClearTokenInformation];
                                                 [FBSession setActiveSession:nil];
                                                 //FB_CreateNewSession();
                                             }
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}
/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

-(void)applicationWillTerminate:(UIApplication *)application {
    // FBSample logic
    // if the app is going away, we close the session if it is open
    // this is a good idea because things may be hanging off the session, that need
    // releasing (completion block, etc.) and other components in the app may be awaiting
    // close notification in order to do cleanup
    [[NSUserDefaults standardUserDefaults] synchronize];
    [FBSession.activeSession close];
}

@end
