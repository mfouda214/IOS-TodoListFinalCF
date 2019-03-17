//
//  globalConstant.swift
//  toDoList
//
//  Created by Mohamed Sobhi  Fouda on 2/15/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import Foundation
import UIKit

// Configuration

// Parse APP ID & Client Key
let PARSE_APP_ID = "MtlrhltcEHPIiBllkGCKcal4rkpip2G3nkEo0Gze"
let PARSE_CLIENT_KEY = "vCwEdAflLjsh88lZZbkmrWBKkFdAYFep8kYlKTk4"

// To Enable or Disable Admob (true or false)
let admobEnable = true
// Admob App ID (Example: "ca-app-pub-2975668811067685/1240224784")
let admobAppId = "ca-app-pub-3940256099942544~2934735716"
// Admob banner Ad Unit (Example: "ca-app-pub-2975668811067685/1240224784")
let admobAdUnit = "ca-app-pub-3940256099942544/2934735716"

// Base Color (Example : UIColor(netHex: 0xA71A5B) )
let baseColor = UIColor(netHex: 0xA71A5B)

// Done & TODO Status Color
let todoColor = UIColor(netHex: 0xA71A5B)
let doneColor = UIColor(netHex: 0x00743F)

// Navigation Bar Color
let navigationBarTintColor = UIColor.white

// TabBar Tint Color
let tabBarTintColor = baseColor

// Category TODO
let categoryList = ["Home","Work","Personel","Others"]

// font medium
let font18base = UIFont(name: "SFUIText-Medium", size: 18)
let font34base = UIFont(name: "SFUIText-Medium", size: 34)

// font regular
let font16regular = UIFont(name: "SFUIText-Regular", size: 16)
let font18regular = UIFont(name: "SFUIText-Regular", size: 18)
let font34regular = UIFont(name: "SFUIText-Regular", size: 34)





extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
