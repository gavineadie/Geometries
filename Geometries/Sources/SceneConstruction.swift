/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SceneConstruction.swift                                                               Geometries ║
  ║ Created by Gavin Eadie on Mar12/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import CoreLocation
import SceneKit
import SatKit

public let  annArborLatitude = +42.2755                  // degrees
public let annArborLongitude = -83.7521                  // degrees
public let  annArborAltitude =   0.1                     // Kilometers

let  annArborLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: annArborLatitude,
                                                                      longitude: annArborLongitude),
                                   altitude: annArborAltitude * 1000.0,
                                   horizontalAccuracy: 1.0, verticalAccuracy: 1000.0, timestamp: Date())

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃                                                                                                  ┃
  ┃  .. gets the rootNode (sceneNode = "scene") in the sceneView and attaches various other nodes:   ┃
  ┃                                                                                                  ┃
  ┃     "frame" represents the inertial frame and it never directly transformed.                     ┃
  ┃                                                                                                  ┃
  ┃         It contains the "earth" node which is composed of a solid sphere ("globe"), graticule    ┃
  ┃         marks ("grids"), and the geographic coastlines, lakes , rivers, etc ("coast").           ┃
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
  ┃                                                       |                   |                      ┃
  ┃                         |                             |                   |                      ┃
  ┃                         |                             |                   |                      ┃
  ┃                         |                             +-- Node("spots")   +-- Node("obsvr")      ┃
  ┃                         |                             |                                          ┃
  ┃                         |                             +-- Node("solar" <<< "light")              ┃
  ┃                         |                                                                        ┃
  ┃                         +-- Node("viewr" <<< "camra")                                            ┃
  ┃                                                                                                  ┃
  ┃         Satellites also moving in the inertial frame but they are not added here ..              ┃
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

// MARK: - Scene construction functions ..

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ contruct the "frame" node .. this is the 'interial frame' of the universe ..                     │
  │                                                             .. and attach it to the "scene" node │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func makeFrame() -> SCNNode {
    if Debug.scene { print("       SceneConstruction| makeFrame()") }

    let frameNode = SCNNode(name: "frame")              // frameNode
    frameNode.eulerAngles = SCNVector3(-Float.π/2.0, -Float.π/2.0, 0.0)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ contruct the "earth" node .. this is the sphere of the Earth plus anything that rotates with it. ╎
  ╎ The Earth is not exactly spherical; that oblateness, is gained by scaling the "earth" node.      ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let earthNode = makeEarth()                             // earthNode ("globe", "grids", coast")
    earthNode.scale = SCNVector3(1.0, 1.0, 6356.752/6378.135)
    earthNode.eulerAngles.z = CGFloat(zeroMeanSiderealTime(julianDate: FakeClock.shared.julianDaysNow()) * deg2rad)
    frameNode <<< earthNode

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ .. and attach "solar" (with 1 "light" child to provide illumination) node to "frame"             ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let solarNode = makeSolarLight()
    solarNode.childNodes[0].constraints = [SCNLookAtConstraint(target: earthNode)]
    frameNode <<< solarNode                             //           "frame" << "solar"

    if Debug.scene { earthNode <<< addMarkerSpot(color: #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1), at: Vector(7000.0, 0.0, 0.0)) }

    return frameNode
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Dimensions (Kms):                                                                                ┃
  ┃             Earth Radius:   6,378                                                                ┃
  ┃     Geostationary Radius:  42,164                                                                ┃
  ┃      Camera Point Radius: 120,000                                                                ┃
  ┃             Camera z-box: ±40,000                                                                ┃
  ┃        Moon Orbit Radius: 385,000                                                                ┃
  ┃                                                                                                  ┃
  ┃     •---------•---------•---------•---------•---------•---------•---------•---------•---------•  ┃
  ┃    120       100       80        60        40        20         0       -20       -40       -60  ┃
  ┃     0864208642086420864208642086420864208642086420864208642086420864208642086420864208642086420  ┃
  ┃     C                   N                   │                │EEEEE│                │         F  ┃
  ┃                                             │                └─────┘                │            ┃
  ┃                                             └───────────────────────────────────────┘            ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

func makeEarth() -> SCNNode {
    if Debug.scene { print("       SceneConstruction| makeEarth()") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth -- contains "globe" + "grids" + "coast"                                                    ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let earthNode = SCNNode(name: "earth")

    earthNode <<< makeGlobe()

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's lat/lon grid dots -- build the "grids" node and add it to "earth" ..                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    if let gridsGeom = geometry(from: "grids.vector") {
        gridsGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        gridsGeom.firstMaterial?.lightingModel = .constant

        earthNode <<< SCNNode(geometry: gridsGeom, name: "grids")
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's coastline vectors -- build the "coast" node and add it to "earth" ..                     ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    if let coastGeom = geometry(from: "coast.vector") {
        coastGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        coastGeom.firstMaterial?.lightingModel = .constant

        earthNode <<< SCNNode(geometry: coastGeom, name: "coast")
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ get the observer's position, and attach an "obsvr" node to node "earth"                          ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let obsvrNode = makeObserver()
        obsvrNode.position = SCNVector3(geo2eci(julianDays: -1.0,
                                                geodetic: Vector(annArborLocation.coordinate.latitude,
                                                                 annArborLocation.coordinate.longitude,
                                                                 annArborLocation.altitude/1000.0)))
    earthNode <<< obsvrNode

    return earthNode
}

func makeGlobe() -> SCNNode {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ Earth's surface -- a globe of ~Rₑ                                                                ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let globeGeom = SCNSphere(radius: CGFloat(Rₑ - 14.0))
    globeGeom.isGeodesic = false
    globeGeom.segmentCount = 60

    let globeNode = SCNNode(geometry: globeGeom, name: "globe")

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ rotate the globe so the texture maps in the right place ..                                       ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

    globeNode.eulerAngles = SCNVector3(Float.π/2.0, 0.0, Float.π/2.0)

    let globeMaterial = SCNMaterial()
//  globeMaterial.diffuse.contents = UIImage(named: "earth_diffuse_4k.jpg")
    globeGeom.firstMaterial = globeMaterial

    globeGeom.firstMaterial?.emission.contents = Color.black
    globeGeom.firstMaterial?.specular.contents = Color.gray

    if #available(iOS 10, *) {
        globeGeom.firstMaterial?.lightingModel = .phong
    } else {
        globeGeom.firstMaterial?.lightingModel = .lambert
    }

    return globeNode
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the surface where the observer is standing ..                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func makeObserver() -> SCNNode {
    if Debug.scene { print("       SceneConstruction| makeObserver()") }

    let obsvrGeom = SCNSphere(radius: 50.0)
    obsvrGeom.isGeodesic = true
    obsvrGeom.segmentCount = 18
    obsvrGeom.firstMaterial?.emission.contents = #colorLiteral(red: 0, green: 1.0, blue: 0, alpha: 1)
    obsvrGeom.firstMaterial?.diffuse.contents = #colorLiteral(red: 0, green: 1.0, blue: 0, alpha: 1)

    let obsvrNode = SCNNode(geometry: obsvrGeom, name: "obsvr")

    return obsvrNode
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ create a viewpoint node "viewr" away from the center of "earth" which, when rotated, will keep   │
  │ that distance.  Attach the camera to it.                                                         │
  │                                                      http://stackoverflow.com/questions/25654772 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
let cameraDistance = 120_000.0
let cameraBracket = 40_000.0

func makeCameraView() -> SCNNode {
    if Debug.scene { print("       SceneConstruction| makeCameraView()") }

    let camera = SCNCamera()                            // create a camera
    camera.zFar  = cameraDistance+cameraBracket         // z-Range brackets geo
    camera.zNear = cameraDistance-cameraBracket

    if #available(iOS 11.0, OSX 10.13, *) {
        camera.fieldOfView = 7.5
    } else {
        camera.xFov = 7.5
        camera.yFov = 7.5
    }

    let camraNode = SCNNode(name: "camra")
    camraNode.position = SCNVector3(0, 0, Float(cameraDistance))
    camraNode.camera = camera

    let viewrNode = SCNNode(name: "viewr")              // non-rendering node, holds the camera

    viewrNode <<< camraNode                             // attach the camera to the v           "viewr" << "camra"

    if Debug.scene {
        viewrNode <<< addMarkerSpot(color: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), at: Vector(0.0, 0.0, 7000.0))
        viewrNode <<< addMarkerSpot(color: #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), at: Vector(0.0, 0.0, 7100.0))
        viewrNode <<< addMarkerSpot(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), at: Vector(0.0, 0.0, 7200.0))
    }

    return viewrNode
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func makeSolarLight() -> SCNNode {
    if Debug.scene { print("       SceneConstruction| makeSolarLight()") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ put a node in the direction of the sun ..                                                        ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let solarNode = SCNNode(name: "solar")              // position of sun in (x,y,z)

    let sunVector = solarCel(julianDays: FakeClock.shared.julianDaysNow())
    solarNode.position = SCNVector3(sunVector)
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╎ make a bright light ..                                                                           ╎
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    let sunLight = SCNLight()
    sunLight.type = .directional                        // make a directional light

    let lightNode = SCNNode(name: "light")
    lightNode.light = sunLight

    solarNode <<< lightNode                             //                      "solar" << "light"
    return solarNode
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ a spot on the x-axis (points at vernal equinox)                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func addMarkerSpot(color: Color, at: Vector) -> SCNNode {
    if Debug.scene { print("       SceneConstruction| addMarkerSpot()") }

    let spotsGeom = SCNSphere(radius: 100.0)
    spotsGeom.isGeodesic = true
    spotsGeom.segmentCount = 6
    spotsGeom.firstMaterial?.emission.contents = color

    let spotsNode = SCNNode(geometry: spotsGeom)
    spotsNode.position = SCNVector3(at)

    return spotsNode
}

struct Vertex {
    var x: Float
    var y: Float
    var z: Float
}

let vertexStride = MemoryLayout<Vertex>.stride

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ reads a binary file (x,y,z),(x,y,z), (x,y,z),(x,y,z), .. and makes a SceneKit Geometry ..        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func geometry(from resourceFile: String) -> SCNGeometry? {
    let mainBundle = Bundle.main
    let sceneURL = mainBundle.url(forResource: resourceFile, withExtension: "")

    guard let dataContent = try? Data(contentsOf: sceneURL!) else {
        print("mesh file '\(resourceFile)' missing")
        return nil
    }

    let vertexSource = SCNGeometrySource(data: dataContent,
                                         semantic: SCNGeometrySource.Semantic.vertex,
                                         vectorCount: dataContent.count/(vertexStride*2),
                                         usesFloatComponents: true, componentsPerVector: 3,
                                         bytesPerComponent: MemoryLayout<Float>.size,
                                         dataOffset: 0, dataStride: vertexStride)

    let element = SCNGeometryElement(data: nil, primitiveType: .line,
                                     primitiveCount: dataContent.count/(vertexStride*2),
                                     bytesPerIndex: MemoryLayout<UInt16>.size)

    return SCNGeometry(sources: [vertexSource], elements: [element])
}
