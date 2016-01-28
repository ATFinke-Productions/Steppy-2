//
//  STPYColor.swift
//  SwiftSteppy
//
//  Created by Andrew Finke on 12/21/14.
//  Copyright (c) 2014 Andrew Finke. All rights reserved.
//

import UIKit

extension UIColor {
    
    /**
    Gets the color components of the color
    
    - returns: The components
    */
    func rgbComponents() -> (red : CGFloat, green : CGFloat, blue : CGFloat) {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha){
            return(red,green,blue)
        }
        return(0,0,0)
    }
    
    /**
    Creates a color with a mix between two other colors
    
    - parameter currentColor: The main color
    - parameter nextColor: The next color
    - parameter mix: The progress from the main color to the next color
    */
    convenience init(_ currentColor : UIColor,_ nextColor : UIColor, mix : CGFloat) {
        let currentComponents = currentColor.rgbComponents()
        let nextComponents = nextColor.rgbComponents()
        let red = (nextComponents.red - currentComponents.red) * mix + currentComponents.red
        let green = (nextComponents.green - currentComponents.green) * mix + currentComponents.green
        let blue = (nextComponents.blue - currentComponents.blue) * mix + currentComponents.blue
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /**
    An array of the standard graph view controller background colors
    
    - returns: The array of colors
    */
    class func backgroundColors() -> [UIColor] {
        var colors = [UIColor(red: 0.203922, green: 0.286275, blue: 0.368627, alpha: 1.000000), UIColor(red: 0.752941, green: 0.223529, blue: 0.168627, alpha: 1.000000), UIColor(red: 0.556863, green: 0.266667, blue: 0.678431, alpha: 1.000000), UIColor(red: 0.172549, green: 0.243137, blue: 0.313726, alpha: 1.000000), UIColor(red: 0.152941, green: 0.682353, blue: 0.376471, alpha: 1.000000), UIColor(red: 0.160784, green: 0.501961, blue: 0.725490, alpha: 1.000000), UIColor(red: 0.905882, green: 0.298039, blue: 0.235294, alpha: 1.000000), UIColor(red: 0.901961, green: 0.494118, blue: 0.133333, alpha: 1.000000), UIColor(red: 0.607843, green: 0.349020, blue: 0.713726, alpha: 1.000000), UIColor(red: 0.827451, green: 0.329412, blue: 0.000000, alpha: 1.000000), UIColor(red: 0.203922, green: 0.596078, blue: 0.858824, alpha: 1.000000)]
        /*
        for i in 0..<(colors.count - 1) {
            let j = Int(arc4random_uniform(UInt32(colors.count - i))) + i
            swap(&colors[i], &colors[j])
        }*/
        return colors
    }
}