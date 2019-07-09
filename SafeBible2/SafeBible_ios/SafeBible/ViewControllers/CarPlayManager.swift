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
    private static let FAV_LIST = ["MAT", "MRK", "LUK", "JHN", "ACT", "EPH", "PHP", "PSA", "PRO" ]
    
    static func setUp() {
        MPPlayableContentManager.shared().dataSource = CarPlayManager.shared
        MPPlayableContentManager.shared().delegate = CarPlayManager.shared
    }
    
    private var historyLimit = CarPlayManager.HISTORY_LIMIT
    private var bibleId: String
    private var favoriteList: [String]
    
    private override init() {
        let curr = HistoryModel.shared.current()
        self.bibleId = curr.bibleId
        self.favoriteList = CarPlayManager.FAV_LIST
        
        super.init()
        _ = AudioBibleController.shared // Init AudioBibleController now
    }
    
    deinit {
        print("****** deinit CarPlayManager ******")
    }
    
    //
    // DataSource
    //
    func numberOfChildItems(at indexPath: IndexPath) -> Int {
        print("CarPlay: number Child Items called \(indexPath)  level: \(indexPath.count)")
        switch indexPath.count {
        case 0:
            return CarPlayManager.tabs.count
        case 1:
            switch indexPath[0] {
            case 0: return min(self.historyLimit, HistoryModel.shared.historyCount)
            case 1:
                return self.favoriteList.count
            default: return 0
            }
        default: return 0
        }
    }
    
    /** This is also being done by Toolbar, how we share with it? */
    private func buildFavoriteList(reference: Reference) -> String {
        let bible = reference.bible
        let controller = AudioBibleController.shared
        let bookIdList = controller.findAudioVersion(bibleId: reference.bibleId,
                                                     bibleName: bible.name,
                                                     iso3: bible.iso3,
                                                     audioBucket: bible.audioBucket,
                                                     otDamId: bible.otDamId,
                                                     ntDamId: bible.ntDamId)
        print("bookIdList \(bookIdList)")
        self.favoriteList = [String]()
        for item in CarPlayManager.FAV_LIST {
            if bookIdList.contains(item) {
                self.favoriteList.append(item)
            }
        }
        return reference.bibleId
    }
    
    func contentItem(forIdentifier identifier: String,
                     completionHandler: @escaping (MPContentItem?, Error?) -> Void) {
        print("CarPlay: Retrieve content item \(identifier)")
    }
    
    func childItemsDisplayPlaybackProgress(at indexPath: IndexPath) -> Bool {
        print("CarPlay: Ask if child items Display Progress at \(indexPath)")
        return true
    }
    
    func contentItem(at indexPath: IndexPath) -> MPContentItem? {
        print("CarPlay: content item called \(indexPath)")
        switch indexPath.count {
        case 1:
            let item = CarPlayManager.tabs[indexPath[0]]
            return loadCarPlayTab(ident: item[0], title: item[1], image: item[2])
        case 2:
            switch indexPath[0] {
            case 0:
                let index = HistoryModel.shared.historyCount - indexPath[1] - 1
                let ref = HistoryModel.shared.getHistory(row: index)
                let itemId = "\(ref.bibleId):\(ref.bookId):\(ref.chapter)"
                return loadCarPlayItem(ident: itemId, title: ref.description(),
                                       subtitle: ref.bible.name, cache: true)
            case 1:
                let bookId = self.favoriteList[indexPath[1]]
                let ref = Reference(bibleId: self.bibleId, bookId: bookId, chapter: 1)
                let hasCache = AudioBibleController.shared.hasCache(book: bookId, chapterNum: 1)
                let itemId = "\(ref.bibleId):\(ref.bookId):\(ref.chapter)"
                return loadCarPlayItem(ident: itemId, title: ref.description(),
                                       subtitle: ref.bible.name, cache: hasCache)
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
        print("CarPlay: initiate Playback of Content Item called \(indexPath)")
        if let item = self.contentItem(at: indexPath) {
            let parts = item.identifier.components(separatedBy: ":")
            let bibleId = parts[0]
            let bookId = parts[1]
            let chapter: Int = Int(parts[2]) ?? 1
            if bibleId != self.bibleId {
                let ref = Reference(bibleId: bibleId, bookId: bookId, chapter: chapter)
                self.bibleId = self.buildFavoriteList(reference: ref)
                HistoryModel.shared.changeReference(reference: ref)
            } else {
                HistoryModel.shared.changeReference(bookId: bookId, chapter: chapter)
            }
            AudioBibleController.shared.carPlayPlayer(book: bookId,
                                                      chapterNum: chapter,
                                                      start: true, complete: completionHandler)
        }
    }
    
    func playableContentManager(_ contentManager: MPPlayableContentManager,
                                didUpdate context: MPPlayableContentManagerContext) {
        print("CarPlay: update ContentManagerContext called")
        self.historyLimit = min(context.enforcedContentItemsCount, CarPlayManager.HISTORY_LIMIT)
        self.bibleId = self.buildFavoriteList(reference: HistoryModel.shared.current())
        
        // This is in lieu of AudioSession, which I might need to handle earphone connections
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playback,
                                    mode: AVAudioSession.Mode.spokenAudio,
                                    options: [])
            try session.setActive(true)
        } catch let err {
            print("Create Session Error \(err)")
        }
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
    
    private func loadCarPlayItem(ident: String, title: String, subtitle: String, cache: Bool) -> MPContentItem {
        let item = MPContentItem(identifier: ident)
        item.isContainer = false
        item.isExplicitContent = false
        item.isPlayable = true
        item.isStreamingContent = !cache
        item.playbackProgress = 0.0
        item.title = title
        item.subtitle = subtitle
        return item
    }
}
