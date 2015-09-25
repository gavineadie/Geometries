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
        
        let solarNode = SCNNode()
        solarNode.light = SCNLight()
        solarNode.light!.type = SCNLightTypeDirectional
        solarNode.light!.color = NSColor(white: 0.75, alpha: 1.0)
        solarNode.position = SCNVector3Make(0, 100000, 0)
        scene.rootNode.addChildNode(solarNode)

//        let globeMesh = SCNSphere(radius: 6500.0)
//        let globeNode = SCNNode(geometry: globeMesh)
//        scene.rootNode.addChildNode(globeNode)
        
        let coastMesh = SCNGeometry.CoastMesh();
        let coastNode = SCNNode(geometry: coastMesh)
        scene.rootNode.addChildNode(coastNode)
        
        let camera = SCNCamera()
        camera.xFov = 45.0
        camera.yFov = 45.0
        camera.zFar = -1000.0
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 25000)
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.scene = scene
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}