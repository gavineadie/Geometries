//
//  ViewController.swift
//  Geometries
//
//  Created by Gavin Eadie on 9/25/15.
//  Copyright © 2015 Gavin Eadie. All rights reserved.
//

import Cocoa
import SceneKit
import SpriteKit

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Dimensions (Kms):                                                                                ╎
  ╎             Earth Radius:   6,378                                                                ╎
  ╎     Geostationary Radius:  42,164                                                                ╎
  ╎      Camera Point Radius: 120,000                                                                ╎
  ╎        Moon Orbit Radius: 385,000                                                                ╎
  ╎                                                                                                  ╎
  ╎     •---------•---------•---------•---------•---------•---------•---------•---------•---------•  ╎
  ╎    120       100       80        60        40        20         0       -20       -40       -60  ╎
  ╎     0864208642086420864208642086420864208642086420864208642086420864208642086420864208642086420  ╎
  ╎     C                   N                  |                 |EEEEE|                          F  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

let Rₑ:CGFloat = 6.378135e3                 // equatorial radius (polar radius = 6356.752 Kms)
let π:CGFloat = 3.1415926e0                 // for now

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  │                              +--------------------------------------------------------------+    │
  │                              |                              "com.ramsaycons.geometries.scn" |    │
  │                          +-- |  Node("frame") --------+                                     |    │
  │                          |   |                        |                                     |    │
  │                          |   |                        +-- Node("earth") --+                 |    │
  │ SCNView.scene.rootNode   |   |                        |                   +-- Node("globe") |    │
  │       == Node("total") --+   |                        |                   +-- Node("grids") |    │
  │                          |   |                        |                   +-- Node("coast") |    │
  │                          |   +------------------------|-------------------------------------+    │
  │                          |                            |                                          │
  │                          +-- Node("orbit") --+        +-- Node("spots")                          │
  │                                              |        |                                          │
  │                                              |        +-- Node("solar")                          │
  │                                              |                                                   │
  │                                              +-- Node("camra")                                   │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

        let totalView = self.view as! SceneView
        totalView.scene = SCNScene()

        let totalNode = totalView.scene?.rootNode
        totalNode!.name = "total"

        if let frameScene = SCNScene(named: "com.ramsaycons.geometries.scn"),
           let frameNode = frameScene.rootNode.childNode(withName: "frame", recursively: true) {

            totalNode?.addChildNode(frameNode)                  // "total << "frame"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ a spot on the x-axis (points at vernal equinox)                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let spotsGeom = SCNSphere(radius: 100.0)
            spotsGeom.isGeodesic = true
            spotsGeom.segmentCount = 6

            let spotsNode = SCNNode(geometry:spotsGeom)
            spotsNode.name = "spots"
            spotsNode.position = SCNVector3Make(Rₑ * 1.1, 0, 0)

            frameNode.addChildNode(spotsNode)                   //           "frame" << "spots"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let sunshine = SCNLight()
            sunshine.type = SCNLightTypeDirectional

            let solarNode = SCNNode()
            solarNode.name = "solar"
            solarNode.light = sunshine

//          solarNode.eulerAngles = SCNVector3Make(π/4, π/4, 0.0)
//          solarNode.orientation = SCNVector4Make(1, 0, 0, 0)  // lit from south pole
//          solarNode.orientation = SCNVector4Make(0, 1, 0, 0)  // lit from south pole
//          solarNode.orientation = SCNVector4Make(0, 0, 1, 0)  // lit from north pole
//          solarNode.orientation = SCNVector4Make(0, 0, 0, 1)  // lit from north pole
//          solarNode.orientation = SCNVector4Make(0, 1, 1, 0)  // lit from south tropics +90°
//          solarNode.orientation = SCNVector4Make(1, 0, 1, 0)  // lit from south tropics 0°
//          solarNode.orientation = SCNVector4Make(1, -1, 1, 0)  // lit from south tropics +180°

//          solarNode.rotation = SCNVector4Make(0.0, 1.0, 0.0, 0.0) // top
//          solarNode.rotation = SCNVector4Make(1.0, 0.0, 0.0, 0.0) // top

//          print("SolarNode.transform: \(solarNode.transform)")

//          SolarNode.transform: CATransform3D(
//              m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0,
//              m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0,
//              m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0,
//              m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)

            solarNode.transform = CATransform3DRotate(solarNode.transform, π/2, 1, 0, 0);

//          print("SolarNode.transform: \(solarNode.transform)")

            frameNode.addChildNode(solarNode)                   //           "frame" << "solar"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ attach camera to the edge of a non-rendering node centered on (0, 0, 0) ..                       ╎
  ╎ viewpoint initially on x-axis at 120,000Km with north (z-axis) up                                ╎
  ╎                                                      http://stackoverflow.com/questions/25654772 ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let cameraRange = 120_000.0

            let camera = SCNCamera()
            camera.xFov = 800_000.0 / cameraRange
            camera.yFov = 800_000.0 / cameraRange
            camera.automaticallyAdjustsZRange = true

            let cameraNode = SCNNode()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: CGFloat(cameraRange))
            cameraNode.name = "camra"
            cameraNode.camera = camera

            let cameraConstraint = SCNLookAtConstraint(target: frameNode)
            cameraConstraint.gimbalLockEnabled = true
            cameraNode.constraints = [cameraConstraint]

            let orbitNode = SCNNode()
            orbitNode.name = "orbit"

            orbitNode.addChildNode(cameraNode)                  //            "orbit" << "camra"
            totalNode!.addChildNode(orbitNode)                  // "total" << "orbit"

        }

        totalView.backgroundColor = NSColor.blue()
        totalView.autoenablesDefaultLighting = true
        totalView.showsStatistics = true

//      if let overlay = OverlayScene(fileNamed:"OverlayScene") { totalView.overlaySKScene = overlay }

//        let action = SCNAction.rotateByAngle(π*2, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 5.0)
//        let earthNode = totalView.scene!.rootNode.childNodeWithName("earth", recursively: true)
//        earthNode!.runAction(action)

    }

//    @IBAction func spinAction(sender: NSButton) {
//
//        print("spinAction")
//
//        let sceneView = self.view as! SCNView
//        let scene = sceneView.scene
//
//        if let earthNode = scene!.rootNode.childNodeWithName("earth", recursively: true) {
//
//            let action = SCNAction.rotateByAngle(π*2.0, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 10.0)
//            earthNode.runAction(action)
//
//        }
//        else {
//            print("node 'earth' not found in model")
//        }
//
//    }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (X, Y, X) --> (rad, inc, azi)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraCart2Pole(_ x:Double, _ y:Double, _ z:Double) -> (Double, Double, Double) {
    let rad = sqrt(x*x + y*y + z*z)
    return (rad, acos(z/rad), atan2(y, x))
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (lon, lat, alt) --> (X, Y, X)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraPole2Cart(_ rad:Double, _ inc:Double, _ azi:Double) -> (Double, Double, Double) {
    return (rad * sin(inc) * cos(azi), rad * sin(inc) * sin(azi), rad * cos(inc))
}

extension SCNVector3 {
    public init(_ t: (Double, Double, Double)) {
        x = CGFloat(t.0)
        y = CGFloat(t.1)
        z = CGFloat(t.2)
    }
}

