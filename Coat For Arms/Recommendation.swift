//
//  Recommendation.swift
//  CoatForArms
//
//  Created by Calvin So 12/04/16
//  Copyright © 2016 nyu.edu. All rights reserved.
//

import UIKit

class Recommendation : NSObject, NSCoding {
    //MARK: Properties
    
    var upper : String
    var lower : String
    var accessory : String
    var minimumTemperature : float_t
    var maximumTemperature : float_t
    
    struct PropertyKey{
        static let upperKey = "upper"
        static let lowerKey = "lower"
        static let accessoryKey = "accessory"
        static let minKey = "minimumTemperature"
        static let maxKey = "maximumTemperature"
    }
    
    //MARK: Initialization
    init?( upper : String, lower : String, accessory: String, minimumTemperature : float_t, maximumTemperature : float_t){
        self.upper = upper
        self.lower = lower
        self.accessory = accessory
        self.minimumTemperature = minimumTemperature
        self.maximumTemperature = maximumTemperature
        
        super.init()
        
        
        //Init fails if no clothing is implemented
        if upper.isEmpty || lower.isEmpty{
            return nil
        }
    }
    
    //MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(upper, forKey: PropertyKey.upperKey)
        aCoder.encodeObject(lower, forKey: PropertyKey.lowerKey)
        aCoder.encodeObject(accessory, forKey: PropertyKey.accessoryKey)
        aCoder.encodeFloat(minimumTemperature, forKey: PropertyKey.minKey)
        aCoder.encodeFloat(maximumTemperature, forKey: PropertyKey.maxKey)
        
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let upper = aDecoder.decodeObjectForKey(PropertyKey.upperKey) as! String
        let lower = aDecoder.decodeObjectForKey(PropertyKey.lowerKey) as! String
        let accessory = aDecoder.decodeObjectForKey(PropertyKey.accessoryKey) as! String
        let minimumTemperature = aDecoder.decodeFloatForKey(PropertyKey.minKey)
        let maximumTemperature = aDecoder.decodeFloatForKey(PropertyKey.maxKey)
        self.init(upper: upper, lower: lower, accessory: accessory, minimumTemperature : minimumTemperature, maximumTemperature: maximumTemperature)
    }
    
    //MARK: Archiving Path
    static let DocumentsDirectory =
    NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("recommendations")

    //MARK: Modify will add the float given to it to the minmum/maximum temperatures to account for changes
    func modifyMin(change: float_t){
        self.minimumTemperature += change
        if self.minimumTemperature == self.maximumTemperature {
            self.minimumTemperature -= 0.1
        }
    }
    
    func modifyMax(change : float_t){
        self.maximumTemperature += change
        if self.maximumTemperature == self.minimumTemperature {
            self.maximumTemperature += 0.1
        }
    }
    
    //MARK: Shifts the entire set of temperatures this clothing is used at. Positive values will shift up, negative will shift down.
    func shiftRec(change : float_t){
        modifyMin(change)
        modifyMax(-change)
    }
    
    func toString() -> String{
        var printString : String
        printString = upper + " and " + lower + " with " + accessory + ": " + String(minimumTemperature) + " - " + String(maximumTemperature)
        return printString
    }
}

