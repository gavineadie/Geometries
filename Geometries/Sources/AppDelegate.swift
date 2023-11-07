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
import os.log

@NSApplicationMain

class AppDelegate: NSObject, ApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  │ P R E S T A R T                                                                      application │
  ┃     Insert code here to initialize your application                                              ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("             Application| applicationWillFinishLaunching()")

#if DEBUG
        print("""
               Application| DEBUG BUILD
                          | Debug.clock=\(Debug.clock)
                          | Debug.error=\(Debug.error)
                          | Debug.https=\(Debug.https)
                          | Debug.other=\(Debug.other)
                          | Debug.scene=\(Debug.scene)
                          | Debug.trace=\(Debug.trace)
                          | Debug.views=\(Debug.views)
  """)
#else
        print("             Application| RELEASE BUILD")
#endif

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ S T A R T I N G                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("             Application| DidFinishLaunching()")

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ R E S I G N E D                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func applicationDidResignActive( _ notification: Notification) {

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ E N E R G I Z E                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func applicationWillBecomeActive( _ notification: Notification) {

    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  │ S H U T D O W N                                                                      application │
  ┃     Insert code here to tear down your application                                               ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationWillTerminate(_ notification: Notification) {
        print("             Application| WillTerminate()")

    }

// swiftlint:enable force_cast

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     When the last window closes, it's time to say Goodbye (and thanks for all the fish!) ..      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationShouldTerminateAfterLastWindowClosed(_ app: Application) -> Bool {
        print("             Application| ShouldTerminateAfterLastWindowClosed")

        return true

    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     Insert code here to to request that the file filename be opened as a linked file             ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func application(_ sender: Any, openFileWithoutUI filename: String) -> Bool {
        print("             Application| openFileWithoutUI: \(filename)")

        return true

    }
}
