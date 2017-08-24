//
//  ViewController.swift
//  AudioPlayer
//
//  Created by Gary Griswold on 7/31/17.
//  Copyright © 2017 ShortSands. All rights reserved.
//

import UIKit
import AWS

class ViewController: UIViewController {
    
    let controller = AudioBibleViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.controller.view)
        //self.present(self.controller, animated: false, completion: nil)//{ print("AUDIOBIBLEVIEWCONTROLLER DONE") })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

