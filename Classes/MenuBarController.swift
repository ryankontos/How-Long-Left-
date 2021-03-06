//
//  MenuBarController.swift
//  How Long Left?
//
//  Created by Ryan Kontos on 2/5/18.
//  Copyright © 2018 Ryan Kontos. All rights reserved.
//
//  Manages the App Launch, Menu Bar, Triggering of output events, Responding to settings changes, Timers, and Launching windows... basically just too much stuff.
//

import Cocoa
import HotKey
import LaunchAtLogin

class StatusMenuController: NSObject {
    
    @IBOutlet weak var showNotificationsButton: NSMenuItem!
    var fastTimer: Timer!
    var timer = Timer()
    let outputhandler = OutputHandler()
    
    @IBOutlet weak var menuOutput1: NSMenuItem!
    @IBOutlet weak var menuOutput2: NSMenuItem!
    
    @IBOutlet weak var showNotificationButton: NSMenuItem!
    @IBOutlet weak var refreshMenuBarButton: NSMenuItem!
    
    @IBOutlet weak var preferencesButton: NSMenuItem!
    @IBOutlet weak var quitButton: NSMenuItem!
    
    
    
    struct menuLines {
        static var menuLine1 = ""
        static var menuLine2 = ""
    }
    
    
    var hotKeyValue = String()
    var prefs = Preferences()
    
    private var hotKey: HotKey? {
        didSet {
            print("Didset!")
            guard let hotKey = hotKey else {
                return
            }
            
            
            hotKey.keyDownHandler = { [weak self] in
                print("Pressed")
                let _ = calendar.updateCalendarData()
                self?.doTimeToNotification()
                self?.routineMenuBarUpdate(isStart: false)
            }
        }
    }
    
    let calendardata = eventData()
    var calAccess = false

    @IBOutlet weak var statusMenu: NSMenu!

    @IBAction func welcomeViewTest(_ sender: Any) {
        
        var welcomeWindowController : NSWindowController!
        let welcomeStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Welcome"), bundle: nil)
        welcomeWindowController = welcomeStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Welcome")) as! NSWindowController
        // make initial settings before showing the window
        welcomeWindowController.showWindow(self)
    }
    
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBAction func welcomeTest(_ sender: NSMenuItem) {
        showWelcomeView()
    }
    
    func showWelcomeView() {
        let ww = WelcomeWindow()
        ww.openWindow()
    }
    
    
    
    @IBAction func PrefClicked(_ sender: NSMenuItem) {
        
    
        
        var windowController : NSWindowController!
        
        let mainStoryBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
        windowController = mainStoryBoard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Prefs")) as! NSWindowController
        // make initial settings before showing the window
        windowController.showWindow(self) 
    }
    
    func launchCalAcess() {
        let calAccessLaunch = calendardata.getCalendarAccess()
        if calAccessLaunch == false {
            notify.firstLine = "How Long Left does not have calendar access."
            notify.secondLine = "Enable it in System Preferences."
            notify.send()
        }
    }
    
    
    override func awakeFromNib() {
        
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        
        let latestversion = (defaults.string(forKey: "setupComplete"))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.launchApp), name: Notification.Name("setupComplete"), object: nil)
        if latestversion != "1.1" {
            menuOutput1.title = "Complete setup to use How Long Left."
            menuOutput2.isHidden = true
            setupButton.isHidden = false
            showNotificationsButton.isHidden = true
            refreshMenuBarButton.isHidden = true
            preferencesButton.isHidden = true
        launchCalAcess()
        showWelcomeView()
        } else {
        launchCalAcess()
            launchApp()
        }
    }
    
    @IBOutlet weak var setupButton: NSMenuItem!
    @IBAction func setupClicked(_ sender: Any) {
      showWelcomeView()
    }
    
    func setHotKey() {
        

        print("setting HK")
        
       let hotKeySetValue = (defaults.string(forKey: "setHotKey")!)
        
        if hotKeySetValue == "0" {
          
            
          hotKey = HotKey(keyCombo: KeyCombo(key: .w, modifiers: [.option]))
            
        } else if hotKeySetValue == "1"  {
            
            hotKey = HotKey(keyCombo: KeyCombo(key: .t, modifiers: [.command]))
        } else {
            hotKey = nil
            print("Hot key is disabled")
        }
    }
    
    
    
    @objc func launchApp() {
        menuOutput2.isEnabled = false
        menuOutput2.isHidden = true
        setupButton.isHidden = true
        showNotificationsButton.isHidden = false
        refreshMenuBarButton.isHidden = false
        preferencesButton.isHidden = false
        setHotKey()
        defaults.set("1.1", forKey: "setupComplete")
        let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
        icon?.isTemplate = true
        statusItem.image = icon
        statusItem.menu = statusMenu
        routineMenuBarUpdate(isStart: false)
        fastTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(menuCheck), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSettings), name: Notification.Name("settingChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.autoNotify), name: Notification.Name("autoNotify"), object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.EKChange),
            name: .EKEventStoreChanged,
            object: nil)
        
        
    }
    
    @objc func EKChange() {
        print("Event change detected!")
        routineMenuBarUpdate(isStart: false)
    }
    
    @objc func updateMenuItems() {
        menuOutput1.title = menuLines.menuLine1
        menuOutput2.title = menuLines.menuLine2
    }
    
    @objc func autoNotify() {
        // Called by the 
       doTimeToNotification()
    }
    
    @objc func menuCheck() {
      
        let date = Date()
        let calendar = NSCalendar.current
        let seconds = calendar.component(.second, from: date)
        if seconds == 0 {
            routineMenuBarUpdate(isStart: true)
        } else if seconds != 0 {
            let inSync = calendardata.isMenuBarInSync()
            if inSync != true {
            routineMenuBarUpdate(isStart: false)
                
            }
        }
    }
    
    @objc func updateSettings() {
        
        setHotKey()
        OutputHandler.outputArchive.predictedMenuBarText = nil
        print("1")
        routineMenuBarUpdate(isStart: false)
    }
    
    @IBAction func FUMB(_ sender: NSMenuItem) {
        routineMenuBarUpdate(isStart: false)
        print("4")
    }
    
    @objc func routineMenuBarUpdate(isStart: Bool) {
        
        let _ = calendar.updateCalendarData()
        
        let myString = outputhandler.outputMenuBar(isStartMin: isStart)
        let myAttribute = [ NSAttributedStringKey.font: NSFont(name: "Helvetica Neue", size: 13.0)!]
        
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
        
        if myString == "" {
            let icon = NSImage(named: NSImage.Name(rawValue: "statusIcon"))
            statusItem.attributedTitle = myAttrString
            statusItem.image = icon
        } else {
            statusItem.image = nil
          statusItem.attributedTitle = myAttrString
        }
        
        menuBarItemUpdate()
    }
    
    @IBAction func run(_ sender: NSMenuItem) {
        routineMenuBarUpdate(isStart: false)
        doTimeToNotification()
    }
    
    func menuBarItemUpdate() {
        let outputArray = outputhandler.multiLineOutput()
        menuOutput1.title = outputArray[0]
        menuOutput2.title = outputArray[1]
        
        if outputArray[1] == "" {
            menuOutput2.isHidden = true
        } else {
            menuOutput2.isHidden = false
        }
        
    }
    
    func doTimeToNotification() {
        let outputArray = outputhandler.multiLineOutput()
        notify.firstLine = outputArray[0]
        notify.secondLine = outputArray[1]
        notify.send()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
