//
//  VideoViewController.swift
//  SafeBible
//
//  Created by Gary Griswold on 1/12/19.
//  Copyright © 2019 ShortSands. All rights reserved.
//
import UIKit
import VideoPlayer

class VideoViewController: AppTableViewController, UITableViewDataSource {
    
    static func push(iso3: String, controller: UIViewController?) {
        let videoController = VideoViewController(iso3: iso3)
        controller?.navigationController?.pushViewController(videoController, animated: true)
    }
    
    private let iso3: String
    private let dataModel: VideoModel
    private var videoPlayer: VideoViewPlayer?
    
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
        let video = self.dataModel.selected[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoDescriptionCell", for: indexPath) as! VideoDescriptionCell
        cell.contentView.backgroundColor = AppFont.backgroundColor
        cell.title.text = video.title
        cell.title.textColor = AppFont.textColor
        cell.descr.text = video.description
        cell.descr.textColor = AppFont.textColor
        let image = UIImage(named: "www/images/\(video.mediaId).jpg")
        cell.photo.image = image
        //cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //
    // Delegate
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = self.dataModel.selected[indexPath.row]
        self.videoPlayer = VideoViewPlayer(mediaSource: video.mediaSource,
                                 videoId: video.mediaId,
                                 languageId: video.languageId,
                                 silLang: self.iso3,
                                 videoUrl: video.HLS_URL)
        self.videoPlayer!.begin(complete: { error in
            if error != nil {
                print("ERROR: VideoViewPlayer.begin \(error!)")
            } else {
                print("Video completed")
            }
        })
        self.present(self.videoPlayer!.controller, animated: true, completion: nil)
    }
}

class VideoDescriptionCell : UITableViewCell {
    
    let photo = UIImageView()
    let title = UILabel()
    let descr = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(self.photo)
        
        self.title.font = AppFont.sansSerif(style: .caption1)
        self.contentView.addSubview(self.title)
        
        self.descr.numberOfLines = 0
        self.descr.font = AppFont.serif(style: .body)
        self.contentView.addSubview(self.descr)
        
        let inset = self.contentView.frame.width * 0.05
        
        let vue = self.contentView
        //let aspectRatio = (self.imageView!.image!.size.width / self.imageView!.image!.size.height)
        let aspectRatio: CGFloat = 0.80
        self.photo.translatesAutoresizingMaskIntoConstraints = false
        self.photo.topAnchor.constraint(equalTo: vue.topAnchor, constant: inset).isActive = true
        self.photo.leadingAnchor.constraint(equalTo: vue.leadingAnchor, constant: inset).isActive = true
        self.photo.trailingAnchor.constraint(equalTo: vue.trailingAnchor, constant: -inset).isActive = true
        self.photo.heightAnchor.constraint(equalTo: self.photo.widthAnchor,
                                                multiplier: aspectRatio).isActive = true

        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.title.topAnchor.constraint(equalTo: self.photo.bottomAnchor, constant: inset).isActive = true
        self.title.leadingAnchor.constraint(equalTo: vue.leadingAnchor, constant: inset).isActive = true
        
        self.descr.translatesAutoresizingMaskIntoConstraints = false
        self.descr.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: inset / 2.0).isActive = true
        self.descr.leadingAnchor.constraint(equalTo: vue.leadingAnchor, constant: inset).isActive = true
        self.descr.trailingAnchor.constraint(equalTo: vue.trailingAnchor, constant: -inset).isActive = true
        self.descr.bottomAnchor.constraint(equalTo: vue.bottomAnchor, constant: -inset).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("VideoDescriptionCell(coder:) is not implemented.")
    }
    
    deinit {
        print("**** deinit VideoDescriptionCell ******")
    }
}

