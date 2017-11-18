/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Extensions.swift                                                                      Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Feb04/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable variable_name

import SceneKit

let Rₑ: Double = 6.378135e3                // equatorial radius (polar radius = 6356.752 Kms)
let π: Double = 3.141_592_653_589_793_238_462_643_383_279_502_884_197_169_399_375_105_820_975
let deg2rad = Double(π / 180.0)

#if os(iOS) || os(tvOS) || os(watchOS)
    typealias Color = UIColor
#else
    typealias Color = NSColor
#endif

infix operator <<<

extension SCNNode {

    static func <<< (lhs: SCNNode, rhs: SCNNode) {
        lhs.addChildNode(rhs)
    }

}

extension CGFloat {

    static let π: CGFloat = 3.1415926

}
