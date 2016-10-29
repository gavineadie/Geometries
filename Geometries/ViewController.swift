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

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Dimensions (Kms):                                                                                ║
  ║             Earth Radius:   6,378                                                                ║
  ║     Geostationary Radius:  42,164                                                                ║
  ║      Camera Point Radius: 120,000                                                                ║
  ║        Moon Orbit Radius: 385,000                                                                ║
  ║                                                                                                  ║
  ║     •---------•---------•---------•---------•---------•---------•---------•---------•---------•  ║
  ║    120       100       80        60        40        20         0       -20       -40       -60  ║
  ║     0864208642086420864208642086420864208642086420864208642086420864208642086420864208642086420  ║
  ║     C                   N                  |                 |EEEEE|                          F  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

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
  │                                              |        +-- Node("light")                          │
  │                                              |                                                   │
  │                                              +-- Node("camra")                                   │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

        let totalView = self.view as! SceneView
        totalView.scene = SCNScene()

        let totalNode = totalView.scene?.rootNode
        totalNode!.name = "total"

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
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: CGFloat(cameraRange))
        cameraNode.name = "camra"

        let cameraConstraint = SCNLookAtConstraint(target: totalNode)
        cameraConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [cameraConstraint]

        let orbitNode = SCNNode()
        orbitNode.name = "orbit"

        orbitNode.addChildNode(cameraNode)                  //            "orbit" << "camra"
        totalNode!.addChildNode(orbitNode)                  // "total" << "orbit"

        if let frameScene = SCNScene(named: "com.ramsaycons.geometries.scn"),
           let frameNode = frameScene.rootNode.childNode(withName: "frame", recursively: true) {

            totalNode?.addChildNode(frameNode)              // "total << "frame"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ a spot on the x-axis (points at vernal equinox)                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let spotsGeom = SCNSphere(radius: 100.0)
            spotsGeom.isGeodesic = true
            spotsGeom.segmentCount = 6

            let spotsNode = SCNNode(geometry:spotsGeom)
            spotsNode.name = "spots"
            spotsNode.position = SCNVector3Make(Rₑ * 1.1, 0, 0)

            frameNode.addChildNode(spotsNode)               //           "frame" << "spots"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let sunLight = SCNLight()
            sunLight.type = SCNLight.LightType.directional  // make a directional light

            let lightNode = SCNNode()
            lightNode.name = "light"
            lightNode.light = sunLight

            frameNode.addChildNode(lightNode)               //           "frame" << "light"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

            let solarNode = SCNNode()                       // position of sun in (x,y,z)
            frameNode.addChildNode(solarNode)

            solarNode.position = SCNVector3((-1000.0, -1000.0, 0.0))

            let solarConstraint = SCNLookAtConstraint(target: solarNode)
            lightNode.constraints = [solarConstraint]       // keep the light coming from the sun
        }

        totalView.backgroundColor = NSColor.blue
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

