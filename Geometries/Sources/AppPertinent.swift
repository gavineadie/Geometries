/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AppPertinent.swift                                                                    Satellites ║
  ║ Created by Gavin Eadie on Nov27/17         Copyright © 2017-18 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable discarded_notification_center_observer

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#else
    import Cocoa
#endif

import SatKit

enum Debug {

    static let clock = false
    static let error = false                        // debug error code
    static let https = false
    static let other = false
    static let scene = false
    static let trace = true
    static let views = true

}

class AppSupport {

    static let shared = AppSupport()                // application support singleton ..

    private init() {
#if DEBUG
    print("""
                AppSupport| DEBUG BUILD
                          | Debug.clock=\(Debug.clock)
                          | Debug.error=\(Debug.error)
                          | Debug.https=\(Debug.https)
                          | Debug.other=\(Debug.other)
                          | Debug.scene=\(Debug.scene)
                          | Debug.trace=\(Debug.trace)
                          | Debug.views=\(Debug.views)
  """)
#else
    print("              AppSupport| RELEASE BUILD")
#endif

        if Debug.trace { print("              AppSupport| .. init") }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ application startup ..                                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func starting(_ application: Application) {
        if Debug.trace { print("              AppSupport| .. startup") }

#if os(iOS) || os(tvOS) || os(watchOS)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ iOS Version ..                                                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let myDevice = UIDevice.current

        print(String(format: "              AppSupport| .. startup .. %@ %@ on %@",
                     myDevice.systemName,
                     ProcessInfo.processInfo.operatingSystemVersionString,
                     stringsFromHardware()["hw.machine"] ?? "UNKNOWN"))

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Application Version ..                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        print(String(format: "              AppSupport| .. startup .. %@ v%@ (#%d • %@-bit) [%@ @ %@]",
                     "AppDisplayName".localized(), Bundle.shortVersion, Bundle.versionNumber,
                     UIDevice.systemIs64Bit ? "64" : "32", Bundle.dateStamp, Bundle.timeStamp))
#else
        print(String(format: "              AppSupport| .. startup .. %@ v%@ (#%d) [%@ @ %@]",
                     Bundle.displayName, Bundle.shortVersion, Bundle.versionNumber,
                     Bundle.dateStamp, Bundle.timeStamp))
#endif

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ SatKit Version ..                                                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        print(String(format: "              AppSupport| .. startup .. %@", SatKit.version))

        if Debug.error { print("              AppSupport| .. failure " + "MissingKey".localized()) }

//      appUpgradeActions()

#if os(iOS) || os(tvOS) || os(watchOS)
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ catch screen connect notification (UIScreenDidConnectNotification)                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        NotificationCenter.default.addObserver(forName: .UIScreenDidConnect,
                                               object: nil, queue: nil, using: { notification in
                print("                        | \(notification)")
        })

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ catch screen disconnect notification (UIScreenDidDisconnectNotification)                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        NotificationCenter.default.addObserver(forName: .UIScreenDidDisconnect,
                                               object: nil, queue: nil, using: { notification in
                print("                        | \(notification)")
        })

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ catch defaults change notification (NSUserDefaultsDidChangeNotification)                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
                                               object: nil, queue: nil, using: { notification in
                print("                        | \(notification)")
        })

#endif

        if SatelliteStore.shared.visualGroup == nil {

            SatelliteStore.shared.downloadLocal()

        }

    }

    func resigned(_ application: Application) {
        if Debug.trace { print("              AppSupport| .. resigned") }

    }

    func energize(_ application: Application) {
        if Debug.trace { print("              AppSupport| .. energize") }

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ application shutdown ..                                                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func shutdown(_ application: Application) {
        if Debug.trace { print("              AppSupport| .. shutdown") }

    }

}

func predictions() {

}

extension SatelliteStore {

    func downloadLocal() {

        let localFile = "file:///Users/gavin/Library/Application%20Support/com.ramsaycons.tle/visual.txt"
        do {
            let localURL = URL(string: localFile)!
            let satCollectionKey = localURL.deletingPathExtension().lastPathComponent

            let tleChunk = try String(contentsOf: localURL)

            var satelliteGroup = SatelliteGroup()
            satelliteGroup.processTLEs(tleChunk) // .components(separatedBy: "\n"))

            SatelliteStore.shared.setGroup(named: satCollectionKey, group: satelliteGroup)
        } catch {
            print("error")
        }

    }

}
