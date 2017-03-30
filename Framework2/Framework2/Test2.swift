//
//  Test2.swift
//  Framework2
//
//  Created by Adolf Jurgens Freitas on 3/30/17.
//  Copyright © 2017 Adolf Jurgens Freitas. All rights reserved.
//

import Framework1

public class Test2 {
    public init() {}
    
    public func test() -> String {
        let testFramework1 = Test1()
        
        return testFramework1.test() + " test2"
    }
}

