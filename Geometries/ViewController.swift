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

    let eRadiusKms:CGFloat = 6378.135           // equatorial radius (polar radius = 6356.752 Kms)
    let PI:CGFloat = 3.14159                    // for now

    override func viewDidLoad() {
        super.viewDidLoad()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │          +-----------------------------------------------------------------------+               │
  │ SCNView -- SCNScene --+                          "com.ramsaycons.geometries.scn" |               │
  │          |            |                                                          |               │
  │          |            +-- rootNode --+                                           |               │
  │          |                           |                                           |               │
  │          |                           +-- SCNNode("frame") --+                    |               │
  │          |                           |                      |                    |               │
  │          |                           |                      +-- SCNNode("earth") |               │
  │          |                           |                      |                    |               │
  │          |                           |                      +-- SCNNode("coast") |               │
  │          +---------------------------|----------------------|--------------------+               │
  │                                      |                      |                                    │
  │                                      |                      +-- SCNNode("camra")                 │
  │                                      +-- SCNNode("solar")                                        │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        let sceneView = self.view as! SCNView
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true

    #if true

        if let scene = SCNScene.init(named: "com.ramsaycons.geometries.scn") {

            if let frameNode = scene.rootNode.childNodeWithName("Frame", recursively: true) {

                let spotsGeom = SCNSphere(radius: 100.0)
                spotsGeom.geodesic = false
                spotsGeom.segmentCount = 6
                let spotsNode = SCNNode(geometry:spotsGeom)
                spotsNode.position = SCNVector3Make(0, eRadiusKms * 1.1, 0)
                frameNode.addChildNode(spotsNode)

                let camera = SCNCamera()
                camera.xFov = 10.0
                camera.yFov = 10.0
                camera.zNear = 45000.0
                camera.zFar = 100000.0

                let cameraNode = SCNNode()
                cameraNode.name = "camera"
                cameraNode.camera = camera
                cameraNode.position = SCNVector3(x: 100000, y: 0, z: 0)
                cameraNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: PI/2.0)
                cameraNode.constraints = [SCNLookAtConstraint(target: frameNode)]
                frameNode.addChildNode(cameraNode)
            }

            sceneView.scene = scene

        }

    #else

        let scene = SCNScene()

        let globeGeom = SCNSphere(radius: eRadiusKms - 0.2)
        globeGeom.geodesic = false
        globeGeom.segmentCount = 90
        let globeNode = SCNNode(geometry:globeGeom)
        globeNode.name = "Earth"

//        let gridsGeom = SCNGeometry.GlobeMesh()
//        gridsGeom.firstMaterial?.diffuse.contents = NSColor.blackColor()
//        let gridsNode = SCNNode(geometry: gridsGeom)
//        scene.rootNode.addChildNode(gridsNode)

        let coastGeom = SCNGeometry.CoastMesh()
        coastGeom.firstMaterial?.diffuse.contents = NSColor.blueColor()
        let coastNode = SCNNode(geometry: coastGeom)
        coastNode.name = "Coast"

        let frameNode = SCNNode()
        frameNode.name = "Frame"
        frameNode.addChildNode(globeNode)
        frameNode.addChildNode(coastNode)
        frameNode.eulerAngles = SCNVector3(x: -PI/2.0, y: -PI/2.0, z: 0.0)

        scene.rootNode.addChildNode(frameNode)

        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let documentsDirectory = paths.first as NSString? {
            let archivePath = documentsDirectory.stringByAppendingPathComponent("com.ramsaycons.geometries.scn")
            NSKeyedArchiver.archiveRootObject(scene, toFile: archivePath)
        }

//        let solarNode = SCNNode()
//        solarNode.light = SCNLight()
//        solarNode.light!.type = SCNLightTypeDirectional
//        solarNode.light!.color = NSColor.orangeColor()
//        solarNode.position = SCNVector3Make(0, 100000, 0)
//        scene.rootNode.addChildNode(solarNode)

        sceneView.scene = scene

    #endif

    }

    override var representedObject: AnyObject? {
        didSet {

        }
    }

}
