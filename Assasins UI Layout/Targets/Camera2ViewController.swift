//
//  Camera2ViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 12/1/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit

class Camera2ViewController: UIViewController {

    var image:UIImage!
    @IBOutlet weak var imagePreview: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePreview.image = image
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionRetakePhoto(_ sender: Any) {
        //        CameraHandler.shared.camera()
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            self.imagePreview.image = image
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
