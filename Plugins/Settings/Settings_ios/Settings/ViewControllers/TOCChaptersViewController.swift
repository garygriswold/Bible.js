//
//  TOCChaptersViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/22/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class TOCChaptersViewController: AppViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    private let book: Book
    private let size: CGFloat = 50.0
    
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
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ChapterNumCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = AppFont.backgroundColor
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let guide = UILayoutGuide()
        self.view.addLayoutGuide(guide)

        guide.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        guide.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        
        collectionView.widthAnchor.constraint(equalToConstant: width).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: guide.centerYAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
    }
    
    @objc func historyHandler(sender: UIBarButtonItem) {
        let historyController = HistoryViewController()
        self.navigationController?.pushViewController(historyController, animated: true)
    }
    
    //
    // UICollectionViewDataSource
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.book.lastChapter
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChapterNumCell",
                                                      for: indexPath as IndexPath)
        let chapter = indexPath.row + 1
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.size, height: self.size))
        label.textAlignment = .center
        label.text = String(chapter)
        label.textColor = UIColor(red: 0.24, green: 0.5, blue: 0.96, alpha: 1.0)
        
        label.bounds = CGRect(x: 0.0, y: 0.0, width: self.size, height: self.size)
        label.layer.cornerRadius = self.size / 2
        label.layer.borderWidth = 2.0
        label.layer.borderColor = UIColor.init(white: 0.8, alpha: 1.0).cgColor
        let lastRef = HistoryModel.shared.current()
        if lastRef.bookId == self.book.bookId && lastRef.chapter == chapter {
            let alpha = AppFont.nightMode ? 0.3 : 1.0
            label.backgroundColor = UIColor(red: 0.89, green: 0.98, blue: 0.96, alpha: CGFloat(alpha))
            label.layer.masksToBounds = true
        }
        cell.contentView.addSubview(label)
        return cell
    }
    
    //
    // UICollectionViewDelegateFlowLayout
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.size, height: self.size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 50, left: 20, bottom: 20, right: 20)
    }
    
    //
    // UICollectionViewDelegate
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chapter = indexPath.row + 1
        HistoryModel.shared.changeReference(book: self.book, chapter: chapter)
        NotificationCenter.default.post(name: ReaderPagesController.NEW_REFERENCE,
                                        object: HistoryModel.shared.current())
        self.navigationController?.popToRootViewController(animated: true)
    }
}

