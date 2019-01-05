/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AppPertinent.swift                                                                    Satellites ║
  ║ Created by Gavin Eadie on Nov27/17         Copyright © 2017-18 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable discarded_notification_center_observer
// swiftlint:disable weak_delegate

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit

    typealias Font = UIFont
    typealias View = UIView
#else
    import Cocoa

    typealias Font = NSFont
    typealias View = NSView
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

protocol AppSupportDelegate: AnyObject {

    func doApplicationUpgrade()
    func doApplicationPhoneHome()

}

class AppSupport {

    static let shared = AppSupport()                // application support singleton ..

    var delegate: AppSupportDelegate?

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

        delegate?.doApplicationPhoneHome()
#endif
//        downloadTLEs("http://www.celestrak.com/NORAD/elements/visual.txt")

//      predictions()

//        let satStore = SatelliteStore.shared
//
//        let observation = satStore.observe(\.name) { (satStore, change) in
//            print("satStore.name: \(satStore.name) .. \(change)")
//        }
//
//        satStore.name = "B"
//
//        observation.invalidate()
//
//        satStore.name = "C"

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
