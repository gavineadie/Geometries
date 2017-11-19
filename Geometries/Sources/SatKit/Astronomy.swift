/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Astronomy.swift                                                                           SatKit ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jul06/15.  Copyright (c) 2015 Ramsay Consulting. All rights reserved.  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import Foundation

public let  day2min: Double = (24.0 * 60.0)
public let  min2day: Double = 1.0 / day2min

public let  day2sec: Double = (24.0 * 60.0 * 60.0)
public let  sec2day: Double = 1.0 / day2sec

public let  eRadiusKms = 6378.135           // WGS72: equatorial radius (polar radius = 6356.752 Kms)
public let  eFlattening = (1.0 / 298.26)
public let  e2 = (eFlattening * (2.0 - eFlattening))

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Reference: The 1992 Astronomical Almanac, page K12.                                              ┃
  ┃                                                                                                  ┃
  ┃ Procedure eci2geo() will calculate the geodetic position of an object given its ECI position     ┃
  ┃ position and time.  It is intended to be used to determine the ground track of a satellite.      ┃
  ┃ The calculations assume the earth to be an oblate spheroid. If the time is negative, treat as    ┃
  ┃ zero.                                                                                            ┃
  ┃                                                                                                  ┃
  ┃ geodetic : latitude (degrees)                                                                    ┃
  ┃          : longitude (degrees)                                                                   ┃
  ┃          : altitude (meters above geoid) [### still Kms]                                         ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func eci2geo(julianDays: Double, celestial: Vector) -> Vector {

    let     positionXY = sqrt(celestial.x*celestial.x + celestial.y*celestial.y)
    var     newLatRads = atan2(celestial.z, positionXY)

    var     oldLatRads: Double
    var     correction: Double

    repeat {
        let sinLatitude = sin(newLatRads)
        correction = eRadiusKms / sqrt(1.0 - (e2 * sinLatitude*sinLatitude))
        oldLatRads = newLatRads
        newLatRads = atan2(celestial.z + correction * e2 * sinLatitude, positionXY)
    } while (fabs(newLatRads - oldLatRads) > 0.0001)

    return Vector(newLatRads * rad2deg,
                  fmod(360.0 + atan2pi(celestial.y, celestial.x) *
                    rad2deg - ((julianDays < 0.0) ? 0.0 : zeroMeanSiderealTime(julianDate: julianDays)), 360.0),
                  positionXY / cos(newLatRads) - correction)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ geo2eci                                                                                          ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public var siteMatrix00 = 0.0
public var siteMatrix01 = 0.0
public var siteMatrix02 = 0.0

public var siteMatrix10 = 0.0
public var siteMatrix11 = 0.0
public var siteMatrix12 = 0.0

public var siteMatrix20 = 0.0
public var siteMatrix21 = 0.0
public var siteMatrix22 = 0.0

public func geo2eci(julianDays: Double, geodetic: Vector) -> Vector {
    let     latitudeRads = geodetic.x * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let      c = eRadiusKms / sqrt(1.0 + e2 * sinLatitude * sinLatitude)
    let      s = (1 - e2) * c
    let      achcp = (c + geodetic.z) * cosLatitude

    let      siderealRads = ((julianDays < 0.0) ? geodetic.y :
        siteMeanSiderealTime(julianDate: julianDays, geodetic.y)) * deg2rad
    let      sinSidereal = sin(siderealRads)
    let      cosSidereal = cos(siderealRads)

    siteMatrix00 = +sinLatitude * cosSidereal
    siteMatrix01 = +sinLatitude * sinSidereal
    siteMatrix02 = -cosLatitude
    siteMatrix10 =               -sinSidereal
    siteMatrix11 =               +cosSidereal
    siteMatrix12 =               +0.0
    siteMatrix20 = +cosLatitude * cosSidereal
    siteMatrix21 = +cosLatitude * sinSidereal
    siteMatrix22 = +sinLatitude

    return Vector(achcp * cosSidereal,
                  achcp * sinSidereal,
                  (s + geodetic.z) * sinLatitude)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func cel2top(satVector: Vector, obsVector: Vector) -> Vector {
    let obs2sat = Vector(satVector.x - obsVector.x,
                         satVector.y - obsVector.y,
                         satVector.z - obsVector.z)

    return Vector(obs2sat.x*siteMatrix00 + obs2sat.y*siteMatrix01 + obs2sat.z*siteMatrix02,
                  obs2sat.x*siteMatrix10 + obs2sat.y*siteMatrix11 + obs2sat.z*siteMatrix12,
                  obs2sat.x*siteMatrix20 + obs2sat.y*siteMatrix21 + obs2sat.z*siteMatrix22)
}

let     JD_2000 = 2451545.0                                 // 2000-Jan-01.5 (12h)

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ http://aa.usno.navy.mil/faq/docs/SunApprox.php                                                   ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func solarCel(julianDays: Double) -> Vector {
    let     daysSinceJD2000 = julianDays - JD_2000

    let     solarMeanAnom = (357.529 + 0.98560028 * daysSinceJD2000) * deg2rad

    let     aberration1 = 1.915 * sin(1.0 * solarMeanAnom)
    let     aberration2 = 0.020 * sin(2.0 * solarMeanAnom)

    let     solarEclpLong = ((280.459 + 0.98564736 * daysSinceJD2000) + aberration1 + aberration2) * deg2rad

    let     eclipticInclin =  (23.439 - 0.00000036 * daysSinceJD2000) * deg2rad

    return Vector(cos(solarEclpLong),
                  sin(solarEclpLong) * cos(eclipticInclin),
                  sin(solarEclpLong) * sin(eclipticInclin))
}

//  Declination (delta) and Right Ascension (alpha) are returned as decimal degrees.

public func solarGeo(julianDays: Double) -> (Double, Double) {
    let     solarVector: Vector = solarCel(julianDays: julianDays)

    return (asin(solarVector.z) * rad2deg, atan2pi(solarVector.y, solarVector.x) * rad2deg)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Low precision formulae for the moon, from:                                                       ┃
  ┃                            AN ALTERNATIVE LUNAR EPHEMERIS MODEL FOR ON-BOARD FLIGHT SOFTWARE USE ┃
  ┃                                                                by: David G. Simpson (NASA, GSFC) ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func lunarCel(julianDays: Double) -> Vector {
    let     centsSinceJD2000 = ( julianDays - JD_2000 ) / 36525.0

    let moonX1 = 383.0e3 * sin( 8399.685 * centsSinceJD2000 + 5.381)
    let moonX2 =  31.5e3 * sin(   70.990 * centsSinceJD2000 + 6.169)
    let moonX3 =  10.6e3 * sin(16728.377 * centsSinceJD2000 + 1.453)
    let moonX4 =   6.2e3 * sin( 1185.622 * centsSinceJD2000 + 0.481)
    let moonX5 =   3.2e3 * sin( 7143.070 * centsSinceJD2000 + 5.017)
    let moonX6 =   2.3e3 * sin(15613.745 * centsSinceJD2000 + 0.857)
    let moonX7 =   0.8e3 * sin( 8467.263 * centsSinceJD2000 + 1.010)

    let moonY1 = 351.0e3 * sin( 8399.687 * centsSinceJD2000 + 3.811)
    let moonY2 =  28.9e3 * sin(   70.997 * centsSinceJD2000 + 4.596)
    let moonY3 =  13.7e3 * sin( 8433.466 * centsSinceJD2000 + 4.766)
    let moonY4 =   9.7e3 * sin(16728.380 * centsSinceJD2000 + 6.165)
    let moonY5 =   5.7e3 * sin( 1185.667 * centsSinceJD2000 + 5.164)
    let moonY6 =   2.9e3 * sin( 7143.058 * centsSinceJD2000 + 0.300)
    let moonY7 =   2.1e3 * sin(15613.755 * centsSinceJD2000 + 5.565)

    let moonZ1 = 153.2e3 * sin( 8399.672 * centsSinceJD2000 + 3.807)
    let moonZ2 =  31.5e3 * sin( 8433.464 * centsSinceJD2000 + 1.629)
    let moonZ3 =  12.5e3 * sin(   70.996 * centsSinceJD2000 + 4.595)
    let moonZ4 =   4.2e3 * sin(16728.364 * centsSinceJD2000 + 6.162)
    let moonZ5 =   2.5e3 * sin( 1185.645 * centsSinceJD2000 + 5.167)
    let moonZ6 =   3.0e3 * sin(  104.881 * centsSinceJD2000 + 2.555)
    let moonZ7 =   1.8e3 * sin( 8399.116 * centsSinceJD2000 + 6.248)

    return Vector(
        moonX1 + moonX2 + moonX3 + moonX4 + moonX5 + moonX6 + moonX7,
        moonY1 + moonY2 + moonY3 + moonY4 + moonY5 + moonY6 + moonY7,
        moonZ1 + moonZ2 + moonZ3 + moonZ4 + moonZ5 + moonZ6 + moonZ7)
}

//  Right Ascension (alpha) and Declination (delta) are returned as decimal degrees.

public func lunarGeo (julianDays: Double) -> (Double, Double) {
    let     lunarVector: Vector = lunarCel(julianDays: julianDays)

    return (asin(lunarVector.z / sqrt(lunarVector.x * lunarVector.x +
                                      lunarVector.y * lunarVector.y +
                                      lunarVector.z * lunarVector.z)) * rad2deg,
            atan2pi(lunarVector.y, lunarVector.x) * rad2deg)
}
