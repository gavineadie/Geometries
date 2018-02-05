/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Extensions.swift                                                                      Geometries ║
  ║ Created by Gavin Eadie on Feb04/17  ..  Copyright © 2018 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import SceneKit
import SatKit

let Rₑ: Double = 6.378135e3                // equatorial radius (polar radius = 6356.752 Kms)
let  π: Double = 3.141_592_653_589_793_238_462_643_383_279_502_884_197_169_399_375_105_820_975
let deg2rad = Double(π / 180.0)

#if os(iOS) || os(tvOS) || os(watchOS)
    typealias Color = UIColor
#else
    typealias Color = NSColor
#endif

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
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
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
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

//  public static var bundleID: String? { return main.bundleIdentifier }
//     open func object(forInfoDictionaryKey key: String) -> Any?

    public static var displayName: String {
        return main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "AppName"
    }

    public static var versionString: String {
        return main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "0"
    }

    public static var versionNumber: Int { return Int(versionString) ?? 0 }

    public static var shortVersion: String {
        return main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    public static var dateStamp: String {
        return main.object(forInfoDictionaryKey: "AppBuildDate") as? String ?? "BuildDate"
    }

    public static var timeStamp: String {
        return main.object(forInfoDictionaryKey: "AppBuildTime") as? String ?? "BuildTime"
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
  ║ Created by Gavin Eadie on Sep03/17         Copyright © 2017-18 Gavin Eadie. All rights reserved. ║
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

//Now I can use async dispatch the way God intended:
//
//DispatchQueue.main.asyncAfter(deadline: 5) { /* ... */ }
