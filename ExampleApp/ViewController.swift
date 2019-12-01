//
//  ViewController.swift
//  ExampleApp
//
//  Created by David Thorn on 01.12.19.
//  Copyright © 2019 David Thorn. All rights reserved.
//

import UIKit
import URLSessionQueue

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
}

struct User: Codable {
    let id: Int
    let name: String
}

struct Photo: Codable {
    let albumId: Int
    let id: Int
    let title: String
    let url: URL
    let thumbnailUrl: URL
}

class ViewController: UIViewController {
    
    var dataQueue = URLSessionQueue()
    
    lazy var usersDataTask: GenericDataTask<User> = {
        let usersTask = dataQueue.createTask(url:  URL(string: "https://jsonplaceholder.typicode.com/users")!)
        return GenericDataTask<User>(task: usersTask, data: nil, identifier: usersTask.taskIdentifier)
    }()
    
    lazy var postsDataTask: GenericDataTask<Post> = {
        let postsTask = dataQueue.createTask(url:  URL(string: "https://jsonplaceholder.typicode.com/posts")!)
        return GenericDataTask<Post>(task: postsTask, data: nil, identifier: postsTask.taskIdentifier)
    }()
    
    lazy var photosDataTask: GenericDataTask<Photo> = {
        let photosTask = dataQueue.createTask(url:  URL(string: "https://jsonplaceholder.typicode.com/photos")!)
        return GenericDataTask<Photo>(task: photosTask, data: nil, identifier: photosTask.taskIdentifier)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataQueue.addTask(dataTask: photosDataTask)
        dataQueue.addTask(dataTask: postsDataTask)
        dataQueue.addTask(dataTask: usersDataTask)
        
        dataQueue.execute(taskCompleted: { (task, error) in
            debugPrint("Task completed: \(task.identifier) with error: \(error)")
        }) { [weak self] completedTasks in
            guard let strongSelf = self else { return }
            
            debugPrint(strongSelf.usersDataTask.taskElements.map( { $0.name }))
            debugPrint("all tasks completed......")
        }
        
    }
    
    
}

