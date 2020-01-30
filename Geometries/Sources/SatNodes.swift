/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Satellite.swift                                                                       Satellites ║
  ║ Created by Gavin Eadie on Jan01/17.. Copyright © 2017-20 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable statement_position
// swiftlint:disable function_body_length

import AppExtras
import SceneKit
import SatelliteKit

let orbTickDelta = 30                                           // seconds between marks on orbit
let orbTickRange = -5*(60/orbTickDelta)...80*(60/orbTickDelta)  // range of marks on orbital track ..
let surTickRange = -5*(60/orbTickDelta)...300*(60/orbTickDelta) // range of marks on surface track ..

let horizonVertexCount = 90

var fakeClock = FakeClock.shared

public extension Satellite {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    var trailNode: SCNNode {
        let basicNode = SCNNode()
        basicNode.name = self.noradIdent

        for _ in 0...orbTickRange.count {
            let dottyGeom = SCNSphere(radius: 10.0)         //
            dottyGeom.isGeodesic = true
            dottyGeom.segmentCount = 6
            dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // NSColor.white (!!CPU!!)

            let dottyNode = SCNNode(geometry: dottyGeom)
            dottyNode.position = SCNVector3(0.0, 0.0, 0.0)

            basicNode <<< dottyNode                         //                      "trail" << "dotty"
        }

        return basicNode
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ satellite may own a SCNNode containing a trail of dots [SCNNode] along the orbital trail         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func orbitalNode(inFrame frameNode: SCNNode) {
        if frameNode.childNode(withName: "O-" + self.noradIdent, recursively: true) == nil {

            let node = SCNNode(name: "O-" + self.noradIdent)

            for _ in orbTickRange {
                let dottyGeom = SCNSphere(radius: 10.0)         //
                dottyGeom.isGeodesic = true
                dottyGeom.segmentCount = 4
                dottyGeom.firstMaterial?.emission.contents = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // NSColor.white (!!CPU!!)
                node <<< SCNNode(geometry: dottyGeom)
            }

            frameNode <<< node
        }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ satellite may own a SCNNode containing a trail of dots [SCNNode] along the surface trail         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func surfaceNode(inFrame frameNode: SCNNode) {
        if frameNode.childNode(withName: "S-" + self.noradIdent, recursively: true) == nil {

            let node = SCNNode(name: "S-" + self.noradIdent)

            for _ in surTickRange {
                let dottyGeom = SCNSphere(radius: 50.0)
                dottyGeom.isGeodesic = true
                dottyGeom.segmentCount = 4
                dottyGeom.firstMaterial?.emission.contents = Color.white    // (!!CPU!!)
                dottyGeom.firstMaterial?.diffuse.contents = Color.gray
                node <<< SCNNode(geometry: dottyGeom)
            }

            frameNode <<< node
        }

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ satellite may own a SCNNode containing the circle on the ground that is its horizon ..           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func horizonNode(inFrame frameNode: SCNNode) {
        var horizonVertices = Data(capacity: MemoryLayout<Vertex>.stride * horizonVertexCount * 2)
        horizonVertices.removeAll()
        let satNowLatLonAlt = self.geoPosition(minsAfterEpoch:
                                            (fakeClock.ep1950DaysNow() - self.t₀Days1950) * 1440.0)

        let satLatitudeRads = satNowLatLonAlt.lat * deg2rad
        let satLongitudeRads = satNowLatLonAlt.lon * deg2rad
        let sinSatLatitude = sin(satLatitudeRads)
        let cosSatLatitude = cos(satLatitudeRads)

        let elevationLimitRads = 5.0 * deg2rad
        let beta = acos(cos(elevationLimitRads) * EarthConstants.Rₑ /
                            (EarthConstants.Rₑ + satNowLatLonAlt.alt)) - elevationLimitRads
        let sinBeta = sin(beta)
        let cosBeta = cos(beta)

        for azimuthStep in 0...horizonVertexCount {

            let azimuthDegs = azimuthStep * 360 / horizonVertexCount
            let azimuthRads = fmod2pi_0(Double(azimuthDegs) * deg2rad)

            let footDelta = asin(sinSatLatitude * cosBeta +
                                 cosSatLatitude * sinBeta * cos(azimuthRads))

            let numerator = cosBeta - sinSatLatitude * sin(footDelta)
            let denominator =         cosSatLatitude * cos(footDelta)

            var footAlpha = 0.0

            if beta > .pi/2 - satLatitudeRads &&
               (azimuthDegs == 0 || azimuthDegs == 180) { footAlpha = satLongitudeRads + .pi }
            else if fabs(numerator/denominator) > 1.0 { footAlpha = satLongitudeRads }
            else {
                if azimuthDegs < 180 { footAlpha = satLongitudeRads - acos2pi(numerator, denominator) }
                                else { footAlpha = satLongitudeRads + acos2pi(numerator, denominator) }
            }

            let eciVector = geo2xyz(julianDays: (fakeClock.ep1950DaysNow() - self.t₀Days1950) * 1440.0 *
                                                        TimeConstants.min2day + self.t₀Days1950 + JD.epoch1950,
                                    geodetic: LatLonAlt(lat: footDelta * rad2deg,
                                                        lon: footAlpha * rad2deg,
                                                        alt: 0.0))

            var eciVertex = Vertex(x: Float(eciVector.x), y: Float(eciVector.y), z: Float(eciVector.z))

            horizonVertices.append(Data(bytes: &eciVertex, count: MemoryLayout<Vertex>.size))
            if azimuthStep > 0 && azimuthStep < horizonVertexCount {
                horizonVertices.append(Data(bytes: &eciVertex, count: MemoryLayout<Vertex>.size))
            }

        }

        let vertexSource = SCNGeometrySource(data: horizonVertices,
                                             semantic: SCNGeometrySource.Semantic.vertex,
                                             vectorCount: horizonVertices.count/(vertexStride*2),
                                             usesFloatComponents: true, componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0, dataStride: vertexStride)

        let element = SCNGeometryElement(data: nil, primitiveType: .line,
                                         primitiveCount: horizonVertices.count/(vertexStride*2),
                                         bytesPerIndex: MemoryLayout<UInt16>.size)

        let horizonGeom = SCNGeometry(sources: [vertexSource], elements: [element])
        horizonGeom.firstMaterial?.diffuse.contents = Color.yellow
        horizonGeom.firstMaterial?.lightingModel = .constant

        let newHorizonNode = SCNNode(geometry: horizonGeom, name: "H-" + self.noradIdent)

        if let oldHorizonNode = frameNode.childNode(withName: "H-" + self.noradIdent, recursively: true) {
            frameNode.replaceChildNode(oldHorizonNode, with: newHorizonNode)
        }
        else {
            frameNode.addChildNode(newHorizonNode)
        }

    }

    func everySecond(inFrame frameNode: SCNNode) {

        guard let orbitalNode = frameNode.childNode(withName: "O-" + self.noradIdent,
        											recursively: true) else {return }
        let oDots = orbitalNode.childNodes

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ obtain the time (possibly 'fake') and set up the intervals before and after to plot ..           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let nowMinsAfterEpoch = (fakeClock.ep1950DaysNow() - self.t₀Days1950) * 1440.0

        for index in orbTickRange {

		let tickMinutes = nowMinsAfterEpoch + Double(orbTickDelta*index) / 60.0
		let oSatCel = self.position(minsAfterEpoch: tickMinutes)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for 'orbital' track, is satellite in sunlight ?                                                  ┆
  ┆                                                    .. eclipsed dots are smaller than sunlit ones ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
		let horizonAngle = acos(EarthConstants.Rₑ/magnitude(oSatCel)) * rad2deg
		let sunCel = solarCel(julianDays: fakeClock.julianDaysNow())
		let eclipseDepth = (horizonAngle + 90.0) - separation(oSatCel, sunCel)

		let tickIndex = index - orbTickRange.lowerBound
		oDots[tickIndex].position = SCNVector3(oSatCel.x, oSatCel.y, oSatCel.z)

		if let tickGeom = oDots[tickIndex].geometry as? SCNSphere {
			if index == 0 {
				tickGeom.radius = 50
				tickGeom.firstMaterial?.emission.contents = Color.red
				tickGeom.firstMaterial?.diffuse.contents = Color.red
			} else {
				tickGeom.radius = eclipseDepth < 0.0 ? 15.0 : 30.0
			}
		}
	}

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ for 'surface' track ..                                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        guard let surfaceNode = frameNode.childNode(withName: "S-" + self.noradIdent,
        											recursively: true) else {return }
        let sDots = surfaceNode.childNodes

        for index in surTickRange {

            let tickMinutes = nowMinsAfterEpoch + Double(orbTickDelta*index) / 60.0
            let oSatCel = self.position(minsAfterEpoch: tickMinutes)

            let jDate = self.t₀Days1950 + JD.epoch1950 + tickMinutes / 1440.0
            var lla = eci2geo(julianDays: jDate, celestial: oSatCel)
            lla.alt = 0.0                                            // altitude = 0.0 (surface)
			lla.lon -= Double(orbTickDelta*index) * EarthConstants.rotationₑ / 240.0

            let sSatCel = geo2eci(julianDays: jDate, geodetic: lla)

            let tickIndex = index - surTickRange.lowerBound
            sDots[tickIndex].position = SCNVector3(sSatCel.x, sSatCel.y, sSatCel.z)

            if index == 0 {
                if let tickGeom = sDots[tickIndex].geometry as? SCNSphere {
                    tickGeom.radius = 50
                    tickGeom.firstMaterial?.emission.contents = Color.red
                    tickGeom.firstMaterial?.diffuse.contents = Color.red
                }
            }
        }
    }
}
