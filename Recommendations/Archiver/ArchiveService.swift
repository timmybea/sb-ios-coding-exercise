//
//  ArchiveService.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

//MARK: ArchiveService
class ArchiveService<T: NSObject & Codable> {
    
    let archiveUrl: URL
    
    private let accessQueue: DispatchQueue
    
    var unarchivedObjects = Set<T>()
    
    /// sets full path url in documents directory.
    /// sets the concurrent dispatch queue.
    /// attempts to set the unarchived objects set.
    init(fileName: String) {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.archiveUrl = path.appendingPathComponent(fileName)
        
        self.accessQueue = DispatchQueue(label: "archive." + fileName, attributes: .concurrent)
        
        do {
            let data = try Data(contentsOf: archiveUrl)
        
            guard let unarchived = try? JSONDecoder().decode([T].self, from: data) else { return }
            unarchivedObjects = Set(unarchived)
            
        } catch {
            print("\(error.localizedDescription), file: \(#file), line: \(#line)")
        }
        
    }
    
    /// synchronously gets all unarchived objects.
    func getAll() -> [T] {
        var allObjects = [T]()
        accessQueue.sync {
            allObjects = Array(self.unarchivedObjects)
            print("HERE: allObjects \(allObjects)")
        }
        print("HERE: unarchived \(unarchivedObjects)")
        print("HERE: returning objects \(allObjects)")
        return allObjects
    }

    /// inserts the new object into unarchived objects and saves.
    func save(_ object: T) {
        accessQueue.async(flags: .barrier, execute: {
            self.unarchivedObjects.insert(object)
        })
        write()
    }
    
    /// removes all objects from the unarchived objects set and saves.
    func removeAll() {
        accessQueue.async(flags: .barrier, execute: {
            self.unarchivedObjects.removeAll()
        })
        write()
    }

    /// writes the present state of the unarchived objects set to full path/
    private func write() {
        
        var backgroundTask: UIBackgroundTaskIdentifier?
        backgroundTask = UIApplication.shared.beginBackgroundTask (expirationHandler: {
            UIApplication.shared.endBackgroundTask(backgroundTask!)
            backgroundTask = UIBackgroundTaskIdentifier(rawValue: UIBackgroundTaskIdentifier.invalid.rawValue)
        })
        
        accessQueue.sync(flags: .barrier, execute: {
            do {
                let rootObject = Array(self.unarchivedObjects)
                let data = try JSONEncoder().encode(rootObject)

                try data.write(to: archiveUrl)
                
            } catch {
                print("\(error.localizedDescription), file: \(#file), line:\(#line)")
            }
            
            UIApplication.shared.endBackgroundTask(backgroundTask!)
            backgroundTask = UIBackgroundTaskIdentifier(rawValue: UIBackgroundTaskIdentifier.invalid.rawValue)
        })
    }

}
