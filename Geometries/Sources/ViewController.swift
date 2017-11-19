/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ViewController.swift                                                                  Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable variable_name

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

var fakeClock = FakeClock.sharedInstance

class ViewController: NSViewController, SCNSceneRendererDelegate {

    var sceneNode = SCNNode()               // set in "viewDidLoad()" after scene constructed ..
    var frameNode = SCNNode()
    var earthNode = SCNNode()
    var solarNode = SCNNode()
    var trailNode: SCNNode!
    var tickNodes: [SCNNode]!

    @IBOutlet weak var sceneView: SceneView!

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidLoad" (10.10+), called once,                                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController.viewDidLoad()")

        fakeClock.reset()
        fakeClock.dateFactor = 0.0

        sceneView.backgroundColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.5, alpha: 1)
        sceneView.scene = SCNScene()

        sceneView.overlaySKScene = constructSpriteView()

        sceneNode = (sceneView.scene?.rootNode)!
        sceneNode.name = "scene"

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃                                                                                                  ┃
  ┃  .. gets the rootNode in that SceneView ("scene") and attaches various other nodes:              ┃
  ┃     "frame" is a comes from the SceneKit file "com.ramsaycons.geometries.scn" and represents     ┃
  ┃             the inertial frame and it never directly transformed. It contains the "earth" node   ┃
  ┃             which is composed of a solid sphere ("globe"), graticule marks ("grids'), and the    ┃
  ┃             geographic coastlines, lakes , rivers, etc ("coast").                                ┃
  ┃                                                                                                  ┃
  ┃                              +--------------------------------------------------------------+    ┃
  ┃ SCNView.scene.rootNode       |                                                              |    ┃
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
  ┃                                             |         +-- Node("solar"+"light")                  ┃
  ┃                                             |                                                    ┃
  ┃                                             +-- Node("camra")                                    ┃
  ┃                                                                                                  ┃
  ┃         Satellites also moving in the inertial frame but they are not added to the scene         ┃
  ┃         by this "construct(scene:)".                                                             ┃
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  ╎ contruct the "frame" node ("earth", ("globe", "grids", coast")) ..                               ╎
  ╎                                                             .. and attach it to the "scene" node ╎
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        frameNode.name = "frame"                            // frameNode
        sceneNode <<< frameNode

        earthNode = MakeEarth()                             // earthNode
        frameNode <<< earthNode
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ get the observer's position ..                                                                   ╎
  ╎ .. and attach an "obsvr" node to node "earth"                                                    ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let obsCelestial = geo2eci(julianDays: -1.0,
                                   geodetic: Vector(AnnArborLatitude, AnnArborLongitude, AnnArborAltitude))
        Geometries.addObserver(earthNode, at: (obsCelestial.x, obsCelestial.y, obsCelestial.z))
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ rotate "earthNode" for time of day                                                               ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        earthNode.eulerAngles.z += CGFloat(zeroMeanSiderealTime(julianDate: Date().julianDate) * deg2rad)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ .. and attach "camra" node to "scene" and "light" node to "earth" ..                             ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        addViewCamera(to: sceneNode)
        addSolarLight(to: frameNode)

        frameNode.eulerAngles = SCNVector3(x: -CGFloat.π/2.0, y: -CGFloat.π/2.0, z: 0.0)
        frameNode.scale =
            SCNVector3(1.0, 1.0, 6356.752/6378.135)         // flatten the earth slightly !
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        NotificationCenter.default.addObserver(self, selector: #selector(self.ApplicationAwake),
                                               name: NSApplication.willBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.ApplicationSleep),
                                               name: NSApplication.willResignActiveNotification, object: nil)
/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  .. sets some properties on the window's NSView (SceneView) including an overlayed SpriteKit     ┃
  ┃     placard which will display data and take hits.                                               ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidAppear" (10.10+), called once,                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidAppear() {
        super.viewDidAppear()
        print("ViewController.viewDidAppear()")

        sceneView.delegate = self                           // renderer will start running now ..
        sceneView.isPlaying = true
    }

// MARK: - AWAKE/SLEEP notification callbacks ..
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  ╎ notification callbacks ..                                                                        ╎
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @objc func ApplicationAwake(notification: Notification) {

        print(notification.name)
        sceneView.isPlaying = true

    }

    @objc func ApplicationSleep(notification: Notification) {

        print(notification.name)
        sceneView.isPlaying = false

    }

// MARK: - Rendering callback delegate ..
/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  SCNSceneRendererDelegate calls : sixty per second which is far too fast for our needs ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    var frameCount = 0

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ guard for satellites available ..                                                                ╎
  ╎                                                 .. once a second: reposition the satellite trail ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        guard let visualCollection = satelliteStore["visual.txt"],
                  visualCollection.collectionSats.count > 0 else { return }

        if frameCount % 10 == 0 {                   // once a second

            if let satellite = visualCollection.collectionSats["25544"] {

                if frameNode.childNode(withName: "25544", recursively: true) == nil {
                    trailNode = satellite.trailNode
                    frameNode <<< trailNode
                }

                tickNodes = trailNode.childNodes

                for index in orbTickRange {
                    let satCel = satellite.position(minsAfterEpoch: fakeClock.julianDaysNow())

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ is satellite in sunlight ?                                                                       ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
                    let horizonAngle = acos(eRadiusKms/magnitude(satCel)) * rad2deg
                    let sunCel =  solarCel(julianDays: Date().julianDate)
                    let eclipseDepth = (horizonAngle + 90.0) - separation(satCel, sunCel)

                    let tickIndex = index - orbTickRange.lowerBound
                    tickNodes[tickIndex].position = SCNVector3(satCel.x, satCel.y, satCel.z)

                    if let tickGeom = tickNodes[tickIndex].geometry as? SCNSphere {
                        if index == 0 {
                            tickGeom.radius = 50
                            tickGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                            tickGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
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
            earthNode.eulerAngles.z = CGFloat(zeroMeanSiderealTime(julianDate: Date().julianDate) * deg2rad)
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ if the sun exists (the construction succeeded) ..                                                ╎
  ╎                                                          .. once every ten minutes: move the sun ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if frameCount % 36000 == 0 {                // once every ten minutes
            let sunVector = solarCel(julianDays: Date().julianDate)
            solarNode.position = SCNVector3(-sunVector.x, -sunVector.y, -sunVector.z)

            frameCount = 0
        }

        frameCount += 1
    }

//    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
//
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
//
//    }

}
