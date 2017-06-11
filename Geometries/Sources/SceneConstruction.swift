/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneConstruction.swift                                                               Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Mar12/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position
// swiftlint:disable file_length

import SceneKit
import SatKit

// MARK: - Scene construction functions ..

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  │                              +--------------------------------------------------------+          │
  │                              |                   -- Node("earth") --+                 |          │
  │                              |                                      +-- Node("globe") |          │
  │                              |                                      +-- Node("grids") |          │
  │                              |                                      +-- Node("coast") |          │
  │                              +--------------------------------------------------------+          │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

    func MakeEarth() -> SCNNode {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth -- contains "globe" + "grids" + "coast"                                                    ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let earthNode = SCNNode()
        earthNode.name = "earth"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's surface -- a globe of ~Rₑ                                                                ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let globeGeom = SCNSphere(radius: CGFloat(Rₑ - 10.0))
        globeGeom.isGeodesic = false
        globeGeom.segmentCount = 90

        let globeNode = SCNNode(geometry: globeGeom)
        globeNode.name = "globe"
        earthNode <<< globeNode

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's lat/lon grid dots -- build the "grids" node and add it to "earth" ..                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let gridsGeom = gridsMesh() {
            gridsGeom.firstMaterial?.diffuse.contents = Color.black

            let gridsNode = SCNNode(geometry: gridsGeom)
            gridsNode.name = "grids"
            earthNode <<< gridsNode
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's coastline vectors -- build the "coast" node and add it to "earth" ..                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let coastGeom = coastMesh() {
            coastGeom.firstMaterial?.diffuse.contents = Color.blue

            let coastNode = SCNNode(geometry: coastGeom)
            coastNode.name = "coast"
            earthNode <<< coastNode
        }

        return earthNode
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the x-axis (points at vernal equinox)                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func addObserver(_ parentNode: SCNNode, at: (Double, Double, Double)) {
        print("               ...addObserver()")

        let viewrGeom = SCNSphere(radius: 50.0)
        viewrGeom.isGeodesic = true
        viewrGeom.segmentCount = 18
        viewrGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0, green: 1.0, blue: 0, alpha: 1)
        viewrGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0, green: 1.0, blue: 0, alpha: 1)

        let viewrNode = SCNNode(geometry:viewrGeom)
        viewrNode.name = "obsvr"
        viewrNode.position = SCNVector3(at.0, at.1, at.2)

        parentNode <<< viewrNode                            //           "frame" << "viewr"
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ attach the camera a long way from the center of a (non-rendering node) and pointed at (0, 0, 0)  │
  │ with a viewpoint initially on x-axis at 120,000Km with north (z-axis) up                         │
  │                                                      http://stackoverflow.com/questions/25654772 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func addViewCamera(to node: SCNNode) {
        print("               ...addViewCamera()")

        let camera = SCNCamera()                            // create a camera
        let cameraRange = 120_000.0
        camera.xFov = 800_000.0 / cameraRange
        camera.yFov = 800_000.0 / cameraRange
        camera.automaticallyAdjustsZRange = true

        let cameraNode = SCNNode()
        cameraNode.name = "camra"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: CGFloat(Float(cameraRange)))

        let cameraConstraint = SCNLookAtConstraint(target: node)
        cameraConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [cameraConstraint]

        let viewrNode = SCNNode()                           // non-rendering node, holds the camera
        viewrNode.name = "viewr"

        viewrNode <<< cameraNode                            //            "viewr" << "camra"
        node <<< viewrNode                                  // "scene" << "viewr"
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
	func addSolarLight(to node: SCNNode) {
		print("               ...addSolarLight()")

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ put a node in the direction of the sun ..                                                        ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let solarNode = SCNNode()                           // position of sun in (x,y,z)
        solarNode.name = "solar"

        let sunVector = solarCel(julianDays: julianDaysNow())
        solarNode.position = SCNVector3(sunVector.x, sunVector.y, sunVector.z)

        node <<< solarNode                                  //           "frame" << "solar"
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ make a bright light ..                                                                           ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let sunLight = SCNLight()
        sunLight.type = SCNLight.LightType.directional      // make a directional light
        sunLight.castsShadow = true

        let lightNode = SCNNode()
        lightNode.name = "light"
        lightNode.light = sunLight
        lightNode.constraints = [SCNLookAtConstraint(target: node)]

        solarNode <<< lightNode                             //                      "solar" << "light"
	}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the x-axis (points at vernal equinox)                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
//func addMarkerSpot(to node: SCNNode, color: Color, at: (Double, Double, Double)) {
//    print("               ...addMarkerSpot()")
//
//    let spotsGeom = SCNSphere(radius: 100.0)
//    spotsGeom.isGeodesic = true
//    spotsGeom.segmentCount = 6
//    spotsGeom.firstMaterial?.diffuse.contents = color
//
//    let spotsNode = SCNNode(geometry:spotsGeom)
//    spotsNode.name = "spots"
//    spotsNode.position = SCNVector3(at.0, at.1, at.2)
//
//    parentNode <<< spotsNode                            //           "frame" << "spots"
//}
//
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ...
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

//func createTrail(_ geometry: SCNGeometry) -> SCNParticleSystem {
//
//    let trail = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil)!
//
//    trail.emitterShape = geometry
//
//    return trail
//}
//
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (X, Y, X) --> (rad, inc, azi)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
//func cart2Pole(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
//    let rad = sqrt(x*x + y*y + z*z)
//    return (rad, acos(z/rad), atan2(y, x))
//}
//
///*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
//  │ (lon, lat, alt) --> (X, Y, X)                                                                    │
//  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
//func pole2Cart(_ rad: Double, _ inc: Double, _ azi: Double) -> (Double, Double, Double) {
//    return (rad * sin(inc) * cos(azi), rad * sin(inc) * sin(azi), rad * cos(inc))
//}
//
//
//import SpriteKit
//
//func constructSpriteView() -> OverlayScene {
//
//    let overlay = OverlayScene(size: CGSize(width: 600, height: 600))
//
//    let baseNode = SKNode()
//    baseNode.name = "BASE"
//    overlay.addChild(baseNode)
//
//    let rectNodeA = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
//    rectNodeA.position = CGPoint(x: 50, y: 50)
//    rectNodeA.name = "BotL"
//    overlay.addChild(rectNodeA)
//
//    let rectNodeB = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
//    rectNodeB.position = CGPoint(x: 550, y: 50)
//    rectNodeB.name = "BotR"
//    overlay.addChild(rectNodeB)
//
//    let rectNodeC = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
//    rectNodeC.position = CGPoint(x: 50, y: 550)
//    rectNodeC.name = "TopL"
//    overlay.addChild(rectNodeC)
//
//    let rectNodeD = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
//    rectNodeD.position = CGPoint(x: 550, y: 550)
//    rectNodeD.name = "TopR"
//    overlay.addChild(rectNodeD)
//
//    let word = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
//    word.position = CGPoint(x: 300, y: 10)
//    word.name = "WORD"
//    word.text = "Geometries"
//    baseNode.addChild(word)
//
//    return overlay
//}
