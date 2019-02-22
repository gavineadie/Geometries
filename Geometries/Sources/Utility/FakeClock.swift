/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ FakeClock.swift                                                                       Satellites ║
  ║ Created by Gavin Eadie on Aug26/17.. Copyright © 2017-18 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation
import SatKit

class FakeClock {

    typealias JulianDays = Double

    public var dateOffset: Double = 0.0
    public var dateFactor: Double = 0.0
           var dateOrigin: Date = Date()

    static let shared = FakeClock()

    private init() {}

    public func date() -> Date {

        let now = Date()
        return now + dateOffset + now.timeIntervalSince(dateOrigin) * dateFactor

    }

    public func reset() {

        self.dateOffset = 0.0
        dateFactor = 0.0
        dateOrigin = Date()

    }

    public func julianDaysNow() -> JulianDays {
        return JD.appleZero + self.date().timeIntervalSinceReferenceDate * TimeConstants.sec2day
    }

    public func ep1950DaysNow() -> Double {
        return julianDaysNow() - JD.epoch1950
    }

}
