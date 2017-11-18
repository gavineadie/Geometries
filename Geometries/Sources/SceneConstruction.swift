/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneConstruction.swift                                                               Geometries ║
  ║ Created by Gavin Eadie on Mar12/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name

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
    if let gridsGeom = xxxxxMesh(resourceFile: "grids.vector") {
        gridsGeom.firstMaterial?.diffuse.contents = Color.gray
        gridsGeom.firstMaterial?.lightingModel = .constant

		let gridsNode = SCNNode(geometry: gridsGeom)
		gridsNode.name = "grids"
		earthNode <<< gridsNode
}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's coastline vectors -- build the "coast" node and add it to "earth" ..                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    if let coastGeom = xxxxxMesh(resourceFile: "coast.vector") {
        coastGeom.firstMaterial?.diffuse.contents = Color.blue
        coastGeom.firstMaterial?.lightingModel = .constant

        let coastNode = SCNNode(geometry: coastGeom)
        coastNode.name = "coast"
        earthNode <<< coastNode
    }

    return earthNode
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the surface where the observer is standing ..                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addObserver(_ parentNode: SCNNode, at: (Double, Double, Double)) {
    print("               ...addObserver()")

    let viewrGeom = SCNSphere(radius: 50.0)
    viewrGeom.isGeodesic = true
    viewrGeom.segmentCount = 18
    viewrGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0, green: 1.0, blue: 0, alpha: 1)
    viewrGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0, green: 1.0, blue: 0, alpha: 1)

    let viewrNode = SCNNode(geometry: viewrGeom)
    viewrNode.name = "obsvr"
    viewrNode.position = SCNVector3(at.0, at.1, at.2)

    parentNode <<< viewrNode                            //           "frame" << "viewr"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ attach the camera a long way from the center of a (non-rendering node) and pointed at (0, 0, 0)  │
  │ with a viewpoint initially on x-axis at 120,000Km with north (z-axis) up                         │
  │                                                      http://stackoverflow.com/questions/25654772 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
let cameraDistance = 120_000.0
let cameraBracket = 40_000.0

func addViewCamera(to node: SCNNode) {
    print("               ...addViewCamera()")

    let camera = SCNCamera()                            // create a camera
    let cameraRange = 120_000.0
    camera.xFov = 800_000.0 / cameraRange
    camera.yFov = 800_000.0 / cameraRange

    camera.zFar  = cameraDistance+cameraBracket         // z-Range brackets geo
    camera.zNear = cameraDistance-cameraBracket

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

    let sunVector = solarCel(julianDays: Date().julianDate)
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
	func addMarkerSpot(to node: SCNNode, color: Color, at: (Double, Double, Double)) {
		print("               ...addMarkerSpot()")

		let spotsGeom = SCNSphere(radius: 100.0)
		spotsGeom.isGeodesic = true
		spotsGeom.segmentCount = 6
		spotsGeom.firstMaterial?.diffuse.contents = color

		let spotsNode = SCNNode(geometry: spotsGeom)
		spotsNode.name = "spots"
		spotsNode.position = SCNVector3(at.0, at.1, at.2)

		node <<< spotsNode                            //           "frame" << "spots"
	}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ...                                                                                              │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func construct(orbTickRange: CountableClosedRange<Int>, orbTickDelta: Int) -> SCNNode {
    print("               ...construct.ticks()")

    let trailNode = SCNNode()
    trailNode.name = "trail"

    for _ in 0...orbTickRange.count {
        let dottyGeom = SCNSphere(radius: 10.0)         //
        dottyGeom.isGeodesic = true
        dottyGeom.segmentCount = 6
        dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1.0, green: 1, blue: 1, alpha: 1)  // Color.white (!!CPU!!)
        dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 1.0, green: 1, blue: 1, alpha: 1)

        let dottyNode = SCNNode(geometry: dottyGeom)
        dottyNode.position = SCNVector3(0.0, 0.0, 0.0)

        trailNode <<< dottyNode                         //                      "trail" << "dotty"
    }

    print("               ... \(trailNode.childNodes.count) ticks added")
    return trailNode
}

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
