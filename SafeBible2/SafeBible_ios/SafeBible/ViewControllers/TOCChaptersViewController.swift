//
//  TOCChaptersViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/22/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class TOCChaptersViewController: AppViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    static func push(book: Book, controller: UIViewController?) {
        let chaptersController = TOCChaptersViewController(book: book)
        controller?.navigationController?.pushViewController(chaptersController, animated: true)
    }
    
    private let book: Book
    private var collectionView: UICollectionView!
    private var topAnchor: NSLayoutConstraint!
    private var botAnchor: NSLayoutConstraint!
    private var hiteAnchor: NSLayoutConstraint!
    private var centAnchor: NSLayoutConstraint!
    
    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("TOCChaptersViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit TOCChaptersViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = self.book.name
        let history = NSLocalizedString("History", comment: "Button to display History")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: history, style: .plain,
                                                                 target: self,
                                                                 action: #selector(historyHandler))
        
        let rect = self.view.bounds
        let width = (rect.width < rect.height) ? rect.width : rect.height
        let frame = CGRect(x: 0, y: 0, width: width, height: rect.height)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: ChapterNumCell.SIZE, height: ChapterNumCell.SIZE)
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        self.collectionView.register(ChapterNumCell.self, forCellWithReuseIdentifier: "ChapterNumCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = AppFont.backgroundColor
        self.view.addSubview(self.collectionView)
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        collectionView.widthAnchor.constraint(equalToConstant: width).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.topAnchor = collectionView.topAnchor.constraint(equalTo: self.view.topAnchor)
        self.botAnchor = collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        self.hiteAnchor = collectionView.heightAnchor.constraint(equalToConstant: height)
        self.centAnchor = collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustDimensions(note:)),
                                               name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
        
        self.adjustDimensions(note: nil)
    }
    
    @objc func historyHandler(sender: UIBarButtonItem) {
        HistoryViewController.push(controller: self)
    }
    
    @objc func adjustDimensions(note: NSNotification?) {
        let content = self.collectionView.collectionViewLayout.collectionViewContentSize
        
        if content.height > self.view.bounds.height {
            self.topAnchor.isActive = true
            self.botAnchor.isActive = true
            self.hiteAnchor.isActive = false
            self.centAnchor.isActive = false
        } else {
            self.topAnchor.isActive = false
            self.botAnchor.isActive = false
            self.hiteAnchor.isActive = true
            self.centAnchor.isActive = true
        }
    }
    
    //
    // UICollectionViewDataSource
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.book.lastChapter
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChapterNumCell",
                                                      for: indexPath as IndexPath) as! ChapterNumCell
        let chapter = indexPath.row + 1
        cell.label.text = String(chapter)
        let lastRef = HistoryModel.shared.current()
        if lastRef.bookId == self.book.bookId && lastRef.chapter == chapter {
            let alpha = AppFont.nightMode ? 0.3 : 1.0
            cell.label.backgroundColor = UIColor(red: 0.89, green: 0.98, blue: 0.96, alpha: CGFloat(alpha))
            cell.label.layer.masksToBounds = true
        }
        return cell
    }

    //
    // UICollectionViewDelegate
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chapter = indexPath.row + 1
        HistoryModel.shared.changeReference(bookId: self.book.bookId, chapter: chapter)
        NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                        object: HistoryModel.shared.current())
        self.navigationController?.popToRootViewController(animated: true)
    }
}

class ChapterNumCell : UICollectionViewCell {
    
    fileprivate static let SIZE: CGFloat = 50.0
    
    let label: UILabel
    
    override init(frame: CGRect) {
        let frame = CGRect(x: 0.0, y: 0.0, width: ChapterNumCell.SIZE, height: ChapterNumCell.SIZE)
        self.label = UILabel(frame: frame)
        self.label.textAlignment = .center
        self.label.layer.cornerRadius = ChapterNumCell.SIZE / 2
        self.label.layer.borderWidth = 2.0
        self.label.layer.borderColor = UIColor.init(white: 0.8, alpha: 1.0).cgColor
        self.label.textColor = UIColor(red: 0.24, green: 0.5, blue: 0.96, alpha: 1.0)

        super.init(frame: frame)
        self.contentView.addSubview(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

