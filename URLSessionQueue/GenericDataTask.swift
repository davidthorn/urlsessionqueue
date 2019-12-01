//
//  GenericDataTask.swift
//  URLSessionQueue
//
//  Created by David Thorn on 01.12.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public class GenericDataTask<T: Decodable>: DataTaskProtocol {
    
    public var task: URLSessionTask
    
    public var data: Data?
    
    public let identifier: Int
    
    public init(task: URLSessionTask, data: Data? = nil, identifier: Int? = nil) {
        self.task = task
        self.data = data
        self.identifier = identifier ?? task.taskIdentifier
    }
    
    public var taskElement: T? { return decodable as? T }
    public var taskElements: [T] { return decodables as? [T] ?? [] }
    
    public var decodable: Decodable? {
        do {
            guard let data = data else { return nil }
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error {
            debugPrint(error)
            return nil
        }
    }
    
    public var decodables: [Decodable] {
        do {
            guard let data = data else { return [] }
            return try JSONDecoder().decode([T].self, from: data)
        } catch let error {
            debugPrint(error)
            return []
        }
    }
    
    public func update(newData: Data) -> DataTaskProtocol {
        data = update(data: data, newData: newData)
        return self
    }
    
}
