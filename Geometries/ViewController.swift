/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ViewController.swift                                                                  Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position
// swiftlint:disable cyclomatic_complexity

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

let Rₑ: CGFloat = 6.378135e3                // equatorial radius (polar radius = 6356.752 Kms)
let π: CGFloat = 3.1415926e0                // for now

let orbTickDelta = 15                       // seconds between ticks on orbit path
let orbTickRange = -10...330                //

class ViewController: NSViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var totalView: SceneView!

    var totalNode: SCNNode!                 // set in "viewDidLoad()" after scene constructed ..
    var frameNode: SCNNode!
    var earthNode: SCNNode!
    var solarNode: SCNNode!
    var trailNode: SCNNode!
    var tickNodes: [SCNNode]!

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidLoad" (10.10+), called once,                                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController.viewDidLoad()")

        construct(scene: totalView)
        totalNode = totalView.scene?.rootNode
        frameNode = totalNode.childNode(withName: "frame", recursively: true)
        earthNode = frameNode.childNode(withName: "earth", recursively: true)
        solarNode = frameNode.childNode(withName: "solar", recursively: true)

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
                    tickNodes[tickIndex].position = SCNVector3((satCel.x, satCel.y, satCel.z))

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
        guard earthNode != nil else { return }

        if frameCount % 3600 == 0 {                 // every a minute
            earthNode.eulerAngles.z = CGFloat(zeroMeanSiderealTime(julianDaysNow()) * deg2rad)
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ if the sun exists (the construction succeeded) ..                                                ╎
  ╎                                                          .. once every ten minutes: move the sun ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        guard solarNode != nil else { return }

        if frameCount % 36000 == 0 {                // once every ten minutes
            let sunVector = solarCel(julianDays: julianDaysNow())
            solarNode.position = SCNVector3((-sunVector.x, -sunVector.y, -sunVector.z))

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
