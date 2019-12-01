//
//  DataTaskProtocol.swift
//  URLSessionQueue
//
//  Created by David Thorn on 01.12.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public protocol DataTaskProtocol {
    var task: URLSessionTask { get }
    var data: Data? { get }
    var identifier: Int { get }
    var decodable: Decodable? { get }
    var decodables: [Decodable] { get }
    func update(newData: Data) -> DataTaskProtocol
    func update(data: Data? , newData: Data) -> Data
}

extension DataTaskProtocol {
    
    public func update(data: Data? , newData: Data) -> Data {
        if var currentData = data {
            currentData.append(newData)
            return currentData
        }
        
        return newData
    }
    
}
