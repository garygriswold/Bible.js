//
//  AwsS3Region.swift
//  AWS
//
//  Created by Gary Griswold on 4/17/18.
//  Copyright © 2018 ShortSands. All rights reserved.
//

public struct AwsS3Region {
    
    let type: AWSRegionType
    let name: String
    
    init(name: String) {
        self.type = name.aws_regionTypeValue()
        self.name = name
    }
}


