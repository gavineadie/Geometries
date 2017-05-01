/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneConstruction.swift                                                               Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Mar12/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position

import SceneKit
import SatKit

// MARK: - Scene construction functions ..

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ "construct(scene:)"                                                                              ┃
  ┃                                                                                                  ┃
  ┃  .. sets some properties on the window's NSView (SceneView) including an overlayed SpriteKit     ┃
  ┃     placard which will display data and take hits.                                               ┃
  ┃                                                                                                  ┃
  ┃  .. gets the rootNode in that SceneView ("total") and attaches various other nodes:              ┃
  ┃     "frame" is a comes from the SceneKit file "com.ramsaycons.geometries.scn" and represents     ┃
  ┃             the inertial frame and it never directly transformed. It contains the "earth" node   ┃
  ┃             which is composed of a solid sphere ("globe"), graticule marks ("grids'), and the    ┃
  ┃             geographic coastlines, lakes , rivers, etc ("coast").                                ┃
  ┃                                                                                                  ┃
  ┃                              +--------------------------------------------------------------+    ┃
  ┃ SCNView.scene.rootNode       |                              "com.ramsaycons.geometries.scn" |    ┃
  ┃     == Node("total") ---+----|  Node("frame") --------+                                     |    ┃
  ┃                         |    |                        |                                     |    ┃
  ┃                         |    |                        +-- Node("earth") --+                 |    ┃
  ┃                              |                        |                   +-- Node("globe") |    ┃
  ┃                              |                        |                   +-- Node("grids") |    ┃
  ┃                              |                        |                   +-- Node("coast") |    ┃
  ┃                              +------------------------|-------------------------------------+    ┃
  ┃                                                                                                  ┃
  ┃             "construct(scene:)" adds nodes programmatically to represent other objects; It adds  ┃
  ┃             the light of the sun ("solar"), rotating once a year in inertial coordinates to the  ┃
  ┃             "frame", and the observer ("obsvr") to the "earth".                                  ┃
  ┃                                                                                                  ┃
  ┃             "construct(scene:)" also adds a 'double node' to represent to external viewer; a     ┃
  ┃             node at a fixed distant radius ("orbit"), with a camera ("camra") pointing to the    ┃
  ┃             the frame center.                                                                    ┃
  ┃                                                                                                  ┃
  ┃                         |                                                                        ┃
  ┃                         |                                                                        ┃
  ┃                         +-- Node("orbit") --+        +-- Node("spots")   +-- Node("obsvr")       ┃
  ┃                                             |        |                                           ┃
  ┃                                             |        +-- Node("light"+"solar")                   ┃
  ┃                                             |                                                    ┃
  ┃                                             +-- Node("camra")                                    ┃
  ┃                                                                                                  ┃
  ┃         Satellites also moving in the inertial frame but they are not added to the scene         ┃
  ┃         by this "construct(scene:)".                                                             ┃
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func construct(scene totalView: SceneView) {
    print("SceneConstruction.construct()")

    totalView.scene = SCNScene()
    totalView.backgroundColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.5, alpha: 1)

//  if let overlay = OverlayScene(fileNamed:"OverlayScene") { totalView.overlaySKScene = overlay }
//  totalView.overlaySKScene = constructSpriteView()

    guard let totalNode = totalView.scene?.rootNode,
          let frameScene = SCNScene(named: "com.ramsaycons.frame.scn"),
          let frameNode = frameScene.rootNode.childNode(withName: "frame", recursively: true),
          let earthNode = frameNode.childNode(withName: "earth", recursively: true) else { return }
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ by here we have "frameNode" and "earthNode" ..                                                   ╎
  ╎ .. next, label "frameNode" as "frame"                                                            ╎
  ╎ .. and make "earthNode" a subnode of "frameNode"                                                 ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    totalNode.name = "total"
    totalNode <<< frameNode                     // "total << "frame"
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ get the observer's position ..                                                                   ╎
  ╎ .. and attach "obsvrNode" to "earthNode"                                                         ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let obsCelestial = geo2eci(julianDays:-1.0,
                               geodetic: Vector(AnnArborLatitude, AnnArborLongitude, AnnArborAltitude))
    addObserver(earthNode, at:(obsCelestial.x, obsCelestial.y, obsCelestial.z))
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ rotate "earthNode" for time of day                                                               ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    earthNode.eulerAngles.z += CGFloat(zeroMeanSiderealTime(julianDaysNow()) * deg2rad)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ .. and attach "camraNode" to "totalNode" and "lightNode" to "earthNode"                          ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    addViewCamera(totalNode)
    addSolarLight(frameNode)

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ attach the camera a long way from the center of a (non-rendering node) and pointed at (0, 0, 0)  │
  │ with a viewpoint initially on x-axis at 120,000Km with north (z-axis) up                         │
  │                                                      http://stackoverflow.com/questions/25654772 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addViewCamera(_ parentNode: SCNNode) {
    print("               ...addViewCamera()")

    let orbitNode = SCNNode()                           // non-rendering node, holds the camera
    orbitNode.name = "orbit"

    let camera = SCNCamera()                            // create a camera
    let cameraRange = 120_000.0
    camera.xFov = 800_000.0 / cameraRange
    camera.yFov = 800_000.0 / cameraRange

    camera.automaticallyAdjustsZRange = true

    let cameraNode = SCNNode()
    cameraNode.name = "camra"
    cameraNode.camera = camera
    cameraNode.position = SCNVector3(x: 0, y: 0, z: CGFloat(cameraRange))

    let cameraConstraint = SCNLookAtConstraint(target: parentNode)
    cameraConstraint.isGimbalLockEnabled = true
    cameraNode.constraints = [cameraConstraint]

    orbitNode <<< cameraNode                            //            "orbit" << "camra"
    parentNode <<< orbitNode                            // "total" << "orbit"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addSolarLight(_ parentNode: SCNNode) {
    print("               ...addSolarLight()")
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let sunLight = SCNLight()
    sunLight.type = SCNLight.LightType.directional      // make a directional light
    sunLight.castsShadow = true

    let lightNode = SCNNode()
    lightNode.name = "light"
    lightNode.light = sunLight

    parentNode <<< lightNode                            //           "frame" << "light"
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let solarNode = SCNNode()                           // position of sun in (x,y,z)
    solarNode.name = "solar"

    let sunVector = solarCel(julianDays: julianDaysNow())
    solarNode.position = SCNVector3((-sunVector.x, -sunVector.y, -sunVector.z))

    let solarConstraint = SCNLookAtConstraint(target: solarNode)
    lightNode.constraints = [solarConstraint]           // keep the light coming from the sun

    parentNode <<< solarNode
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the x-axis (points at vernal equinox)                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addMarkerSpot(_ parentNode: SCNNode, color: NSColor, at: (Double, Double, Double)) {
    print("               ...addMarkerSpot()")

    let spotsGeom = SCNSphere(radius: 100.0)
    spotsGeom.isGeodesic = true
    spotsGeom.segmentCount = 6
    spotsGeom.firstMaterial?.diffuse.contents = color

    let spotsNode = SCNNode(geometry:spotsGeom)
    spotsNode.name = "spots"
    spotsNode.position = SCNVector3(at)

    parentNode <<< spotsNode                            //           "frame" << "spots"
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
    viewrNode.position = SCNVector3(at)

    parentNode <<< viewrNode                            //           "frame" << "viewr"
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ...
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func construct(orbTickRange: CountableClosedRange<Int>, orbTickDelta: Int) -> SCNNode {
    print("               ...construct.ticks()")

    let trailNode = SCNNode()
    trailNode.name = "trail"

    for _ in 0...orbTickRange.count {
        let dottyGeom = SCNSphere(radius: 10.0)         //
        dottyGeom.isGeodesic = true
        dottyGeom.segmentCount = 6
        dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)  // NSColor.white (!!CPU!!)
        dottyGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 1.0, green: 1, blue: 1, alpha: 1)

        let dottyNode = SCNNode(geometry: dottyGeom)
        dottyNode.position = SCNVector3((0.0, 0.0, 0.0))

        trailNode <<< dottyNode                         //                      "trail" << "dotty"
    }

    print("               ... \(trailNode.childNodes.count) ticks added")
    return trailNode

}

func createTrail(_ geometry: SCNGeometry) -> SCNParticleSystem {

    let trail = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil)!

    trail.emitterShape = geometry

    return trail
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (X, Y, X) --> (rad, inc, azi)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cart2Pole(_ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double) {
    let rad = sqrt(x*x + y*y + z*z)
    return (rad, acos(z/rad), atan2(y, x))
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (lon, lat, alt) --> (X, Y, X)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func pole2Cart(_ rad: Double, _ inc: Double, _ azi: Double) -> (Double, Double, Double) {
    return (rad * sin(inc) * cos(azi), rad * sin(inc) * sin(azi), rad * cos(inc))
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ reads a binary file (x,y,z), (x,y,z), (x,y,z), (x,y,z), .. and makes a SceneKit object ..        │
  │                                                          .. trailMesh(from: "/tmp/coast.vector") │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func trailMesh(from filePath: String) -> SCNGeometry? {

    if let dataContent = try? Data.init(contentsOf: URL(fileURLWithPath: filePath)) {
        let vectorCount = (dataContent.count) / 12           // count of vertices (two per line)

        let vertexSource = SCNGeometrySource(data: dataContent,
                                             semantic: SCNGeometrySource.Semantic.vertex,
                                             vectorCount: vectorCount,
                                             usesFloatComponents: true, componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0, dataStride: 12)

        let element = SCNGeometryElement(data: nil, primitiveType: .line, primitiveCount: vectorCount,
                                         bytesPerIndex: MemoryLayout<Int>.size)

        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    else {
        print("CoastMesh file missing")
        return nil
    }
}

import SpriteKit

func constructSpriteView() -> OverlayScene {

    let overlay = OverlayScene(size: CGSize(width: 600, height: 600))

    let baseNode = SKNode()
    baseNode.name = "BASE"
    overlay.addChild(baseNode)

    let rectNodeA = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeA.position = CGPoint(x: 50, y: 50)
    rectNodeA.name = "BotL"
    overlay.addChild(rectNodeA)

    let rectNodeB = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeB.position = CGPoint(x: 550, y: 50)
    rectNodeB.name = "BotR"
    overlay.addChild(rectNodeB)

    let rectNodeC = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeC.position = CGPoint(x: 50, y: 550)
    rectNodeC.name = "TopL"
    overlay.addChild(rectNodeC)

    let rectNodeD = SKSpriteNode(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), size: CGSize(width: 80, height: 80))
    rectNodeD.position = CGPoint(x: 550, y: 550)
    rectNodeD.name = "TopR"
    overlay.addChild(rectNodeD)

    let word = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
    word.position = CGPoint(x: 300, y: 10)
    word.name = "WORD"
    word.text = "Geometries"
    baseNode.addChild(word)

    return overlay
}
