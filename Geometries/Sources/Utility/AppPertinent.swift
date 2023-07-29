/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AppPertinent.swift                                                                     AppExtras ║
  ║ Created by Gavin Eadie on Nov27/17         Copyright © 2017-23 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#else
    import AppKit
#endif

import OSLog

public enum Debug {

    public static let clock = false
    public static let error = true                         // debug error code
    public static let https = false
    public static let other = false
//    public static let scene = false
    public static let trace = true
    public static let views = true

}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public class AppSupport {

    public static let shared = AppSupport()                // application support singleton ..

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    private init() {
        print("              AppSupport| .. init")

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

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ P R E S T A R T                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func prestart(_ application: Application) {
        print("              AppSupport| .. prestart")

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ S T A R T I N G                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func starting(_ application: Application) {
        print("              AppSupport| .. starting")

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ E N E R G I Z E                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func energize(_ application: Application) {
        print("              AppSupport| .. energize")

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ R E S I G N E D                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func resigned(_ application: Application) {
        print("              AppSupport| .. resigned")

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ S H U T D O W N                                                                      application │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func shutdown(_ application: Application) {
        if Debug.trace { print("              AppSupport| .. shutdown") }

    }

}
