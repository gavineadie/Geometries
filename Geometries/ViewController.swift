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
//      sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        
        let solarNode = SCNNode()
        solarNode.light = SCNLight()
        solarNode.light!.type = SCNLightTypeDirectional
        solarNode.light!.color = NSColor(white: 0.75, alpha: 1.0)
        solarNode.position = SCNVector3Make(0, 100000, 0)
        scene.rootNode.addChildNode(solarNode)

//        let globeNode = SCNNode(geometry: SCNSphere(radius: 6300.0))
//        scene.rootNode.addChildNode(globeNode)
        
        let coastNode = SCNNode(geometry: SCNGeometry.CoastMesh())
        scene.rootNode.addChildNode(coastNode)
        
        let camera = SCNCamera()
        camera.xFov = 15.0
        camera.yFov = 15.0
        camera.zFar = 50000.0
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: -50000, z: 0)
        cameraNode.constraints = [SCNLookAtConstraint(target: coastNode)]
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.scene = scene
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}