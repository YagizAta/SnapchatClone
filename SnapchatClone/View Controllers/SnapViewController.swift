//
//  SnapViewController.swift
//  SnapchatClone
//
//  Created by Yağız Ata Özkan on 31.03.2021.
//

import UIKit
import ImageSlideshow

class SnapViewController: UIViewController {

    @IBOutlet weak var timeLeft: UILabel!
    
    var selectedSnap : Snap?
    
    var inputArray = [KingfisherSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        if let snap = selectedSnap {
            
            timeLeft.text="Time Left \(snap.timeDifference)"
            for imageUrl in snap.imageUrlArray {
                inputArray.append(KingfisherSource(urlString: imageUrl)!)
                
            }
            
            let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width*0.95, height: self.view.frame.height*0.9))
            imageSlideShow.backgroundColor = UIColor.white
            
            let pageIndicator = UIPageControl()
            pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
            pageIndicator.pageIndicatorTintColor = UIColor.black
            imageSlideShow.pageIndicator = pageIndicator
            
            
            imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
            imageSlideShow.setImageInputs(inputArray)
           
            self.view.addSubview(imageSlideShow)
            self.view.bringSubviewToFront(timeLeft)
            
        }
        
        
       
    }


}
