//
//  DynamicValue.swift
//  Recommendations
//
//  Created by Tim Beals on 2020-05-06.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

typealias CompletionHandler = (() -> Void)

//MARK: DynamicValue
class DynamicValue<T> {

    var value : T {
        didSet {
            self.notify()
        }
    }

    private var observers = [String: CompletionHandler]()

    init(_ value: T) {
        self.value = value
    }

    public func addObserver(_ observer: NSObject, completionHandler: @escaping CompletionHandler) {
        observers[observer.description] = completionHandler
    }

    public func addAndNotify(observer: NSObject, completionHandler: @escaping CompletionHandler) {
        self.addObserver(observer, completionHandler: completionHandler)
        self.notify()
    }

    public func removeObserver(_ observer: NSObject) {
        observers[observer.description] = nil
    }
    
    public func removeAllObservers() {
        observers = [:]
    }
    
    private func notify() {
        observers.forEach({ $0.value() })
    }

    deinit {
        observers.removeAll()
    }
}
