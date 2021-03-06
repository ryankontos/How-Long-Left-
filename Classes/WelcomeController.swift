//
//  WelcomeController.swift
//  How Long Left?
//
//  Created by Ryan Kontos on 8/5/18.
//  Copyright © 2018 Ryan Kontos. All rights reserved.
//
//  Controls the Welcome window.
//

import EventKit
import LaunchAtLogin

let userData = UserDefaults.standard

class WelcomeWindow: NSWindowController {
    
    func openWindow() {
        var welcomeWindowController : NSWindowController?
        
        
        
        let welcomeStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Welcome"), bundle: nil)
        welcomeWindowController = welcomeStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Welcome")) as? NSWindowController
        welcomeWindowController?.showWindow(self)
        
        
    }
    
    
    override func windowDidLoad() {
        
        window?.styleMask.remove(.resizable)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
    
    }
}


class tabView: NSTabViewController {
    
    @IBOutlet weak var tabViewController: NSTabView!
    
    
    
    override func viewWillAppear() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.nav), name: Notification.Name("welcomeNavigate"), object: nil)
        
        
        
    }
        
    @objc func nav(data: Notification) {
        
        let navTo = data.object!
        tabViewController.selectTabViewItem(at: navTo as! Int)
        
        
    }
    
   
}

class welcomeNav: NSViewController {

    func navTo(page: Int) {
        NotificationCenter.default.post(name: Notification.Name("welcomeNavigate"), object: page)
    }
    
    
}


class Welcome_updateWelcome: welcomeNav {
    @IBAction func next(_ sender: Any) {
        navTo(page: 1)
    }
    
}

class Welcome_WelcometoHowLongLeft: welcomeNav {
    
    
    // 1
    
    @IBAction func next(_ sender: Any) {
        navTo(page: 1)
    }
    
    override func viewWillAppear() {
        
        if defaults.string(forKey: "setupComplete") != nil {
        if defaults.string(forKey: "setupComplete") == "1.0" {
            navTo(page: 7)
        }
        }
    }
}

class Welcome_LetsGetStarted: welcomeNav {
    
    // 2
    
    @IBAction func back(_ sender: NSButton) {
        
        
        if defaults.string(forKey: "setupComplete") != nil {
            if defaults.string(forKey: "setupComplete") == "1.0" {
                navTo(page: 7)
            } else {
                navTo(page: 0)
            }
        } else {
            navTo(page: 0)
        }
    }
    
        
    @IBAction func next(_ sender: Any) {
        navTo(page: 3)
    }
}

class Welcome_CalendarAccess: welcomeNav {
    @IBOutlet weak var nextbuttonitem: NSButton!
    
    @IBAction func back(_ sender: Any) {
        navTo(page: 1)
    }
    
    @IBAction func next(_ sender: Any) {
        navTo(page: 4)
    }
    
    @IBAction func shortcut(_ sender: NSButton) {
      nextbuttonitem.isEnabled = true
      defaults.set(sender.identifier!, forKey: "setHotKey")
        print(sender.identifier!)
    }
    
    
}
    
    class Welcome_Calendars: welcomeNav {
        
        @IBAction func back(_ sender: NSButton) {
            navTo(page: 2)
        }
        @IBAction func next(_ sender: Any) {
            navTo(page: 5)
        }
        
        @IBOutlet weak var calendarsUseAll: NSButton!
        @IBOutlet weak var calendarsSelectPopUp: NSPopUpButton!
       
        override func viewWillAppear() {
            
            let setCal = defaults.string(forKey: "Calendar")
            let calsArray = cal.getCalendars()
            for item in calsArray {
                calendarsSelectPopUp.addItem(withTitle: (item?.title)!)
            }
            
            if setCal == nil {
            
            
            calendarsSelectPopUp.isEnabled = false
             defaults.set("HLL_AllCals", forKey: "Calendar")
            if calendarsUseAll.state.rawValue == 0 {
                calendarsUseAll.setNextState()
            }
            
            
            } else {
               
                if setCal! == "HLL_AllCals" {
                    calendarsSelectPopUp.isEnabled = false
                    if calendarsUseAll.state.rawValue == 0 {
                        calendarsUseAll.setNextState()
                    }
                } else {
                    if calendarsUseAll.state.rawValue == 1 {
                        calendarsUseAll.setNextState()
                    }
                  calendarsSelectPopUp.selectItem(withTitle: setCal!)
                }
                
                
                
            }
        }
        
        @IBAction func calendarsUseAllChanged(_ sender: NSButton) {
            if calendarsUseAll.state.rawValue == 1 {
                calendarsSelectPopUp.isEnabled = false
                defaults.set("HLL_AllCals", forKey: "Calendar")
            } else {
               calendarsSelectPopUp.isEnabled = true
                if calendarsSelectPopUp.selectedItem != nil {
                    defaults.set(calendarsSelectPopUp.selectedItem!.title, forKey: "Calendar")
                }
            }
        }
        
        @IBAction func popUpCalSelectChanged(_ sender: NSPopUpButton) {
            defaults.set(calendarsSelectPopUp.selectedItem!.title, forKey: "Calendar")
        }
    }

class Welcome_Preferences: welcomeNav {
    
    @IBOutlet weak var launchAtLoginButton: NSButton!
    
    @IBAction func launchAtLoginButtonClicked(_ sender: NSButton) {
        if sender.state.rawValue == 1 {
            LaunchAtLogin.isEnabled = true
        } else {
           LaunchAtLogin.isEnabled = false
        }
    }
    
    @IBAction func tenminbuttonclicked(_ sender: NSButton) {
        if sender.state.rawValue == 0 {
            print("Turning off:")
            switch sender.title {
            case "Has 10 minutes left":
                print("Has 10 minutes left")
                defaults.set(0, forKey: "autoAlert10")
            case "Has 5 minutes left":
                print("Has 5 minutes left")
                defaults.set(0, forKey: "autoAlert5")
            case "Has 1 minute left":
                print("Has 1 minute left")
                defaults.set(0, forKey: "autoAlert1")
            case "Finishes":
                print("Finishes")
                defaults.set(0, forKey: "autoAlert0")
            default:
                print("Not found")
            }
        } else {
            print("Turning on:")
            switch sender.title {
            case "Has 10 minutes left":
                print("Has 10 minutes left")
                defaults.set(1, forKey: "autoAlert10")
            case "Has 5 minutes left":
                print("Has 5 minutes left")
                defaults.set(1, forKey: "autoAlert5")
            case "Has 1 minute left":
                print("Has 1 minute left")
                defaults.set(1, forKey: "autoAlert1")
            case "Finishes":
                print("Finishes")
                defaults.set(1, forKey: "autoAlert0")
            default:
                print("Not found")
            }
        }
    }
    
    @IBAction func back(_ sender: NSButton) {
        navTo(page: 4)
    }
    
    @IBAction func next(_ sender: Any) {
        navTo(page: 6)
    }
    
    @IBOutlet weak var WelcomePrefsShowNext: NSButton!
    @IBOutlet weak var WelcomePrefsMenuBar: NSPopUpButton!
    
    override func viewWillAppear() {
        
        defaults.set(1, forKey: "autoAlert10")
        defaults.set(1, forKey: "autoAlert5")
        defaults.set(1, forKey: "autoAlert1")
        defaults.set(1, forKey: "autoAlert0")
        
        defaults.set(WelcomePrefsMenuBar.selectedItem?.title, forKey: "menuBarFormat")
        
        LaunchAtLogin.isEnabled = false
        if launchAtLoginButton.state.rawValue == 1 {
           launchAtLoginButton.setNextState()
        }
    }
    
    @IBAction func showNextChanged(_ sender: Any) {
        if WelcomePrefsShowNext.state.rawValue == 1 {
            // Enable next
        } else {
            // Disable next
        }
    }
    
    @IBAction func menuBarFormatChanged(_ sender: NSPopUpButton) {
     defaults.set(WelcomePrefsMenuBar.selectedItem?.title, forKey: "menuBarFormat")
        NotificationCenter.default.post(name: Notification.Name("settingChanged"), object: nil)
    }
}

class Welcome_YoureAllSet: welcomeNav {
    @IBAction func back(_ sender: NSButton) {
        navTo(page: 5)
    }
    
    @IBAction func Done(_ sender: NSButton) {
        defaults.set("1.1", forKey: "setupComplete")
        NotificationCenter.default.post(name: Notification.Name("setupComplete"), object: nil)
      self.view.window?.close()
    }
}


