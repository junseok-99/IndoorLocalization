//
//  Http_Client.swift
//  SceneDepthPointCloud
//
//  Created by 장준석 on 2023/10/03.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

let url = "http://192.168.219.100:8080"

struct SpaceData: Codable {
    let spaceInfo: [SpaceInfos]
}

struct SpaceInfos: Codable {
    let pos_name: String
    let x1: Float
    let x2: Float
    let z1: Float
    let z2: Float
}

func getSpaceInfo() -> SpaceData {
    
    let path = "/info/jsons"
    let finalUrl = url + path
    
    if let url = URL(string: finalUrl){
                
            var request = URLRequest.init(url: url)
            
            request.httpMethod = "GET"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                
            URLSession.shared.dataTask(with: request){ (data, response, error) in
                    
                if let error = error {
                        print("Error: \\(error.localizedDescription)")
                        return
                    }

                    guard let data = data else {
                        print("No data received")
                        return
                    }

                
                    do {
                            let json = try JSONDecoder().decode(SpaceData.self, from: data)
                            //let json = try JSONSerialization.jsonObject(with: data, options: [])
                            return json
                    
                        } catch let error {
                            print("Error: JSONS ERROR!!")
                        }
            }.resume() //URLSession - end
                
        }
}
