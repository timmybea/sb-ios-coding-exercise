//
//  ArchiveService.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-05.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

class ArchiveService<T: NSObject & NSCoding> {
    
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
            guard let unarchived = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [T] else { return }
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
        }
        return allObjects
    }

    func save(_ object: T) {
        accessQueue.async(flags: .barrier, execute: {
            if let index = self.unarchivedObjects.firstIndex(where: { $0 == object }) {
                self.unarchivedObjects.remove(at: index)
            }
            self.unarchivedObjects.insert(object)
            print("HERE: unarchived objects count \(self.unarchivedObjects.count)")
        })
        write()
    }

    /// adds objects to unarchived objects set and saves.
    /// if an object is already in the set, it is replaced by the object in the input argument.
    func save(_ objects: [T]) {
        accessQueue.async(flags: .barrier, execute: {
            objects.forEach({ (element) in
                if let index = self.unarchivedObjects.firstIndex(where: { $0 == element }) {
                    self.unarchivedObjects.remove(at: index)
                }
                self.unarchivedObjects.insert(element)
            })
        })
        write()
    }

    func remove(_ object: T) {
        accessQueue.async(flags: .barrier, execute: {
            self.unarchivedObjects.remove(object)
        })
        write()
    }

    /// removes the objects from the unarchived objects set and saves.
    func remove(_ objects: [T]) {
        accessQueue.async(flags: .barrier, execute: {
            objects.forEach { (element) in
                if let index = self.unarchivedObjects.firstIndex(where: { $0 == element }) {
                    self.unarchivedObjects.remove(at: index)
                }
            }
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
                let data = try NSKeyedArchiver.archivedData(withRootObject: rootObject, requiringSecureCoding: false)
                try data.write(to: archiveUrl)
            } catch {
                print("\(error.localizedDescription), file: \(#file), line:\(#line)")
            }
            
            UIApplication.shared.endBackgroundTask(backgroundTask!)
            backgroundTask = UIBackgroundTaskIdentifier(rawValue: UIBackgroundTaskIdentifier.invalid.rawValue)
        })
    }

    /**
        Removes the Archive file from the file system.
    */
    func delete() {
        try? FileManager.default.removeItem(at: self.archiveUrl)
    }

    /// indicates whether or not the full data at full path is able to be unarchived.
    func testArchiveCompatability() throws {
        let data = try Data(contentsOf: archiveUrl)
        let _ = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [T]
    }
    
}
