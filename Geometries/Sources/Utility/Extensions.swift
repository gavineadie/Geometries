/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Extensions.swift                                                                      Geometries ║
  ║ Created by Gavin Eadie on Feb04/17 .. Copyright 2018-16 Ramsay Consulting. All rights reserved.  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SceneKit
import SatelliteKit

let deg2rad = Double(π / 180.0)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Copyright (c) 2015 Suyeol Jeon (xoul.kr)                                                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public protocol Then { }

extension Then where Self: AnyObject {

/// Makes it possible to set properties with closures just after initializing.
///
///     let label = UILabel().then {
///       $0.textAlignment = .Center
///       $0.textColor = UIColor.blackColor()
///       $0.text = "Hello, World!"
///     }

    public func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }

}

extension NSObject: Then {}

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
  ║ Created by Gavin Eadie on Sep03/17         Copyright © 2017-19 Gavin Eadie. All rights reserved. ║
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
  ║ Created by Gavin Eadie on Jan17/20 ... Copyright 2020-23 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)

    import UIKit

    public typealias Application = UIApplication
    public typealias ApplicationDelegate = UIApplicationDelegate

    public typealias ViewController = UIViewController
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
