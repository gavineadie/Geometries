/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ViewController.swift                                                                  Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Cocoa
import SceneKit
import SpriteKit

import SatKit

let  AnnArborLatitude = +42.2755
let AnnArborLongitude = -83.7521
let  AnnArborAltitude =   0.1

extension SCNVector3 {
    public init(_ t: (Double, Double, Double)) {
        x = CGFloat(t.0)
        y = CGFloat(t.1)
        z = CGFloat(t.2)
    }
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Dimensions (Kms):                                                                                ║
  ║             Earth Radius:   6,378                                                                ║
  ║     Geostationary Radius:  42,164                                                                ║
  ║      Camera Point Radius: 120,000                                                                ║
  ║        Moon Orbit Radius: 385,000                                                                ║
  ║                                                                                                  ║
  ║     •---------•---------•---------•---------•---------•---------•---------•---------•---------•  ║
  ║    120       100       80        60        40        20         0       -20       -40       -60  ║
  ║     0864208642086420864208642086420864208642086420864208642086420864208642086420864208642086420  ║
  ║     C                   N                  |                 |EEEEE|                          F  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

let Rₑ:CGFloat = 6.378135e3                 // equatorial radius (polar radius = 6356.752 Kms)
let π:CGFloat = 3.1415926e0                 // for now

class ViewController: NSViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var totalView: SceneView!

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ "viewDidLoad" (10.10+), called once,                                                             ┃
  ┃  .. sets some properties on the window's NSView (SceneView) including an overlayed SpriteKit     ┃
  ┃     placard (which will display data).                                                           ┃
  ┃  .. gets the rootNode in that SceneView ("total") to which will be attached various other nodes: ┃
  ┃     "frame" is a top node from SceneKit file "com.ramsaycons.geometries.scn"; it represents the  ┃
  ┃         inertial frame and it never transformed; it contains some nodes which will be animated.  ┃
  ┃     "earth" -- will rotate once a day                                                            ┃
  ┃  .. adds the following constructed nodes:                                                        ┃
  ┃     "light" -- the light of the sun -- will rotates once a year                                  ┃
  ┃     "spots" -- various other objects -- markers, satellites, etc                                 ┃
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController.viewDidLoad()")

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  │                              +--------------------------------------------------------------+    │
  │                              |                              "com.ramsaycons.geometries.scn" |    │
  │                          +-- |  Node("frame") --------+                                     |    │
  │                          |   |                        |                                     |    │
  │                          |   |                        +-- Node("earth") --+                 |    │
  │ SCNView.scene.rootNode   |   |                        |                   +-- Node("globe") |    │
  │       == Node("total") --+   |                        |                   +-- Node("grids") |    │
  │                          |   |                        |                   +-- Node("coast") |    │
  │                          |   +------------------------|-------------------------------------+    │
  │                          |                            |                   |                      │
  │                          +-- Node("orbit") --+        +-- Node("spots")   +-- Node("viewr")      │
  │                                              |        |                                          │
  │                                              |        +-- Node("light"+"solar")                  │
  │                                              |                                                   │
  │                                              +-- Node("camra")                                   │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

        totalView.scene = SCNScene()
        totalView.backgroundColor = NSColor.blue
        totalView.autoenablesDefaultLighting = true
        totalView.showsStatistics = true

        if let overlay = OverlayScene(fileNamed:"OverlayScene") { totalView.overlaySKScene = overlay }

        guard let totalNode = totalView.scene?.rootNode,
              let frameScene = SCNScene(named: "com.ramsaycons.frame.scn"),
              let frameNode = frameScene.rootNode.childNode(withName: "frame",
                                                            recursively: true),
              let earthNode = frameScene.rootNode.childNode(withName: "earth",
                                                            recursively: true) else { return }
        totalNode.name = "total"
        totalNode.addChildNode(frameNode)              // "total << "frame"

        let obsCelestial = geo2eciᴶᴰ(-1.0,
                                         geodetic: Vector(x: AnnArborLatitude,
                                                          y: AnnArborLongitude,
                                                          z: AnnArborAltitude))
        addViewer(earthNode, at:(obsCelestial.x, obsCelestial.y, obsCelestial.z))

        // rotate earth to time of day
        earthNode.eulerAngles.z += CGFloat(ZeroMeanSiderealTime(JulianDaysNow()) * deg2rad)

        addViewCamera(totalNode)

        addSolarLight(frameNode)

//      addMarkerSpot(frameNode, color: NSColor.magenta, at:(eRadiusKms * 1.05,0.0,0.0))

    }

    override func viewDidAppear() {
        super.viewDidAppear()
        print("ViewController.viewDidAppear()")

        totalView.delegate = self
        totalView.isPlaying = true
    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  SCNSceneRendererDelegate calls : sixty per second which is far too fast for our needs ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    var frameCount = 0
    var satelliteIterator = satellites.makeIterator()

    open func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        guard let earthNode = totalView.scene?.rootNode.childNode(withName: "earth",
                                                                  recursively: true) else { return }

//        if frameCount % 5 == 2 {                // twelve times a second, off the beat
//
//            if let frameNode = totalView.scene?.rootNode.childNode(withName: "frame",
//                                                                   recursively: true) {
//                if let (_, nextSatellite) = satelliteIterator.next() {
//                    addSatellite(frameNode, sat:nextSatellite)
//                }
//                else {
//                    satelliteIterator = satellites.makeIterator()
//                }
//
//            }
//
//        }

        if frameCount % 60 == 0 {               // once a second

            if let frameNode = totalView.scene?.rootNode.childNode(withName: "frame",
                                                                   recursively: true) {

                if let satellite = satellites["25544"] {
                    addSatellite(frameNode, sat:satellite)
                }

            }

        }

        if frameCount % 300 == 0 {              // every five seconds
            earthNode.eulerAngles.z = CGFloat(ZeroMeanSiderealTime(JulianDaysNow()) * deg2rad)
        }

        if frameCount % 3600 == 0 {             // once a minute
            if let solarNode = totalView.scene?.rootNode.childNode(withName: "solar",
                                                                   recursively: true) {

                let sunVector = solarCel(JulianDaysNow())
                solarNode.position = SCNVector3((-sunVector.x, -sunVector.y, -sunVector.z))
            }

            frameCount = 0
        }

        frameCount += 1

    }

    open func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {

    }

    open func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
    }

}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ attach the camera a long way from the center of a (non-rendering node) and pointed at (0, 0, 0)  ┃
  ┃ with a viewpoint initially on x-axis at 120,000Km with north (z-axis) up                         ┃
  ┃                                                      http://stackoverflow.com/questions/25654772 ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addViewCamera(_ parentNode:SCNNode) -> Void {

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

    orbitNode.addChildNode(cameraNode)                  //            "orbit" << "camra"
    parentNode.addChildNode(orbitNode)                  // "total" << "orbit"
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addSolarLight(_ parentNode:SCNNode) -> Void {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let sunLight = SCNLight()
    sunLight.type = SCNLight.LightType.directional      // make a directional light
    sunLight.castsShadow = true

    let lightNode = SCNNode()
    lightNode.name = "light"
    lightNode.light = sunLight

    parentNode.addChildNode(lightNode)                  //           "frame" << "light"

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ sunlight shines                                                                                  ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    let solarNode = SCNNode()                           // position of sun in (x,y,z)
    solarNode.name = "solar"

    let sunVector = solarCel(JulianDaysNow())
    solarNode.position = SCNVector3((-sunVector.x, -sunVector.y, -sunVector.z))

    let solarConstraint = SCNLookAtConstraint(target: solarNode)
    lightNode.constraints = [solarConstraint]           // keep the light coming from the sun

    parentNode.addChildNode(solarNode)
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ a spot on the x-axis (points at vernal equinox)                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addMarkerSpot(_ parentNode:SCNNode, color:NSColor, at:(Double, Double, Double)) -> Void {
    let spotsGeom = SCNSphere(radius: 100.0)
    spotsGeom.isGeodesic = true
    spotsGeom.segmentCount = 6
    spotsGeom.firstMaterial?.diffuse.contents = color
                                                                                                                                                                                                                                                                                                                                                   
    let spotsNode = SCNNode(geometry:spotsGeom)
    spotsNode.name = "spots"
    spotsNode.position = SCNVector3(at)

    parentNode.addChildNode(spotsNode)              //           "frame" << "spots"
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ a spot on the x-axis (points at vernal equinox)                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addViewer(_ parentNode:SCNNode, at:(Double, Double, Double)) -> Void {
    let viewrGeom = SCNSphere(radius: 50.0)
    viewrGeom.isGeodesic = true
    viewrGeom.segmentCount = 18
    viewrGeom.firstMaterial?.emission.contents = NSColor.green

    let viewrNode = SCNNode(geometry:viewrGeom)
    viewrNode.name = "obsvr"
    viewrNode.position = SCNVector3(at)

    parentNode.addChildNode(viewrNode)              //           "frame" << "viewr"
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ a satellite ..                                                                                   ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func addSatellite(_ parentNode:SCNNode, sat:Satellite) -> Void {

    if let trailNode = parentNode.childNode(withName: sat.catalogNum, recursively: true) {
        trailNode.removeFromParentNode()
    }

    let trailNode = SCNNode()
    trailNode.name = sat.catalogNum
    parentNode.addChildNode(trailNode)                  //           "frame" << "trail"

    let timeDelta = 15                                  // seconds between ticks on orbit path

//    SCNTransaction.begin()

    for index in -30...0 {
        let satCel:Vector = sat.positionᴱᴾ(sat.minsAfterEpoch + Double(timeDelta*index) / 60.0)

        let dottyGeom = SCNSphere(radius: 25.0)
        dottyGeom.isGeodesic = true
        dottyGeom.segmentCount = 6

//        if index == 0 {
//            dottyGeom.radius = 50
//            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)              // NSColor.red
//        }
//        else {
//            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)              // NSColor.white (!!CPU!!)
//        }

        let dottyNode = SCNNode(geometry:dottyGeom)
        dottyNode.position = SCNVector3((satCel.x,satCel.y,satCel.z))

        trailNode.addChildNode(dottyNode)               //        "frame" << "trail"
    }

//    SCNTransaction.commit()

}


func createTrail(_ geometry: SCNGeometry) -> SCNParticleSystem {

    let trail = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil)!

    trail.emitterShape = geometry

    return trail
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (X, Y, X) --> (rad, inc, azi)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraCart2Pole(_ x:Double, _ y:Double, _ z:Double) -> (Double, Double, Double) {
    let rad = sqrt(x*x + y*y + z*z)
    return (rad, acos(z/rad), atan2(y, x))
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ (lon, lat, alt) --> (X, Y, X)                                                                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func cameraPole2Cart(_ rad:Double, _ inc:Double, _ azi:Double) -> (Double, Double, Double) {
    return (rad * sin(inc) * cos(azi), rad * sin(inc) * sin(azi), rad * cos(inc))
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ reads a binary file (x,y,z),(x,y,z), (x,y,z),(x,y,z), .. and makes a SceneKit object ..          ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func trailMesh(_ sat:Satellite) -> SCNGeometry? {

    if let dataContent = try? Data.init(contentsOf: URL(fileURLWithPath: "/tmp/coast.vector")) {
        let vectorCount = (dataContent.count) / 12           // count of vertices (two per line)

        let vertexSource = SCNGeometrySource(data: dataContent,
                                             semantic: SCNGeometrySource.Semantic.vertex,
                                             vectorCount: vectorCount,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: 12)

        let element = SCNGeometryElement(data: nil,
                                         primitiveType: .line,
                                         primitiveCount: vectorCount,
                                         bytesPerIndex: MemoryLayout<Int>.size)

        return SCNGeometry(sources: [vertexSource], elements: [element])
    }
    else {
        print("CoastMesh file missing")
        return nil
    }
}
