/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AppDelegate.swift                                                                     Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     Insert code here to initialize your application                                              ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        downloadTLEs("http://www.celestrak.com/NORAD/elements/visual.txt")

//      downloadTLEs("https://www.prismnet.com/~mmccants/programs/qsmag.zip")

    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     When the last window closes, it's time to say Goodbye (and thanks for all the fish!) ..      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {

        return true

    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     Insert code here to tear down your application                                               ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func applicationWillTerminate(_ aNotification: Notification) {

    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃     Insert code here to to request that the file filename be opened as a linked file             ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func application(_ sender: Any, openFileWithoutUI filename: String) -> Bool {

        print("application.openFileWithoutUI: \(filename) from \(sender)")

        return true

    }
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ This application runs on Mac OS 10.10 or above because of certain SceneKit and Recognizer usage. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/
