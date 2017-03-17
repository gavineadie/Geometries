/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ViewController.swift                                                                  Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/15 ... Copyright 2015-17 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position

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

        trailNode = construct(orbTickRange: orbTickRange, orbTickDelta: orbTickDelta)
        frameNode <<< trailNode
        tickNodes = trailNode.childNodes
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ "viewDidAppear" (10.10+), called once,                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func viewDidAppear() {
        super.viewDidAppear()
        print("ViewController.viewDidAppear()")

        totalView.delegate = self           // renderer won't start running till now ..
        totalView.isPlaying = true
        if #available(OSX 10.12, *) {
            totalView.preferredFramesPerSecond = 15
        } else {

        }

//      earthNode.removeFromParentNode()
//      trailNode.removeFromParentNode()
    }

// MARK: - Rendering callback delegate ..

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  SCNSceneRendererDelegate calls : sixty per second which is far too fast for our needs ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

    var frameCount = 0
    var satelliteIterator = satellites.makeIterator()

    open func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

//        if frameCount % 5 == 2 {                // twelve times a second, off the beat
//
//                if let (_, nextSatellite) = satelliteIterator.next() {
//                    addSatellite(frameNode, sat:nextSatellite)
//                }
//                else {
//                    satelliteIterator = satellites.makeIterator()
//                }
//
//        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ if the frame exists (the construction succeeded) ..                                              ╎
  ╎                                                          .. once a second: remodel the satellite ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        guard trailNode != nil else { return }

        if frameCount % 10 == 0 {                   // once a second
            if let satellite = satellites["25544"] {
                trailNode.name = satellite.catalogNum

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
                            tickGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)              // NSColor.red
                        }
                        else {
                            tickGeom.radius = eclipseDepth < 0 ? 10.0 : 20.0
//                            tickGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)              // NSColor.white (!!CPU!!)
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
            earthNode.eulerAngles.z = CGFloat(ZeroMeanSiderealTime(julianDaysNow()) * deg2rad)
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

    open func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {

    }

    open func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {

    }

}
