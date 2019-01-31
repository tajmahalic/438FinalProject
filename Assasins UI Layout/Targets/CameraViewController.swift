//
//  Camera2ViewController.swift
//  Assasins UI Layout
//
//  Created by Eliot Tong on 12/1/18.
//  Copyright © 2018 CSE438. All rights reserved.
//

import UIKit
//import Firebase
import CoreImage

class CameraViewController: UIViewController {

    var image:UIImage!
    var game:Game!
    var targetName:String!
    var hasFace:Bool!
    
    var target: AssassinPlayer!
    
    @IBOutlet weak var imagePreview: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        hasFace = false
        imagePreview.image = image
        detect()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func actionKill(_ sender: Any) {
        var titleText = "Failed"
        var messageText = "Not A Face"
        var buttonText = "Retry"
        if hasFace {
            titleText = "Successful"
            messageText = ""
            buttonText = "OK"
            
            let userPlayer = AssassinPlayer(id: UserClass.CurrentUserID, isActive: true, curKills: 0, username: UserClass.CurrentUsername, name: UserClass.CurrentName)
            
            game.killPlayer(target: target, killer: userPlayer)
            
//            self.uploadImage(self.image, completion: {(hasFinished, url) in
//                if(hasFinished) {
////                    let currUser = Auth.auth().currentUser!
////                    let data = ["killee": self.targetName, "killer": currUser.uid, "picString": url, "status": "unconfirmed"] as [String : Any]
////                    let unicId = CFUUIDCreateString(nil, CFUUIDCreate(nil))
////                    Database.database().reference().child("games").child(self.self.game).child("kills").child(String(unicId!)).setValue(data)
//
//                }
//            })
        }
        let alert = UIAlertController(title: "Assassination " + titleText, message: messageText, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: buttonText, style: UIAlertActionStyle.default)
        {
            (UIAlertAction) -> Void in
            if self.hasFace{
                self.performSegue(withIdentifier: "unwindSegueToTargets", sender: self)
            }
            
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true)
        {
            () -> Void in
        }

    }
    
//        func uploadImage(_ image: UIImage,
//                         completion: @escaping (_ hasFinished: Bool, _ url: String) -> Void) {
//            let data: Data = UIImageJPEGRepresentation(image, 1.0)!
//            let unicId = CFUUIDCreateString(nil, CFUUIDCreate(nil))
//            // ref should be like this
//            let ref = Storage.storage().reference(withPath: "kills/" + game + "/" + String(unicId!))
//            ref.putData(data, metadata: nil,
//                        completion: { (meta , error) in
//                            if error == nil {
//                                // return url
//                                completion(true, (meta?.path)!)
//                            } else {
//                                print(error)
//                                completion(false, "")
//                            }
//            })
//        }
    
    func detect() {
        hasFace = false
        for view in imagePreview.subviews {
            view.removeFromSuperview()
        }
        guard let personciImage = CIImage(image: imagePreview.image!) else {
            return
        }
        
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: personciImage)
        
        // For converting the Core Image Coordinates to UIView Coordinates
        let ciImageSize = personciImage.extent.size
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
        
        for face in faces as! [CIFaceFeature] {
            hasFace = true
            print("Found bounds are \(face.bounds)")
            
            // Apply the transform to convert the coordinates
            var faceViewBounds = face.bounds.applying(transform)
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = imagePreview.bounds.size
            let scale = min(viewSize.width / ciImageSize.width,
                            viewSize.height / ciImageSize.height)
            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
            
            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
            faceViewBounds.origin.x += offsetX
            faceViewBounds.origin.y += offsetY
            
            let faceBox = UIView(frame: faceViewBounds)
            
            faceBox.layer.borderWidth = 3
            faceBox.layer.borderColor = UIColor.red.cgColor
            faceBox.backgroundColor = UIColor.clear
            imagePreview.addSubview(faceBox)
            
            if face.hasLeftEyePosition {
                print("Left eye bounds are \(face.leftEyePosition)")
            }
            
            if face.hasRightEyePosition {
                print("Right eye bounds are \(face.rightEyePosition)")
            }
        }
    }

    
        
        
    
//    func uploadMedia(completion: @escaping (_ url: String?) -> Void) {
//        let storageRef = Storage.storage().reference().child("myImage.png")
//        if let uploadData = UIImagePNGRepresentation(self.myImageView.image!) {
//            storageRef.put(uploadData, metadata: nil) { (metadata, error) in
//                if error != nil {
//                    print("error")
//                    completion(nil)
//                } else {
//                    completion((metadata?.downloadURL()?.absoluteString)!))
//                    // your uploaded photo url.
//                }
//            }
//        }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
