//
//  ViewController.swift
//  AWS_Testharness
//
//  Created by Gary Griswold on 4/6/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let awsS3UnitTest = AwsS3UnitTest2()
        awsS3UnitTest.testDriver()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

