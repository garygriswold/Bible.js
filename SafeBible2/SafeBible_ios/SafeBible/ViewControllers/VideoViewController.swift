//
//  VideoViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 1/12/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//
import UIKit

class VideoViewController: AppTableViewController, UITableViewDataSource {
    
    static func push(iso3: String, controller: UIViewController?) {
        let videoController = VideoViewController(iso3: iso3)
        controller?.navigationController?.pushViewController(videoController, animated: true)
    }
    
    private let iso3: String
    private let dataModel: VideoModel
    
    init(iso3: String) {
        self.iso3 = iso3
        self.dataModel = VideoModel(iso3: iso3)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("VideoViewController(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit VideoViewController ******")
    }
    
    override func loadView() {
        super.loadView()
        
        self.navigationItem.title = NSLocalizedString("Videos", comment: "Title of Videos page")
        
        // Along with auto layout, these are the keys for enabling variable cell height
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.tableView.register(VideoDescriptionCell.self, forCellReuseIdentifier: "videoDescriptionCell")
        self.tableView.dataSource = self
    }

    //
    // DataSource
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.selected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let video = dataModel.selected[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoDescriptionCell", for: indexPath) as! VideoDescriptionCell
        cell.contentView.backgroundColor = AppFont.backgroundColor
        cell.title.text = video.title
        cell.title.textColor = AppFont.textColor
        cell.descript.text = video.description
        cell.descript.textColor = AppFont.textColor
        let image = UIImage(named: "www/images/\(video.mediaId).jpg")
        cell.imageView!.image = image
        //cell.image =
        //cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("NOT YET IMPLEMENTED, must play video.")
    }
}

class VideoDescriptionCell : UITableViewCell {
    
    let title = UILabel()
    let descript = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.title.font = AppFont.sansSerif(style: .caption1)
        self.contentView.addSubview(self.title)
        
        self.descript.numberOfLines = 0
        self.descript.font = AppFont.serif(style: .body)
        self.contentView.addSubview(self.descript)
        
        let inset = self.contentView.frame.width * 0.05
        
        let vue = self.contentView
        //let aspectRatio = (self.imageView!.image!.size.width / self.imageView!.image!.size.height)
        let aspectRatio: CGFloat = 0.80
        self.imageView!.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.topAnchor.constraint(equalTo: vue.topAnchor, constant: inset).isActive = true
        self.imageView!.leadingAnchor.constraint(equalTo: vue.leadingAnchor, constant: inset).isActive = true
        self.imageView!.trailingAnchor.constraint(equalTo: vue.trailingAnchor, constant: -inset).isActive = true
        self.imageView!.heightAnchor.constraint(equalTo: self.imageView!.widthAnchor,
                                                multiplier: aspectRatio).isActive = true
        // skip bottom anchor
        
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.title.topAnchor.constraint(equalTo: self.imageView!.bottomAnchor, constant: inset).isActive = true
        self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: inset).isActive = true
        
        self.descript.translatesAutoresizingMaskIntoConstraints = false
        
        self.descript.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: inset / 2.0).isActive = true
        self.descript.leadingAnchor.constraint(equalTo: vue.leadingAnchor, constant: inset).isActive = true
        self.descript.trailingAnchor.constraint(equalTo: vue.trailingAnchor, constant: -inset).isActive = true
        self.descript.bottomAnchor.constraint(equalTo: vue.bottomAnchor, constant: -inset).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("VideoDescriptionCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit VideoDescriptionCell ******")
    }
}

