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

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

#if os(iOS) || os(tvOS) || os(watchOS)
    typealias Color = UIColor
#else
    typealias Color = NSColor
#endif

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

extension SCNVector3 {

    public init(_ v: Vector) {
        self.init()
        x = CGFloat(v.x)
        y = CGFloat(v.y)
        z = CGFloat(v.z)
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

extension Comparable {
    func clamp(from lowerBound: Self, to upperBound: Self) -> Self {
        return min(max(self, lowerBound), upperBound)
    }
}

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
