/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Satellite.swift                                                                       Satellites ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jan01/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SatKit
import SceneKit

public extension Satellite {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    var trailNode: SCNNode {
        let basicNode = SCNNode()
        basicNode.name = self.noradIdent

        for _ in 0...orbTickRange.count {
            let dottyGeom = SCNSphere(radius: 10.0)         //
            dottyGeom.isGeodesic = true
            dottyGeom.segmentCount = 6
            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // NSColor.white (!!CPU!!)

            let dottyNode = SCNNode(geometry: dottyGeom)
            dottyNode.position = SCNVector3(0.0, 0.0, 0.0)

            basicNode <<< dottyNode                         //                      "trail" << "dotty"
        }

        return basicNode
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func positionsᴱᴾ(epochStride: StrideThrough<Double>) -> [Vector] {

        var result = [Vector]()

        for epochMin in epochStride {
            result.append(self.position(minsAfterEpoch: epochMin))
        }

        return result
    }
}
