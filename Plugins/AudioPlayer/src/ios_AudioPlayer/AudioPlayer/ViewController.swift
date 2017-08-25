//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let audioController = AudioBibleController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioController.present(view: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

