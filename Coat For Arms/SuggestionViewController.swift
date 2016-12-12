//
//  ViewController.swift
//  CoatForArms
//
//  Created by Calvin So on 12/4/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

import UIKit

class SuggestionViewController: UIViewController {

    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var UpperImageIcon: UIImageView!
    @IBOutlet weak var LowerImageIcon: UIImageView!
    @IBOutlet weak var AccessoryImageIcon: UIImageView!
    
    var userRecs = [Recommendation]()
    var temperature : Float = 60.0
    var wind : Float = 0.0
    var weather: WeatherGetter!
    var index : Int = 0
    
    var rec : Recommendation = Recommendation(upper: "NONE", lower: "NONE", accessory: "NONE", minimumTemperature: 0, maximumTemperature: 0)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //print(temperature)
        //userRecs = initBaseRecs()
        if let savedRecs = loadRecs(){
            userRecs += savedRecs
        }
        else{
            userRecs = initBaseRecs()
        }
        temperature = temperature - wind/4
            let tempRec = getRec(temperature)
        if(tempRec != nil){
            rec = tempRec!
            UpperImageIcon.image = UIImage(named: GetImagePath(rec.upper))
            LowerImageIcon.image = UIImage(named: GetImagePath(rec.lower))
            AccessoryImageIcon.image = UIImage(named: GetImagePath(rec.accessory))
        }
        index = getRecIndex(temperature)!
        //Enable and disable this below to reset the values saved
        //userRecs = initBaseRecs()
        saveRecs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func GetImagePath(clothes : String) -> String{
        if(clothes == "Tank"){
            return "TankIcon.jpg"
        }
        else if(clothes == "T-Shirt"){
            return "TShirtIcon.jpeg"
        }
        else if(clothes == "Shirt"){
            return "ShirtIcon.jpeg"
        }
        else if(clothes == "Light Jacket" || clothes == "Jacket"){
            return "JacketIcon.jpeg"
        }
        else if(clothes == "Coat"){
            return "CoatIcon.jpeg"
        }
        else if(clothes == "Shorts"){
            return "ShortsIcon.jpeg"
        }
        else if(clothes == "Jeans/Pants"){
            return "JeansIcon.jpeg"
        }
        else if(clothes == "Beanie/Scarf"){
            return "ScarfIcon.png"
        }
        return ""
    }
    
    func updateRec(){
        let tempRec = getRec(temperature)
        index = getRecIndex(temperature)!
        if(tempRec != nil){
            rec = tempRec!
            UpperImageIcon.image = UIImage(named: GetImagePath(rec.upper))
            LowerImageIcon.image = UIImage(named: GetImagePath(rec.lower))
            AccessoryImageIcon.image = UIImage(named: GetImagePath(rec.accessory))
        }
    }

    @IBAction func SubmitRatingButton(sender: AnyObject) {
        let rating = ratingSlider.value
        print(userRecs.count)
        if (userRecs[index].maximumTemperature == 200.0){
            if(rating < 0){
                userRecs[index].modifyMin(-rating)
                userRecs[index + 1].maximumTemperature = userRecs[index].minimumTemperature
            }
        }
        else if (userRecs[index].minimumTemperature == -200.0){
            if(rating > 0){
                userRecs[index].modifyMax(-rating)
                userRecs[index - 1].minimumTemperature = userRecs[index].maximumTemperature
            }
        }
        else{
            if(rating < 0){
                userRecs[index].modifyMin(-rating)
                userRecs[index + 1].maximumTemperature = userRecs[index].minimumTemperature
            }
            else if(rating > 0){
                userRecs[index].modifyMax(-rating)
                userRecs[index - 1].minimumTemperature = userRecs[index].maximumTemperature

            }
        }
        updateRec()
        saveRecs()
        [self .dismissViewControllerAnimated(true, completion: nil)]

    }
    
    func initBaseRecs() -> [Recommendation]{
        var allRecs = [Recommendation]()
        var temp = Recommendation(upper: "Tank", lower: "Shorts", accessory: "", minimumTemperature: 80, maximumTemperature: 200)
        allRecs.append(temp!)
        temp = Recommendation(upper: "T-Shirt", lower: "Shorts", accessory: "", minimumTemperature: 70, maximumTemperature: 80)
        allRecs.append(temp!)
        temp = Recommendation(upper: "Shirt", lower: "Shorts", accessory: "", minimumTemperature: 60, maximumTemperature: 70)
        allRecs.append(temp!)
        temp = Recommendation(upper: "Light Jacket" , lower: "Jeans/Pants", accessory: "", minimumTemperature: 50, maximumTemperature: 60)
        allRecs.append(temp!)
        temp = Recommendation(upper: "Jacket", lower: "Jeans/Pants", accessory: "Beanie/Scarf", minimumTemperature: 40, maximumTemperature: 50)
        allRecs.append(temp!)
        temp = Recommendation(upper: "Coat", lower: "Jeans/Pants", accessory: "Beanie and Scarf", minimumTemperature: -200, maximumTemperature : 40)
        allRecs.append(temp!)
        return allRecs
    }
    
    func getRecIndex(Temperature: float_t) -> Int?{
        var i : Int = 0
        for recs in userRecs{
            if(recs.minimumTemperature <= Temperature && recs.maximumTemperature > Temperature){
                return i
            }
            i++
        }
        return nil
    }
    
    func getRec(Temperature: float_t) -> Recommendation?{
        for recs in userRecs {
            if(recs.minimumTemperature <= Temperature && recs.maximumTemperature > Temperature){
                return recs
            }
        }
        //If we get this return then the temperature was invalid
        return nil
    }
    
    //MARK: NSCoding
    
    func saveRecs(){
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(userRecs, toFile: Recommendation.ArchiveURL.path!)
        if !isSuccessfulSave {
            print ("Failed  to save any recs")
        }
    }
    
    func loadRecs() -> [Recommendation]?{
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Recommendation.ArchiveURL.path!) as? [Recommendation]
    }

}

