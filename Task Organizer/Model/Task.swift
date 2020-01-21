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
    
    var date : String
    
    internal init(title: String, info: String, days: Int, date : String) {
        self.title = title
        self.info = info
        self.days = days
        self.used = 0
        self.date = date
    }
    
    internal init(title: String, info: String, days: Int, used: Int, date: String) {
        self.title = title
        self.info = info
        self.days = days
        self.used = used
        self.date = date
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
    
    func getInfo() -> String {
        return self.info
    }
    
    func getDateCreated() -> String {
        return self.date
    }
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func setInfo(info: String) {
        self.info = info
    }
    
    func setDays(days: Int) {
        self.days = days
    }
    
    func setDaysConsumed() {
        self.used += 1
    }
    

    
    
    
    
    
}
