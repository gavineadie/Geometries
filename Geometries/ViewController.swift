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

class ViewController: NSViewController {

    let Rₑ:CGFloat = 6.378135e3                 // equatorial radius (polar radius = 6356.752 Kms)
    let PI:CGFloat = 3.141593e0                 // for now

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

        scene = SCNScene(named: "com.ramsaycons.geometries.scn")

        if let frameNode = scene!.rootNode.childNodeWithName("frame", recursively: true) {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ a spot on the x-axis (points at vernal equinox)                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let spotsGeom = SCNSphere(radius: 100.0)
            spotsGeom.geodesic = false
            spotsGeom.segmentCount = 6

            let spotsNode = SCNNode(geometry:spotsGeom)
            spotsNode.name = "spots"
            spotsNode.position = SCNVector3Make(Rₑ * 1.1, 0, 0)
          //spotsNode.pivot = SCNMatrix4MakeTranslation(Rₑ * 1.1 * 2, 0, 0)
            frameNode.addChildNode(spotsNode)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ viewpoint initially on x-axis at 100,000Km with north (z-axis) up                                ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let camera = SCNCamera()
            camera.xFov = 10.0
            camera.yFov = 10.0
            camera.zNear = 45000.0
            camera.zFar = 150000.0

            let cameraNode = SCNNode()
            cameraNode.name = "camra"
            cameraNode.camera = camera
            cameraNode.position = SCNVector3(x: 100000, y: 0, z: 0)
            cameraNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: PI/2.0)
            cameraNode.constraints = [SCNLookAtConstraint(target: frameNode)]
            frameNode.addChildNode(cameraNode)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines from +y (for now)                                                                ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let sunshine = SCNLight()
            sunshine.type = SCNLightTypeOmni

            let solarNode = SCNNode()
            solarNode.name = "solar"
            solarNode.light = sunshine
            solarNode.position = SCNVector3Make(100000, 100000, 0)
            frameNode.addChildNode(solarNode)
            
        }

        let sceneView = self.view as! SceneView
        sceneView.scene = scene
        sceneView.backgroundColor = NSColor.blackColor()
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true
        sceneView.showsStatistics = true

        sceneView.overlaySKScene = OverlayScene(fileNamed:"OverlayScene")

        let action = SCNAction.rotateByAngle(PI*2.0, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 10.0)
        let earthNode = scene.rootNode.childNodeWithName("earth", recursively: true)
        earthNode!.runAction(action)

    }

    @IBAction func spinAction(sender: NSButton) {

        print("spinAction")

        let sceneView = self.view as! SCNView
        let scene = sceneView.scene

        if let earthNode = scene!.rootNode.childNodeWithName("earth", recursively: true) {

            let action = SCNAction.rotateByAngle(PI*2.0, aroundAxis: SCNVector3(x: 0, y: 0.3, z: 1), duration: 10.0)
            earthNode.runAction(action)

        }
        else {
            print("node 'earth' not found in model")
        }

    }

}