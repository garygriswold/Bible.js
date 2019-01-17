//
//  ReaderToolbar.swift
//  Settings
//
//  Created by Gary Griswold on 10/30/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit
import AudioPlayer

class ReaderToolbar {
    
    private weak var controller: ReaderPagesController?
    private weak var navigationController: UINavigationController?
    
    private var audioBookIdSet: Set<Substring>!
    private var historyBack: UIBarButtonItem!
    private var tocBookLabel: UILabel!
    private var tocChapLabel: UILabel!
    private var versionLabel: UILabel!
    private var audioPlayer: UIBarButtonItem!
    
    init(controller: ReaderPagesController) {
        self.controller = controller
        self.navigationController = controller.navigationController
        
        if let nav = self.navigationController {
            
            nav.toolbar.isTranslucent = false
            nav.toolbar.barTintColor = AppFont.backgroundColor
        }
        
        let reference = HistoryModel.shared.current()
        self.audioBookIdSet = Set(self.findAudioVersion(ref: reference).split(separator: ","))
        
        var items = [UIBarButtonItem]()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let menuImage = UIImage(named: "www/images/ui-menu.png")
        let menu = UIBarButtonItem(image: menuImage, style: .plain, target: self,
                                   action: #selector(menuTapHandler))
        items.append(menu)
        items.append(spacer)
        
        let priorImage = UIImage(named: "www/images/ios-previous.png")
        self.historyBack = UIBarButtonItem(image: priorImage, style: .plain, target: self,
                                           action: #selector(historyTapHandler))
        self.historyBack.isEnabled = HistoryModel.shared.hasBack()
        items.append(self.historyBack)
        items.append(spacer)
        
        self.tocBookLabel = toolbarLabel(width: 80, action: #selector(tocBookHandler))
        let tocBook = UIBarButtonItem(customView: self.tocBookLabel)
        items.append(tocBook)
        items.append(spacer)
        
        self.tocChapLabel = toolbarLabel(width: 22, action: #selector(tocChapHandler))
        let tocChap = UIBarButtonItem(customView: self.tocChapLabel)
        items.append(tocChap)
        items.append(spacer)
        
        self.versionLabel = toolbarLabel(width: 38, action: #selector(versionTapHandler))
        let version = UIBarButtonItem(customView: self.versionLabel)
        items.append(version)
        items.append(spacer)
        
        let audioImage = UIImage(named: "www/images/mus-vol-med.png")
        self.audioPlayer = UIBarButtonItem(image: audioImage, style: .plain, target: self,
                                           action: #selector(audioTapHandler))
        self.audioPlayer.isEnabled = self.audioBookIdSet.contains(Substring(reference.bookId))
        items.append(self.audioPlayer)
        items.append(spacer)
        
        let composeImage = UIImage(named: "www/images/ios-new.png")
        let compose = UIBarButtonItem(image: composeImage, style: .plain, target: self,
                                      action: #selector(composeTapHandler))
        items.append(compose)
        items.append(spacer)
        
        let searchImage = UIImage(named: "www/images/ios-search.png")
        let search = UIBarButtonItem(image: searchImage, style: .plain, target: self,
                                     action: #selector(searchTapHandler))
        items.append(search)
        self.controller!.setToolbarItems(items, animated: true)
    }
    
    func refresh() {
        if let nav = self.navigationController {
            nav.toolbar.barTintColor = AppFont.backgroundColor
        }
        let background = AppFont.nightMode ? UIColor(white: 0.20, alpha: 1.0) :
            UIColor(white: 0.95, alpha: 1.0)
        self.tocBookLabel.backgroundColor = background
        self.tocChapLabel.backgroundColor = background
        self.versionLabel.backgroundColor = background
    }
    
    func loadBiblePage(reference: Reference) {
        self.tocBookLabel.frame = CGRect(x: 0, y: 0, width: 80, height: 32) // prevents fields running together
        self.tocBookLabel.text = reference.bookName
        self.tocChapLabel.text = String(reference.chapter)
        self.versionLabel.text = reference.abbr
        self.historyBack.isEnabled = HistoryModel.shared.hasBack()
        self.audioPlayer.isEnabled = self.audioBookIdSet.contains(Substring(reference.bookId))
    }
    
    @objc func menuTapHandler(sender: UIBarButtonItem) {
        SettingsViewController.push(settingsViewType: .primary, controller: self.controller, language: nil)
    }
    
    @objc func historyTapHandler(sender: UIBarButtonItem) {
        HistoryViewController.push(controller: self.controller)
    }
    
    @objc func tocBookHandler(sender: UIBarButtonItem) {
        TOCBooksViewController.push(controller: self.controller)
    }
    
    @objc func tocChapHandler(sender: UIBarButtonItem) {
        if let book = HistoryModel.shared.currBook {
            TOCChaptersViewController.push(book: book, controller: self.controller)
        }
    }
    
    @objc func versionTapHandler(sender: UIBarButtonItem) {
        BiblesActionSheet.present(controller: self.controller)
    }
    
    @objc func audioTapHandler(sender: UIBarButtonItem) {
        let audioController = AudioBibleController.shared
        if audioController.isPlaying() {
            audioController.dismiss()
        } else {
            let ref = HistoryModel.shared.current()
            audioController.present(view: self.controller!.view, book: ref.bookId, chapterNum: ref.chapter,
                complete: { error in
                    // No error is actually being returned
                    if let err = error {
                        print("Audio Player Error \(err)")
                    } else {
                        print("Audio Player success")
                    }
                }
            )
        }
    }
    
    // This func is a placeholder until it is properly placed
    private func isPlayingAudioController() -> Bool {
        return AudioBibleController.shared.isPlaying()
    }
    
    private func findAudioVersion(ref: Reference) -> String {
        let audioController = AudioBibleController.shared
        let bookIdList = audioController.findAudioVersion(bibleId: ref.bibleId, iso3: ref.bible.iso3,
                                                          audioBucket: ref.bible.audioBucket,
                                                          otDamId: ref.bible.otDamId,
                                                          ntDamId: ref.bible.ntDamId)
        print("bookIdList \(bookIdList)")
        return bookIdList
    }

    // This func is a placeholder until it is properly placed
    private func stopAudioController() {
        AudioBibleController.shared.stop()
    }
    
    @objc func composeTapHandler(sender: UIBarButtonItem) {
        NotesListViewController.push(controller: self.controller)
    }
    
    @objc func searchTapHandler(sender: UIBarButtonItem) {
        print("search button handler")
    }
    
    private func toolbarLabel(width: CGFloat, action: Selector) -> UILabel {
        let frame = CGRect(x: 0, y: 0, width: width, height: 32)
        let label = UILabel(frame: frame)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        if AppFont.nightMode {
            label.backgroundColor = UIColor(white: 0.20, alpha: 1.0)
        } else {
            label.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        }
        label.textColor = UIColor(red: 0.24, green: 0.5, blue: 0.96, alpha: 1.0)
        let gesture = UITapGestureRecognizer(target: self, action: action)
        gesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(gesture)
        label.isUserInteractionEnabled = true
        return label
    }
}
