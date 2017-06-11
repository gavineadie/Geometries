/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Geometries.swift                                                                      Geometries ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jun10/17  ..  Copyright © 2017 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable large_tuple
// swiftlint:disable variable_name
// swiftlint:disable statement_position
// swiftlint:disable file_length

import SceneKit

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
func coastMesh() -> SCNGeometry? {
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
func gridsMesh() -> SCNGeometry? {
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
