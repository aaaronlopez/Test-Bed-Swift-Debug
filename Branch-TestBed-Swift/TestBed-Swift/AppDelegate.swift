//
//  AppDelegate.swift
//  TestBed-Swift
//
//  Created by David Westgate on 8/29/16.
//  Copyright © 2016 Branch Metrics. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var waitingForBranch = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        initBranch(launchOptions)
        return true
    }
    
    // Respond to URL scheme links
    func application(_ application: UIApplication,
                          open url: URL,
                 sourceApplication: String?,
                        annotation: Any) -> Bool {

        let branchHandled = Branch.getInstance().application(application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        return Branch.getInstance().continue(userActivity);
        //return true
    }
    
    var branchInitialized = false
    var openingFromBranchLink = false
    func consumeDeepLink(_ params: [AnyHashable: Any]) {
        guard !self.branchInitialized else {
            return
        }
        self.branchInitialized = true
        
        var feature:String?
        
        
        if let channel = params["~channel"] as? String {
            var sharingIncident = false
            if let intent = params["intent"] as? String, intent == "incident-share" {
                sharingIncident = true
            }
            
            let shouldProcessLink = channel == "spotlight" || sharingIncident
            
            if shouldProcessLink {
                if let incidentId = params["incidentId"] as? String, let username = params["username"] as? String, let uid = params["uid"] as? String  {
                    self.openingFromBranchLink = true
//                    let sud = UserDefaults.standard
//                    if sud.object(forKey: Constants.UserInfoKeys.InviterUserName) == nil {
//                        sud.set(username, forKey: Constants.UserInfoKeys.InviterUserName)
//                        sud.set(uid, forKey: Constants.UserInfoKeys.InviterUserId)
//                    }
                    
                    feature = params["~feature"] == nil ? "spotlight" : params["~feature"] as! String
                    
//                    sud.set(feature, forKey: Constants.UserInfoKeys.BranchFeature)
//                    sud.synchronize()
                    
//                    if SessionUser.instance.isAuthenticated() {
//                        let userInfo:[AnyHashable : Any] = [
//                            "IncidentId":incidentId,
//                            "inviterId":uid,
//                            "feature":feature!
//                        ]
//                        let notification = Notification(name: Notification.Name(rawValue: Constants.Notifications.ShareOnboarding), object: nil, userInfo: userInfo)
//                        OnBoardingContext.sharedInstance.inviterId = uid
//                        NotificationCenter.default.post(notification)
//                    } else {
//                        self.waitingForBranch = false
//                        OnBoardingContext.sharedInstance.phoneNumber = nil
//                        OnBoardingContext.sharedInstance.invitationCode = nil
//                        OnBoardingContext.sharedInstance.incidentId = incidentId
//                        OnBoardingContext.sharedInstance.invitedBy = username
//                        OnBoardingContext.sharedInstance.inviterId = uid
//                        OnBoardingContext.sharedInstance.flow = .tease
//                        
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.BranchSignInFromSharing), object: nil)
//                    }
                }
            }
            
//            if channel == "Testers" {
//                if let btts = params["beta-tester-class"] as? String, let btt = BetaTesterType(rawValue: btts) {
//                    SessionUser.instance.shouldOverrideBetaStatusWithBranch = true
//                    SessionUser.instance.betaTesterType = btt
//                }
//                if let bc = params["beta-tester-city"] as? String {
//                    CityManager.instance.bypassLocation = true
//                    CityManager.instance.currentCityCode = bc
//                }
//                
//                CityManager.instance.filterCities()
//            }
            
//            if let enableGeorestrictionsAsString = params["enableGeorestrictions"] as? String, channel == "disable-georestrictions" {
//                let enableGeorestrictions = enableGeorestrictionsAsString == "true"
//                if !SessionUser.instance.isAuthenticated() {
//                    OnBoardingContext.sharedInstance.overrideGeorestrictions = !enableGeorestrictions
//                    
//                    if OnBoardingContext.sharedInstance.overrideGeorestrictions {
//                        let mainWindow = self.window!
//                        let masterController = mainWindow.rootViewController as! MasterController
//                        if let onboardingViewController = masterController.presentedViewController as? OnBoardingViewController {
//                            let viewControllers = onboardingViewController.viewControllers
//                            if let launch = viewControllers.first as? OnBoardingLaunch {
//                                let currentViewController = viewControllers.last!
//                                if currentViewController is NotInAreaViewController {
//                                    launch.loadNextScreen()
//                                }
//                            }
//                        }
//                    }
//                }
//            }
        }
        
        if self.openingFromBranchLink {
            let isFirstTimeSession = params["+is_first_session"] as! Bool
            let clickedBranchLink = params["+clicked_branch_link"] as! Bool
            
            var attrs:[String:AnyObject] = [
                "~channel":params["~channel"]! as AnyObject,
                "~feature":feature! as AnyObject,
                "+is_first_session":isFirstTimeSession as AnyObject,
                "+clicked_branch_link":clickedBranchLink as AnyObject,
                "Open from Deep Link": true as AnyObject,
                ]
            
            if let username = params["username"] as? String {
                attrs["Referring User"] = username as AnyObject
            }
            
            if let tags = params["~tags"] as? [String] {
                var ts = ""
                for t in tags {
                    ts += t
                }
                attrs["~tags"] = ts as AnyObject
            }
            
            if let c = params["~campaign"] {
                attrs["~campaign"] = c as AnyObject
            }
            
            if let s = params["~stage"] {
                attrs["~stage"] = s as AnyObject
            }
            
            if let cs = params["~creation_source"] {
                attrs["~creation_source"] = cs as AnyObject
            }
            
            if let mg = params["+match_guaranteed"] {
                attrs["+match_guaranteed"] = mg as AnyObject
            }
            
            if let r = params["+referrer"] {
                attrs["+referrer"] = r as AnyObject
            }
            
            if let pn = params["+phone_number"] {
                attrs["+phone_number"] = pn as AnyObject
            }
            
            if let pn = params["+is_first_session"] {
                attrs["+is_first_session"] = pn as AnyObject
            }
            
            if let ct = params["+click_timestamp"] {
                attrs["+click_timestamp"] = ct as AnyObject
            }
            
//            if clickedBranchLink && isFirstTimeSession {
//                Analytics.trackInstalledFromBranchLink(attrs)
//            } else if clickedBranchLink {
//                Analytics.trackClickedBranchLink(attrs)
//            }
//            
//            Analytics.trackOpenApp(attrs)
        }
        else {
            self.waitingForBranch = false
//            let customAttributes:[String : AnyObject] = [
//                "Open from Deep Link": false as AnyObject
//            ]
//            Analytics.trackOpenApp(customAttributes)
        }
    }
    
    func initBranch(_ launchOptions: [AnyHashable: Any]?) {
        self.waitingForBranch = true
        let defaultBranchKey = Bundle.main.object(forInfoDictionaryKey: "branch_key") as! String
        var branchKey = defaultBranchKey
        
        if let pendingBranchKey = DataStore.getPendingBranchKey() as String? {
            if pendingBranchKey != "" {
                branchKey = pendingBranchKey
            }
            DataStore.setActiveBranchKey(branchKey)
        } else {
            branchKey = defaultBranchKey
            DataStore.setActiveBranchKey(defaultBranchKey)
        }
        
        if let branch = Branch.getInstance(branchKey) {
            
            branch.setDebug();
            if DataStore.getPendingSetDebugEnabled()! {
                branch.setDebug()
                DataStore.setActivePendingSetDebugEnabled(true)
            } else {
                DataStore.setActivePendingSetDebugEnabled(false)
            }
            branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { (params, error) in
                if (error == nil) {
                    
                    // Deeplinking logic for use when automaticallyDisplayDeepLinkController = false
                    if let clickedBranchLink = params?[BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] as! Bool? {
                        
                        if clickedBranchLink {
                            
//                            let nc = self.window!.rootViewController as! UINavigationController
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let contentViewController = storyboard.instantiateViewController(withIdentifier: "Content") as! ContentViewController
//                            nc.pushViewController(contentViewController, animated: true)
//                            contentViewController.contentType = "Content"
                            self.consumeDeepLink(params!)
                            
                            
                        }
                    } else {
                        self.waitingForBranch = false
                        print(String(format: "Branch TestBed: Finished init with params\n%@", (params?.description)!))
                    }
                    
                    
                } else {
                    print("Branch TestBed: Initialization failed: " + error!.localizedDescription)
                }
                let notificationName = Notification.Name("BranchCallbackCompleted")
                NotificationCenter.default.post(name: notificationName, object: nil)
                
            })
            
        } else {
            print("Branch TestBed: Invalid Key\n")
            DataStore.setActiveBranchKey("")
            DataStore.setPendingBranchKey("")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification launchOptions: [AnyHashable: Any]) -> Void {
        Branch.getInstance().handlePushNotification(launchOptions)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
}

