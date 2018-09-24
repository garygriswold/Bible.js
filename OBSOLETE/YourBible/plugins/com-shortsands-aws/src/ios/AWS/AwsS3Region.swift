//
//  AwsS3Region.swift
//  AWS
//
//  Created by Gary Griswold on 4/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

import Foundation

public class AwsS3Region {
    
    let type: AWSRegionType
    let name: String
    
    init(type: AWSRegionType, name: String) {
        self.type = type
        self.name = name
    }
    deinit {
        print("****** deinit AwsS3Region ******")
    }
}
