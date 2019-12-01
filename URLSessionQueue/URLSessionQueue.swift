//
//  URLSessionQueue.swift
//  URLSessionQueue
//
//  Created by David Thorn on 01.12.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import Foundation

public class URLSessionQueue: NSObject, URLSessionDataDelegate {

    private let queue = DispatchQueue(label: "urlsession.datatasks.queue")
    private var dataTasks: [DataTaskProtocol] = []
    
    public var taskCompleted: ((_ task: DataTaskProtocol, _ error: Error?) -> Void)?
    public var allTasksCompletedHandler: ((_ tasks: [DataTaskProtocol]) -> Void)?
    
    lazy var session: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }()
    
    public func addTask(dataTask: DataTaskProtocol) {
        dataTasks.append(dataTask)
    }
    
    public func addTask<T: Decodable>(url: URL, lazy: Bool = true) -> GenericDataTask<T> {
        let task = createTask(url: url)
        let dataTask: GenericDataTask<T> = GenericDataTask(task: task)
        dataTasks.append(dataTask)
        return dataTask
    }
    
    public func addTask<T: Decodable>(request: URLRequest, lazy: Bool = true) -> GenericDataTask<T> {
        let task = createTask(request: request)
        let dataTask = GenericDataTask<T>(task: task)
        dataTasks.append(dataTask)
        return dataTask
    }
    
    public func createTask(url: URL) -> URLSessionDataTask {
        return session.dataTask(with: url)
    }
    
    public func createTask(request: URLRequest) -> URLSessionTask {
        return session.dataTask(with: request)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let completedTask = queue.sync(execute: { return dataTasks.first { $0.task.taskIdentifier == task.taskIdentifier } }) {
            taskCompleted?(completedTask, error)
        }
        
        let completed = queue.sync { return dataTasks.filter { $0.task.state == .completed } }
        let allTasks = queue.sync { return dataTasks.count }
        
        if completed.count == allTasks {
            queue.sync {
                allTasksCompletedHandler?(dataTasks)
            }
        } else {
            debugPrint("Tasks completed: \(completed.count)/\(dataTasks.count)")
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        queue.sync {
            dataTasks = dataTasks.map { task in
                
                if task.task.taskIdentifier == dataTask.taskIdentifier {
                    return task.update(newData: data)
                }
                return task
            }
        }
    }
    
    public func execute(taskCompleted: ((_ task: DataTaskProtocol, _ error: Error?) -> Void)? = nil, allTasksCompletedHandler: ((_ tasks: [DataTaskProtocol]) -> Void)? = nil) {
        
        if let taskCompleted = taskCompleted {
            self.taskCompleted = taskCompleted
        }
        
        if let allTaskCompleted = allTasksCompletedHandler {
            self.allTasksCompletedHandler = allTaskCompleted
        }
        
        dataTasks.forEach { dataTask in
            dataTask.task.resume()
        }
    }
    
}
