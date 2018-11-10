//
//  ReaderViewQueue.swift
//  Settings
//
//  Created by Gary Griswold on 11/9/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//
import UIKit

struct ReaderViewQueue {
    
    private static let QUEUE_MAX: Int = 10
    private static let EXTRA_NEXT: Int = 4
    private static let EXTRA_PRIOR: Int = 3
    
    private var queue: [ReaderViewController]
    private var unused: Set<ReaderViewController>
    
    init() {
        self.queue = [ReaderViewController]()
        self.unused = Set<ReaderViewController>()
    }
    
    mutating func first(reference: Reference) -> ReaderViewController {
        for controller in self.queue {
            self.addUnused(controller: controller)
        }
        self.queue.removeAll()
        let controller = self.getUnused(reference: reference)
        self.queue.append(controller)
        return controller
    }
    
    /**
    * The ReaderViewController is one that is already in the queue.
    * So, it is guarantteed to be found within the list.
    */
    mutating func next(controller: UIViewController) -> ReaderViewController {
        guard let readController = controller as? ReaderViewController
            else { fatalError("ReaderViewQueue.next must receive ReaderViewController") }
        let index = findController(reference: readController.reference)
        if index < (queue.count - 1) {
            return self.queue[index + 1]
        } else {
            return appendAfter()
        }
    }
    
    mutating func prior(controller: UIViewController) -> ReaderViewController {
        guard let readController = controller as? ReaderViewController
            else { fatalError("ReaderViewQueue.prior must receive ReaderViewController") }
        let index = findController(reference: readController.reference)
        if index > 0 {
            return self.queue[index - 1]
        } else {
            return insertBefore()
        }
    }
    
    mutating func ensurePreload(reference: Reference) {
        let index = findController(reference: reference)
        if (self.queue.count - index) < ReaderViewQueue.EXTRA_NEXT {
            _ = self.appendAfter()
        }
        if index < ReaderViewQueue.EXTRA_PRIOR {
            _ = self.insertBefore()
        }
    }
    
    mutating private func appendAfter() -> ReaderViewController {
        let reference = self.queue.last!.reference!
        let controller = self.getUnused(reference: reference.nextChapter())
        self.queue.append(controller)
        
        if self.queue.count > ReaderViewQueue.QUEUE_MAX {
            let first = self.queue.removeFirst()
            self.addUnused(controller: first)
        }
        return controller
    }
    
    mutating private func insertBefore() -> ReaderViewController {
        let reference = self.queue[0].reference!
        let controller = self.getUnused(reference: reference.priorChapter())
        self.queue.insert(controller, at: 0)
        
        if self.queue.count > ReaderViewQueue.QUEUE_MAX {
            let last = self.queue.removeLast()
            self.addUnused(controller: last)
        }
        return controller
    }
    
    mutating private func getUnused(reference: Reference) -> ReaderViewController {
        var webView = self.unused.popFirst()
        if webView == nil {
            webView = ReaderViewController()
        }
        webView!.reference = reference
        return webView!
    }
    
    mutating private func addUnused(controller: ReaderViewController) {
        controller.clearWebView()
        self.unused.insert(controller)
    }
    
    private func findController(reference: Reference) -> Int {
        for index in 0..<self.queue.count {
            if self.queue[index].reference == reference {
                return index
            }
        }
        fatalError("ReaderViewQueue.findController should find \(reference)")
    }
}
