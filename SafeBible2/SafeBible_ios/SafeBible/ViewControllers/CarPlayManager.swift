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
    
    private static let tabs = [
        ["recents", "Recents", "ios-recents"],
        ["favorites", "Favorites", "ios-favorites"]
    ]
    
    private static var HISTORY_LIMIT = 5
    private var historyLimit = 0
    
    private static let playList = [
        ["MAT", "Matthew", "Gospel According to Matthew"],
        ["MRK", "Mark", "Gospel According to Mark"],
        ["LUK", "Luke", "Gospel According to Luke"],
        ["JHN", "John", "Gospel According to John"],
        ["ACT", "Acts", "Acts of the Apostles"],
        ["EPH", "Ephesians", "Letter to the Ephesians"],
        ["PHP", "Philippians", "Letter to the Philippians"],
        ["PSA", "Psalms", "Psalms of David"],
        ["PRO", "Proverbs", "The Book of Proverbs"]
    ]
    
    static func setUp() {
        MPPlayableContentManager.shared().dataSource = CarPlayManager.shared
        MPPlayableContentManager.shared().delegate = CarPlayManager.shared
    }
    
    private override init() {
        super.init()
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "Hear Holy Bible"
        ]
        //AudioControlCenter.shared.getIcon() // from prototype
        let controlCenter = MPRemoteCommandCenter.shared()
        controlCenter.playCommand.isEnabled = true
        controlCenter.playCommand.addTarget(handler: { event in
            return .success
        })
        controlCenter.stopCommand.isEnabled = true
        controlCenter.stopCommand.addTarget(handler: { event in
            return .success
        })
        controlCenter.nextTrackCommand.isEnabled = false
        controlCenter.previousTrackCommand.isEnabled = false
    }
    
    deinit {
        print("****** deinit CarPlayManager ******")
    }
    
    //
    // DataSource
    //
    func numberOfChildItems(at indexPath: IndexPath) -> Int {
        print("CarPlay number Child Items called \(indexPath)  count: \(indexPath.count)")
        switch indexPath.count {
        case 0: return CarPlayManager.tabs.count
        case 1:
            switch indexPath[0] {
            case 0: return min(self.historyLimit, HistoryModel.shared.historyCount)
            case 1: return CarPlayManager.playList.count
            default: return 0
            }
        default: return 0
        }
    }
    
    func contentItem(forIdentifier identifier: String,
                     completionHandler: @escaping (MPContentItem?, Error?) -> Void) {
        print("Retrieve content item \(identifier)")
    }
    
//    func beginLoadingChildItems(at indexPath: IndexPath,
//                                completionHandler: @escaping (Error?) -> Void) {
//        print("Starts load of item at \(indexPath)")
//    }
    
    func childItemsDisplayPlaybackProgress(at indexPath: IndexPath) -> Bool {
        print("Ask if child items Display Progress")
        return true
    }
    
    func contentItem(at indexPath: IndexPath) -> MPContentItem? {
        print("CarPlay content item called")
        switch indexPath.count {
        case 1:
            let item = CarPlayManager.tabs[indexPath[0]]
            return loadCarPlayTab(ident: item[0], title: item[1], image: item[2])
        case 2:
            switch indexPath[0] {
            case 0:
                let item = HistoryModel.shared.getHistory(row: indexPath[1])
                return loadCarPlayItem(ident: item.nodeId(), title: item.description(),
                                       subtitle: item.bible.name)
            case 1:
                let item = CarPlayManager.playList[indexPath[1]]
                return loadCarPlayItem(ident: item[0], title: item[1], subtitle: item[2])
            default:
                return nil
            }
        default: return nil
        }
    }
    
    //
    // Delegate
    //
    func playableContentManager(_ contentManager: MPPlayableContentManager,
                                initiatePlaybackOfContentItemAt indexPath: IndexPath,
                                completionHandler: @escaping (Error?) -> Void) {
        print("initiate CarPlay Playback of Content Item called \(indexPath)")
        completionHandler(nil)
    }
    
    func playableContentManager(_ contentManager: MPPlayableContentManager,
                                didUpdate context: MPPlayableContentManagerContext) {
        print("update CarPlay ContentManagerContext called")
        self.historyLimit = min(context.enforcedContentItemsCount, CarPlayManager.HISTORY_LIMIT)
    }
    
    private func loadCarPlayTab(ident: String, title: String, image: String) -> MPContentItem {
        let item = MPContentItem(identifier: ident)
        item.isContainer = true
        item.isExplicitContent = false
        item.isPlayable = false
        item.isStreamingContent = false
        item.title = title
        if let image = UIImage(named: image) {
            item.artwork = MPMediaItemArtwork(boundsSize: image.size,
                                              requestHandler: { _ in return image
            })
        }
        return item
    }
    
    private func loadCarPlayItem(ident: String, title: String, subtitle: String) -> MPContentItem {
        let item = MPContentItem(identifier: ident)
        item.isContainer = false
        item.isExplicitContent = false
        item.isPlayable = true
        item.isStreamingContent = true
        item.playbackProgress = 0.0
        item.title = title
        item.subtitle = subtitle
        return item
    }
}

