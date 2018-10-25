//
//  TOCChaptersViewController.swift
//  Settings
//
//  Created by Gary Griswold on 10/22/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class TOCChaptersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    private let book: Book
    private let size: CGFloat = 50.0
    
    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.book = Book(bookId: "JHN", ordinal: 22, name: "John", lastChapter: 28)
        super.init(coder: coder)
    }
    
    deinit {
        print("**** deinit TOCChaptersViewController ******")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = book.name
        let history = NSLocalizedString("History", comment: "Button to display History")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: history, style: .plain,
                                                                 target: self,
                                                                 action: #selector(historyHandler))
        
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ChapterNumCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        // Reposition collectionView to midview
        let height = collectionView.collectionViewLayout.collectionViewContentSize.height
        let blankSpace = (UIScreen.main.bounds.height - height) / 2.0
        collectionView.frame = CGRect(x: 0, y: blankSpace, width: self.view.bounds.width,
                                 height: self.view.bounds.height - blankSpace)
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
            label.backgroundColor = UIColor(red: 0.89, green: 0.98, blue: 0.96, alpha: 1.0)
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
        self.navigationController?.popToRootViewController(animated: true)
    }
}

