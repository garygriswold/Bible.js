//
//  CarPlayManager.swift
//  SafeBible
//
//  Created by Gary Griswold on 5/23/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//

import Foundation
import MediaPlayer
import AudioPlayer

class CarPlayManager : NSObject, MPPlayableContentDataSource, MPPlayableContentDelegate {
    
    static var shared = CarPlayManager()
    
    static func setUp() {
        MPPlayableContentManager.shared().dataSource = CarPlayManager.shared
        MPPlayableContentManager.shared().delegate = CarPlayManager.shared
        // Crashes if title is not initialized.
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "Hear Holy Bible"
        ]
    }
    
    private override init() {
        super.init()
    }
    
    deinit {
        print("****** deinit CarPlayManager ******")
    }
    
    
    //
    // DataSource
    //
    func numberOfChildItems(at indexPath: IndexPath) -> Int {
        print("CarPlay number Child Items called")
        return 0
    }
    
    func contentItem(forIdentifier identifier: String,
                     completionHandler: @escaping (MPContentItem?, Error?) -> Void) {
        print("Retrieve content item \(identifier)")
    }
    
    func beginLoadingChildItems(at indexPath: IndexPath,
                                completionHandler: @escaping (Error?) -> Void) {
        print("Starts load of item at \(indexPath)")
    }
    
    func childItemsDisplayPlaybackProgress(at indexPath: IndexPath) -> Bool {
        print("Ask if child items Display Progress")
        return false
    }
    
    func contentItem(at indexPath: IndexPath) -> MPContentItem? {
        print("CarPlay content item called")
        return nil
    }
    
    //
    // Delegate
    //
    func playableContentManager(_ contentManager: MPPlayableContentManager,
                                initiatePlaybackOfContentItemAt indexPath: IndexPath,
                                completionHandler: @escaping (Error?) -> Void) {
        print("initiate CarPlay Playback of Content Item called")
    }
    
    func playableContentManager(_ contentManager: MPPlayableContentManager,
                                didUpdate context: MPPlayableContentManagerContext) {
        print("update CarPlay ContentManagerContext called")
        
        let ref = HistoryModel.shared.current()
        AudioBibleController.shared.carPlayPlayer(book: ref.bookId, chapterNum: ref.chapter)
    }
}

