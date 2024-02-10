/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Extensions.swift                                                                      Geometries ║
  ║ Created by Gavin Eadie on Feb04/17 .. Copyright 2018-24 Ramsay Consulting. All rights reserved.  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SceneKit
import SatelliteKit

let deg2rad = Double(π / 180.0)

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AppPertinent.swift                                                                     AppExtras ║
  ║ Created by Gavin Eadie on Nov27/17         Copyright © 2017-24 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
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
    public static let trace = true
    public static let views = true

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
// swiftlint:disable identifier_name

extension SCNVector3 {

    public init(_ v: Vector) {
        self.init(v.x, v.y, v.z)
    }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
infix operator <<<

extension SCNNode {

    public convenience init(name: String) {
        self.init()
        self.name = name
    }

    public convenience init(geometry: SCNGeometry?, name: String) {
        self.init(geometry: geometry)
        self.name = name
    }

    static func <<< (lhs: SCNNode, rhs: SCNNode) {
        lhs.addChildNode(rhs)
    }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ define π (pi) .. the ration between the diameter and circumference of a circle ..                │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
extension Double {
    static let π: Double = 3.141_592_653_589_793_238_462_643_383_279_502_884_197_169_399_375_105
}

extension CGFloat {
    static let π: CGFloat = 3.141_592_653_589_793_238_462
}

extension Float {
    static let π: Float = 3.141_592_653_589_793_238_462
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
extension String {

    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "»\(self)«", comment: "")
    }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
extension Bundle {

    public static var bundleID: String? { return main.bundleIdentifier }

    public static var displayName: String {
        return main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "AppName"
    }

    public static var versionString: String {
        return main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "0"
    }

    public static var versionNumber: Int { return Int(versionString) ?? 0 }

    public static var shortVersion: String {
        return main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    public static var dateStamp: String {
        return main.infoDictionary?["AppBuildDate"] as? String ?? "BuildDate"
    }

    public static var timeStamp: String {
        return main.infoDictionary?["AppBuildTime"] as? String ?? "BuildTime"
    }

    public static func pListHasValue(forKey key: String) -> Bool {
        guard let dict = main.infoDictionary else { return false }
        return dict[key] != nil
    }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
extension Comparable {

    func clamp(from lowerBound: Self, to upperBound: Self) -> Self {
        return min(max(self, lowerBound), upperBound)
    }

}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Environment.swift                                                                     Satellites ║
  ║ Created by Gavin Eadie on Sep03/17         Copyright © 2017-24 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#if os(iOS) || os(tvOS) || os(watchOS)
extension UIDevice {

    public static var systemIs64Bit: Bool { return CGFLOAT_IS_DOUBLE == 1 }

}
#endif

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
extension DispatchTime: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = DispatchTime.now() + .seconds(value)
    }

}

extension DispatchTime: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        self = DispatchTime.now() + .milliseconds(Int(value * 1000))
    }

}

// Now I can use async dispatch the way God intended:
//
// DispatchQueue.main.asyncAfter(deadline: 5) { /* ... */ }

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Extensions.swift                                                                       AppExtras ║
  ║ Created by Gavin Eadie on Jan17/20 ... Copyright 2020-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    import UIKit

    public typealias Application = UIApplication
    public typealias ApplicationDelegate = UIApplicationDelegate

//    public typealias ViewController = UIViewController
    public typealias View = UIView
    public typealias Image = UIImage

    public typealias Font = UIFont
    public typealias Color = UIColor
    public typealias BezierPath = UIBezierPath

    extension BezierPath { public func line(to point: CGPoint) { addLine(to: point) } }

#else

    import AppKit

    public typealias Application = NSApplication
    public typealias ApplicationDelegate = NSApplicationDelegate

//    public typealias ViewController = NSViewController
    public typealias View = NSView
    public typealias Image = NSImage

    public typealias Font = NSFont
    public typealias Color = NSColor
    public typealias BezierPath = NSBezierPath

#endif

public struct Geometries {

    var staticVersion = "~~VersionBuild~~"          // v1.1.0 (321)
    var staticLibDate = "~~AppBuildDate~~"          // Feb27/22
    var staticLibTime = "~~AppBuildTime~~"          // 20:15:10
    var staticLibInfo = "~~CopyrightText~~"         // Copyright 2016-24 Ramsay Consulting

    public static var version: String {
        guard let satelliteKitBundle = Bundle(identifier: "com.ramsaycons.Geometries"),
              let plistDictionary = satelliteKitBundle.infoDictionary else {
            return "No 'Geometries' Info.plist"
        }

        return String(format: "%@ v%@ (#%@) [%@ @ %@]",
                      plistDictionary["CFBundleName"] as? String ?? "Library",
                      plistDictionary["CFBundleShortVersionString"] as? String ?? "v0.0",
                      plistDictionary["CFBundleVersion"] as? String  ?? "0",
                      plistDictionary["AppBuildDate"] as? String ?? "BuildDate",
                      plistDictionary["AppBuildTime"] as? String ?? "BuildTime")
    }

}
