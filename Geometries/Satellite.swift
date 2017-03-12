/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Satellite.swift                                                                       Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jan01/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import SatKit

public extension Satellite {

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃                                                                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    public func positionsᴱᴾ(epochStride: StrideThrough<Double>) -> [Vector] {

        var result = [Vector]()

        for (_, epochMin) in epochStride.enumerated() {
            result.append(self.position(minsAfterEpoch:epochMin))
        }

        return result

    }

}
