//
//  ViewController.swift
//  Geometries
//
//  Created by Gavin Eadie on 9/25/15.
//  Copyright © 2015 Gavin Eadie. All rights reserved.
//

import Cocoa
import SceneKit

class ViewController: NSViewController {

    let Rₑ:CGFloat = 6.378135e3                 // equatorial radius (polar radius = 6356.752 Kms)
    let PI:CGFloat = 3.141593e0                 // for now

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
        let sceneView = self.view as! SCNView
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true

    #if true            // read from "scn"

        if let scene = SCNScene.init(named: "com.ramsaycons.geometries.scn") {

            if let frameNode = scene.rootNode.childNodeWithName("frame", recursively: true) {

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
            }

//            let solarNode = SCNNode()
//            solarNode.name = "solar"
//            solarNode.light = SCNLight()
//            solarNode.light!.type = SCNLightTypeDirectional
//            solarNode.light!.color = NSColor.yellowColor()
//            solarNode.position = SCNVector3Make(100000, 0, 100000)
//            scene.rootNode.addChildNode(solarNode)

            sceneView.scene = scene

        }

    #else               // write to "scn"

        let scene = SCNScene()

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's surface -- a globe of ~Rₑ                                                               ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let globeGeom = SCNSphere(radius: Rₑ - 0.2)
        globeGeom.geodesic = false
        globeGeom.segmentCount = 90

        let globeNode = SCNNode(geometry:globeGeom)
        globeNode.name = "globe"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's lat/lon grid dots --                                                                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let gridsGeom = SCNGeometry.GridsMesh()
        gridsGeom.firstMaterial?.diffuse.contents = NSColor.blackColor()
        let gridsNode = SCNNode(geometry: gridsGeom)
        gridsNode.name = "grids"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's coastlines --                                                                            ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let coastGeom = SCNGeometry.CoastMesh()
        coastGeom.firstMaterial?.diffuse.contents = NSColor.blueColor()

        let coastNode = SCNNode(geometry: coastGeom)
        coastNode.name = "coast"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth -- contains "globe" + "grids" + "coast"                                                    ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let earthNode = SCNNode()
        earthNode.name = "earth"
        earthNode.addChildNode(globeNode)
        earthNode.addChildNode(gridsNode)
        earthNode.addChildNode(coastNode)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Frame -- contains "earth"                                                                       ╎
  ╎          rotated to +x: out; +y: right; +z "up"                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let frameNode = SCNNode()
        frameNode.name = "frame"
        frameNode.addChildNode(earthNode)
        frameNode.eulerAngles = SCNVector3(x: -PI/2.0, y: -PI/2.0, z: 0.0)      //

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ rootNode -- contains "frame"                                                                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        scene.rootNode.addChildNode(frameNode)

        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let documentsDirectory = paths.first as NSString? {
            let archivePath = documentsDirectory.stringByAppendingPathComponent("com.ramsaycons.geometries.scn")
            NSKeyedArchiver.archiveRootObject(scene, toFile: archivePath)
        }

        sceneView.scene = scene

    #endif

    }

    @IBAction func startAction(sender: NSButton) {

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