/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ViewController.swift                                                                  Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable file_length

import SceneKit
import SatKit

let  AnnArborLatitude = +42.2755
let AnnArborLongitude = -83.7521
let  AnnArborAltitude =   0.1

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Dimensions (Kms):                                                                                ┃
  ┃             Earth Radius:   6,378                                                                ┃
  ┃     Geostationary Radius:  42,164                                                                ┃
  ┃      Camera Point Radius: 120,000                                                                ┃
  ┃        Moon Orbit Radius: 385,000                                                                ┃
  ┃                                                                                                  ┃
  ┃     •---------•---------•---------•---------•---------•---------•---------•---------•---------•  ┃
  ┃    120       100       80        60        40        20         0       -20       -40       -60  ┃
  ┃     0864208642086420864208642086420864208642086420864208642086420864208642086420864208642086420  ┃
  ┃     C                   N                  |                 |EEEEE|                          F  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

let orbTickDelta = 15                       // seconds between ticks on orbit path
let orbTickRange = -10...330                //

class ViewController: NSViewController, SCNSceneRendererDelegate {

    var sceneNode = SCNNode()               // set in "viewDidLoad()" after scene constructed ..
    var frameNode = SCNNode()
    var earthNode = SCNNode()
    var solarNode = SCNNode()
    var trailNode: SCNNode!
    var tickNodes: [SCNNode]!

    @IBOutlet weak var totalView: SceneView!

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidLoad" (10.10+), called once,                                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController.viewDidLoad()")

        totalView.backgroundColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.5, alpha: 1)
        totalView.scene = SCNScene()

        sceneNode = (totalView.scene?.rootNode)!
        sceneNode.name = "scene"

        construct(scene: totalView.scene!)

        NotificationCenter.default.addObserver(self, selector: #selector(self.ApplicationAwake),
                                               name: .NSApplicationWillBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.ApplicationSleep),
                                               name: .NSApplicationWillResignActive, object: nil)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidAppear" (10.10+), called once,                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidAppear() {
        super.viewDidAppear()
        print("ViewController.viewDidAppear()")

        totalView.delegate = self                   // renderer won't start running till now ..
        totalView.isPlaying = true
    }

// MARK: - Scene construction functions ..

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ "construct(scene:)"                                                                              ┃
  ┃                                                                                                  ┃
  ┃  .. sets some properties on the window's NSView (SceneView) including an overlayed SpriteKit     ┃
  ┃     placard which will display data and take hits.                                               ┃
  ┃                                                                                                  ┃
  ┃  .. gets the rootNode in that SceneView ("scene") and attaches various other nodes:              ┃
  ┃     "frame" is a comes from the SceneKit file "com.ramsaycons.geometries.scn" and represents     ┃
  ┃             the inertial frame and it never directly transformed. It contains the "earth" node   ┃
  ┃             which is composed of a solid sphere ("globe"), graticule marks ("grids'), and the    ┃
  ┃             geographic coastlines, lakes , rivers, etc ("coast").                                ┃
  ┃                                                                                                  ┃
  ┃                              +--------------------------------------------------------------+    ┃
  ┃ SCNView.scene.rootNode       |                              "com.ramsaycons.geometries.scn" |    ┃
  ┃     == Node("scene") ---+----|  Node("frame") --------+                                     |    ┃
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
  ┃             node at a fixed distant radius ("viewr"), with a camera ("camra") pointing to the    ┃
  ┃             the frame center.                                                                    ┃
  ┃                                                                                                  ┃
  ┃                         |                             |                   |                      ┃
  ┃                         |                             |                   |                      ┃
  ┃                         +-- Node("viewr") --+         +-- Node("spots")   +-- Node("obsvr")      ┃
  ┃                                             |         |                                          ┃
  ┃                                             |         +-- Node("solar")                          ┃
  ┃                                             |                                                    ┃
  ┃                                             +-- Node("camra")                                    ┃
  ┃                                                                                                  ┃
  ┃         Satellites also moving in the inertial frame but they are not added to the scene         ┃
  ┃         by this "construct(scene:)".                                                             ┃
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  ╎ contruct the "frame" node ("earth", ("globe", "grids", coast")) ..                               ╎
  ╎                                                       .. and attach it to the given "scene" node ╎
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func construct(scene: SCNScene) {
        print("SceneConstruction.construct()")

        let sceneNode = scene.rootNode                      // sceneNode
        sceneNode.name = "scene"

        let frameNode = SCNNode()
        frameNode.name = "frame"                            // frameNode
        sceneNode <<< frameNode

        earthNode = MakeEarth()                             // earthNode
        frameNode <<< earthNode
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ get the observer's position ..                                                                   ╎
  ╎ .. and attach an "obsvr" node to node "earth"                                                    ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let obsCelestial = geo2eci(julianDays:-1.0,
                                   geodetic: Vector(AnnArborLatitude, AnnArborLongitude, AnnArborAltitude))
        addObserver(earthNode, at:(obsCelestial.x, obsCelestial.y, obsCelestial.z))
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ rotate "earthNode" for time of day                                                               ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        earthNode.eulerAngles.z += CGFloat(zeroMeanSiderealTime(julianDaysNow()) * deg2rad)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ .. and attach "camra" node to "scene" and "light" node to "earth" ..                             ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        addViewCamera(scene: scene)
        addSolarLight(to: frameNode)

        frameNode.eulerAngles = SCNVector3(x: -CGFloat.π/2.0, y: -CGFloat.π/2.0, z: 0.0)    //
        frameNode.scale = SCNVector3(1.0, 1.0, 6356.752/6378.135)             // flatten the earth slightly !
    }

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
        if let gridsGeom = GridsMesh() {
            gridsGeom.firstMaterial?.diffuse.contents = Color.black

            let gridsNode = SCNNode(geometry: gridsGeom)
            gridsNode.name = "grids"
            earthNode <<< gridsNode
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's coastline vectors -- build the "coast" node and add it to "earth" ..                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if let coastGeom = CoastMesh() {
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
    func addViewCamera(scene: SCNScene) {
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

        let cameraConstraint = SCNLookAtConstraint(target: scene.rootNode)
        cameraConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [cameraConstraint]

        let viewrNode = SCNNode()                           // non-rendering node, holds the camera
        viewrNode.name = "viewr"

        viewrNode <<< cameraNode                            //            "viewr" << "camra"
        scene.rootNode <<< viewrNode                        // "scene" << "viewr"
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
        sunLight.type = SCNLight.LightType.directional  // make a directional light
        sunLight.castsShadow = true

        let lightNode = SCNNode()
        lightNode.name = "light"
        lightNode.light = sunLight
        lightNode.constraints = [SCNLookAtConstraint(target: node)]

        solarNode <<< lightNode                             //                      "solar" << "light"
	}

struct Vertex {
    var x: Float
    var y: Float
    var z: Float

    init(_ px: Float, _ py: Float, _ pz: Float) {
        x = px
        y = py
        z = pz
    }
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ reads a binary file (x,y,z),(x,y,z), (x,y,z),(x,y,z), .. and makes a SceneKit object ..          ┃
  ┃         /tmp/coast.vector ... coastline polygons                                                 ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
	func CoastMesh() -> SCNGeometry? {
		let mainBundle = Bundle.main
		let sceneURL = mainBundle.url(forResource: "coast", withExtension: "vector")

		guard let dataContent = try? Data.init(contentsOf: sceneURL!) else {
			print("CoastMesh file missing")
			return nil
		}

		let vectorCount = (dataContent.count) / 12           // count of vertices (two per line)
		print("CoastMesh(vectorCount: \(vectorCount))")

		let vertexSource = SCNGeometrySource(data: dataContent,
											 semantic: SCNGeometrySource.Semantic.vertex,
											 vectorCount: vectorCount,
											 usesFloatComponents: true,
											 componentsPerVector: 3,
											 bytesPerComponent: MemoryLayout<Float>.size,
											 dataOffset: 0, dataStride: MemoryLayout<Vertex>.size)

		let element = SCNGeometryElement(data: nil,
										 primitiveType: .line,
										 primitiveCount: vectorCount,
										 bytesPerIndex: MemoryLayout<Int>.size)

		return SCNGeometry(sources: [vertexSource], elements: [element])
	}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ reads a binary file (x,y,z),(x,y,z), (x,y,z),(x,y,z), .. and makes a SceneKit object ..          ┃
  ┃         /tmp/coast.vector ... coastline polygons                                                 ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
	func GridsMesh() -> SCNGeometry? {
		let mainBundle = Bundle.main
		let sceneURL = mainBundle.url(forResource: "grids", withExtension: "vector")

		guard let dataContent = try? Data.init(contentsOf: sceneURL!) else {
			print("CoastMesh file missing")
			return nil
		}

		let vectorCount = (dataContent.count) / 12           // count of vertices (two per line)
		print("CoastMesh(vectorCount: \(vectorCount))")

		let vertexSource = SCNGeometrySource(data: dataContent,
											 semantic: SCNGeometrySource.Semantic.vertex,
											 vectorCount: vectorCount,
											 usesFloatComponents: true,
											 componentsPerVector: 3,
											 bytesPerComponent: MemoryLayout<Float>.size,
											 dataOffset: 0, dataStride: MemoryLayout<Vertex>.size)

		let element = SCNGeometryElement(data: nil,
										 primitiveType: .line,
										 primitiveCount: vectorCount,
										 bytesPerIndex: MemoryLayout<Int>.size)

		return SCNGeometry(sources: [vertexSource], elements: [element])
	}

	// MARK: - AWAKE/SLEEP notification callbacks ..

    func ApplicationAwake(notification: Notification) {

        print(notification.name)
        totalView.isPlaying = true
//      totalView.scene?.isPaused = false

    }

    func ApplicationSleep(notification: Notification) {

        print(notification.name)
        totalView.isPlaying = false
//      totalView.scene?.isPaused = true

    }

// MARK: - Rendering callback delegate ..

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  SCNSceneRendererDelegate calls : sixty per second which is far too fast for our needs ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

    var frameCount = 0

    open func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ guard for satellites available ..                                                                ╎
  ╎                                                 .. once a second: reposition the satellite trail ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        guard let visualCollection = satelliteStore["visual.txt"],
                  visualCollection.count > 0 else { return }

        if frameCount % 10 == 0 {                   // once a second

            if let satellite = visualCollection["25544"] {

                if frameNode.childNode(withName: "25544", recursively: true) == nil {
                    trailNode = satellite.trailNode; frameNode <<< trailNode
                }

                tickNodes = trailNode.childNodes

                for index in orbTickRange {
                    let satCel = satellite.position(minsAfterEpoch: satellite.minsAfterEpoch +
                                                                    Double(orbTickDelta*index) / 60.0)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ is satellite in sunlight ?                                                                       ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let horizonAngle = acos(eRadiusKms/magnitude(satCel)) * rad2deg
                    let sunCel =  solarCel(julianDays: julianDaysNow())
                    let eclipseDepth = (horizonAngle + 90.0) - separation(satCel, sunCel)

                    let tickIndex = index - orbTickRange.lowerBound
                    tickNodes[tickIndex].position = SCNVector3(satCel.x, satCel.y, satCel.z)

                    if let tickGeom = tickNodes[tickIndex].geometry as? SCNSphere {
                        if index == 0 {
                            tickGeom.radius = 50
                            tickGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)       // NSColor.red
                            tickGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)        // NSColor.red
                        } else {
                            tickGeom.radius = eclipseDepth < 0 ? 10.0 : 25.0
                        }
                    }

                }
            }
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ if the earth exists (the construction succeeded) ..                                              ╎
  ╎                                                               .. once a minute: rotate the earth ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if frameCount % 3600 == 0 {                 // every a minute
            earthNode.eulerAngles.z = CGFloat(zeroMeanSiderealTime(julianDaysNow()) * deg2rad)
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ if the sun exists (the construction succeeded) ..                                                ╎
  ╎                                                          .. once every ten minutes: move the sun ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if frameCount % 36000 == 0 {                // once every ten minutes
            let sunVector = solarCel(julianDays: julianDaysNow())
            solarNode.position = SCNVector3(-sunVector.x, -sunVector.y, -sunVector.z)

            frameCount = 0
        }

        frameCount += 1
    }

//    open func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
//
//    }
//
//    open func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
//
//    }

}
