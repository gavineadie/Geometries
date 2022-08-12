/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AppDelegate.swift                                                                     Geometries ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-20 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ This application runs on Mac OS 10.10 or above because of certain SceneKit and Recognizer usage. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ This application runs on Mac OS 10.11 due to NSDataAsset, MTKTextureLoader and SceneView.device. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ This application runs on Mac OS 10.12 due to texture access from Asset Catalog.                  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable force_cast

import Cocoa
import AppExtras
import os.log

@NSApplicationMain

class AppDelegate: NSObject, ApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    let appSupport = AppSupport.shared

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     Insert code here to initialize your application                                              ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationWillFinishLaunching(_ notification: Notification) {
        Logger.everything.info("             Application| applicationWillFinishLaunching()")

        appSupport.prestart(notification.object as! Application)

    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.everything.info("             Application| DidFinishLaunching()")

        appSupport.starting(notification.object as! Application)

    }

    func applicationDidResignActive( _ notification: Notification) {

        appSupport.resigned(notification.object as! Application)

    }

    func applicationWillBecomeActive( _ notification: Notification) {

        appSupport.energize(notification.object as! Application)

    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     Insert code here to tear down your application                                               ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationWillTerminate(_ notification: Notification) {
        Logger.everything.info("             Application| WillTerminate()")

        appSupport.shutdown(notification.object as! Application)

    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     When the last window closes, it's time to say Goodbye (and thanks for all the fish!) ..      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationShouldTerminateAfterLastWindowClosed(_ app: Application) -> Bool {

        return true

    }

///*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
//  ┃     Insert code here to to request that the file filename be opened as a linked file             ┃
//  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
//    func application(_ sender: Any, openFileWithoutUI filename: String) -> Bool {
//
//        Logger.everything.info("application.openFileWithoutUI: \(filename) from \(sender)")
//
//        return true
//
//    }
}
