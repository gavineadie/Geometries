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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sceneView = self.view as! SCNView
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
    
//        let solarNode = SCNNode()
//        solarNode.light = SCNLight()
//        solarNode.light!.type = SCNLightTypeDirectional
//        solarNode.light!.color = NSColor.orangeColor()
//        solarNode.position = SCNVector3Make(0, 100000, 0)
//        scene.rootNode.addChildNode(solarNode)

        let globeGeom = SCNSphere(radius: 6200.0)
        globeGeom.geodesic = false
        globeGeom.segmentCount = 90
        let globeNode = SCNNode(geometry:globeGeom)
        scene.rootNode.addChildNode(globeNode)

//        let gridsGeom = SCNGeometry.GlobeMesh()
//        gridsGeom.firstMaterial?.diffuse.contents = NSColor.blackColor()
//        let gridsNode = SCNNode(geometry: gridsGeom)
//        scene.rootNode.addChildNode(gridsNode)

        let coastGeom = SCNGeometry.CoastMesh()
        coastGeom.firstMaterial?.diffuse.contents = NSColor.blueColor()
        let coastNode = SCNNode(geometry: coastGeom)
        scene.rootNode.addChildNode(coastNode)

        let camera = SCNCamera()
        camera.xFov = 10.0
        camera.yFov = 10.0
        camera.zFar = 87000.0
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 50000, y: 50000, z: 50000)
        cameraNode.constraints = [SCNLookAtConstraint(target: globeNode)]
        
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.scene = scene
    }

    override var representedObject: AnyObject? {
        didSet {

        }
    }

}