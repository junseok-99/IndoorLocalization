//
//  Info.swift
//  SceneDepthPointCloud
//
//  Created by 장준석 on 2023/08/16.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

/*
 - usdz 파일명
 - ar좌표
 - 위치좌표, 위치명
 */

public struct Info {
    
    private var posObjects: [String: simd_float4x4] = [
        "M" : simd_float4x4([
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, 0.0, 0.0, 1.0)
        ]),
        "R" : simd_float4x4([
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, -0.995, 9.5, 9.0)
        ])
    ]
    
    func makePosMatrix(direction: String, x: Float, y: Float, z: Float) -> simd_float4x4{
        
        var matrix = posObjects[direction]
        matrix?[3] = simd_float4(x, y, z, 1.0)
        
        return matrix!
    }
    
}
