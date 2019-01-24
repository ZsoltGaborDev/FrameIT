//
//  Creation.swift
//  FrameIT
//
//  Created by zsolt on 17/01/2019.
//  Copyright © 2019 zsolt. All rights reserved.
//

import Foundation
import UIKit

class Creation {
    var image: UIImage
    var unicorn: UIImage
    var colorSwatch: ColorSwatch
    
    static var defaultImage: UIImage {
        return UIImage.init(named: "FrameIT-placeholder")!
    }
    static var defaultUnicorn: UIImage {
        return UIImage.init(named: "Unicorn")!
    }
    static var defaultColorSwatch: ColorSwatch {
        return ColorSwatch (caption: "Simply Yellow ", color: .yellow)
    }

    init() {
        //stored property initialization
        image = Creation.defaultImage
        unicorn = Creation.defaultUnicorn
        colorSwatch = Creation.defaultColorSwatch
    }
    
    convenience init(colorSwatch: ColorSwatch?) {
        self.init()
        //stored property initialization
        if let userColorSwatch = colorSwatch {
            self.colorSwatch = userColorSwatch
        }
    }
    
    func reset(colorSwatch: ColorSwatch?) {
        image = Creation.defaultImage
        unicorn = Creation.defaultUnicorn
        if let userColorSwatch = colorSwatch {
            self.colorSwatch = userColorSwatch
        }
        else {
            self.colorSwatch = Creation.defaultColorSwatch
        }
    }
}
