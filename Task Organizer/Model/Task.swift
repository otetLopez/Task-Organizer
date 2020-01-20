//
//  Task.swift
//  Task Organizer
//
//  Created by otet_tud on 1/19/20.
//  Copyright © 2020 otet_tud. All rights reserved.
//

import Foundation

class Task {
    var title : String
    var info : String
    var days : Int
    var used : Int
    //var date : String
    
    internal init(title: String, info: String, days: Int) {
        self.title = title
        self.info = info
        self.days = days
        self.used = 0
    }
    
    internal init(title: String, info: String, days: Int, used: Int) {
        self.title = title
        self.info = info
        self.days = days
        self.used = used
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getDays() -> Int {
        return self.days
    }
    
    func getDaysConsumed() -> Int {
        return self.used
    }
    
    func setDaysConsumed() {
        self.used += 1
    }
    
}