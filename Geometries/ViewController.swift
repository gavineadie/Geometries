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

let Rₑ:CGFloat = 6.378135e3                 // equatorial radius (polar radius = 6356.752 Kms)
let π:CGFloat = 3.1415926e0                 // for now

class ViewController: NSViewController {

    var scene:SCNScene!

    override func viewDidLoad() {
        super.viewDidLoad()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │          +-------------------------------------------------------------------------------------+ │
  │ SCNView -- SCNScene --+                                        "com.ramsaycons.geometries.scn" | │
  │          |            |                                                                        | │
  │          |            +-- rootNode --+                                                         | │
  │          |                           |                                                         | │
  │          |                "ECEI" --> +-- Node("frame") --+                                     | │
  │          |                           |                   |                                     | │
  │          |          at (0,0,0) and rotates with time --> +-- Node("earth") --+                 | │
  │          |                           |                   |                   +-- Node("globe") | │
  │          |                           |                   |                   +-- Node("grids") | │
  │          |                           |                   |                   +-- Node("coast") | │
  │          +---------------------------|-------------------|-------------------------------------+ │
  │                                      |                   |                                       │
  │                                      +-- Node("spots")   |                                       │
  │                                      |                   |                                       │
  │                                      +-- Node("solar")   |                                       │
  │                                      |                   |                                       │
  │   positioned, rotates by touches --> +-- Node("camra")   |                                       │
  │                                                          |                                       │
  │                   positioned in space, moves quickly --> +-- Node("orbit")                       │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

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

        scene = SCNScene(named: "com.ramsaycons.geometries.scn")

        if let frameNode = scene!.rootNode.childNodeWithName("frame", recursively: true) {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ a spot on the x-axis (points at vernal equinox)                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let spotsGeom = SCNSphere(radius: 100.0)
            spotsGeom.geodesic = true
            spotsGeom.segmentCount = 6

            let spotsNode = SCNNode(geometry:spotsGeom)
            spotsNode.name = "spots"
            spotsNode.position = SCNVector3Make(Rₑ * 1.1, 0, 0)
            frameNode.addChildNode(spotsNode)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ viewpoint initially on x-axis at 120,000Km with north (z-axis) up                                ╎
  ╎     http://stackoverflow.com/questions/25654772                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let cameraRange = 120_000.0

            let camera = SCNCamera()
            camera.xFov = 800_000.0 / cameraRange
            camera.yFov = 800_000.0 / cameraRange
            camera.zNear = cameraRange * 0.2
            camera.zFar = cameraRange * 1.5

            let cameraNode = SCNNode()
            cameraNode.position = SCNVector3(x: CGFloat(cameraRange), y: 0, z: 0)
            cameraNode.name = "camra"
            cameraNode.camera = camera

//          cameraNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: PI/2.0)
            cameraNode.constraints = [SCNLookAtConstraint(target: frameNode)]

            let orbitNode = SCNNode()
            orbitNode.name = "orbit"
            orbitNode.addChildNode(cameraNode)

            scene.rootNode.addChildNode(orbitNode)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let sunshine = SCNLight()
            sunshine.type = SCNLightTypeOmni

            let solarNode = SCNNode()
            solarNode.name = "solar"
            solarNode.light = sunshine
            solarNode.position = SCNVector3Make(1_000_000, 1_000_000, 0)
            frameNode.addChildNode(solarNode)
            
        }

        let sceneView = self.view as! SceneView
        sceneView.scene = scene
        sceneView.backgroundColor = NSColor.blackColor()
        sceneView.autoenablesDefaultLighting = false
//        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true

        sceneView.overlaySKScene = OverlayScene(fileNamed:"OverlayScene")

//        let latAngle = sceneView.latAngle
//        let lonAngle = sceneView.lonAngle

//        let action = SCNAction.rotateByAngle(PI*2.0, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 10.0)
//        let earthNode = scene.rootNode.childNodeWithName("earth", recursively: true)
//        earthNode!.runAction(action)

    }

    @IBAction func spinAction(sender: NSButton) {

        print("spinAction")

        let sceneView = self.view as! SCNView
        let scene = sceneView.scene

        if let earthNode = scene!.rootNode.childNodeWithName("earth", recursively: true) {

            let action = SCNAction.rotateByAngle(π*2.0, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 10.0)
            earthNode.runAction(action)

        }
        else {
            print("node 'earth' not found in model")
        }

    }

}

/*box
    (X, Y, X) --> (rad, inc, azi)
 */
func cameraCart2Pole(x:Double, _ y:Double, _ z:Double) -> (Double, Double, Double) {
    let rad = sqrt(x*x + y*y + z*z)
    return (rad, acos(z/rad), atan2(y, x))
}

/*box
    (lon, lat, alt) --> (X, Y, X)
 */
func cameraPole2Cart(rad:Double, _ inc:Double, _ azi:Double) -> (Double, Double, Double) {
    return (rad * sin(inc) * cos(azi), rad * sin(inc) * sin(azi), rad * cos(inc))
}

extension SCNVector3 {
    public init(_ t: (Double, Double, Double)) {
        x = CGFloat(t.0)
        y = CGFloat(t.1)
        z = CGFloat(t.2)
    }
}

