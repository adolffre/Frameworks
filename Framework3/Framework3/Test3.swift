//
//  Test3.swift
//  Framework3
//
//  Created by Adolf Jurgens Freitas on 3/30/17.
//  Copyright © 2017 Adolf Jurgens Freitas. All rights reserved.
//

import Framework1
import Framework2

public class Test3 {
    
    public init() {}
    
    public func test() -> String {
        let testFramework1 = Test1()
        let testFramework2 = Test2()
        return testFramework1.test() + " " + testFramework2.test()
    }
    
}
