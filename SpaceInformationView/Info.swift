//
//  Info.swift
//  SceneDepthPointCloud
//
//  Created by 장준석 on 2023/08/16.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

public struct Info {
    
    func makePosMatrix(x: Float, y: Float, z: Float) -> simd_float4x4{
        
        var matrix =  simd_float4x4([
            simd_float4(1.0, 0.0, 0.0, 0.0),
            simd_float4(0.0, 1.0, 0.0, 0.0),
            simd_float4(0.0, 0.0, 1.0, 0.0),
            simd_float4(0.0, 0.0, 0.0, 1.0)
        ])
        matrix[3] = simd_float4(x, y, z, 1.0)
        
        return matrix
    }
    
}
