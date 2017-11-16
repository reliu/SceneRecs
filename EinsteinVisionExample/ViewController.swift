//
//  ViewController.swift
//  EinsteinVisionExample
//
//  Created by Renee Liu on 11/15/17.
//  Copyright © 2017 René Winkelmeyer. All rights reserved.
//

import UIKit
import SalesforceEinsteinVision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let travelScenes = ["Airplane interior", "Airport check-in", "Airport exterior", "Airport terminal",
                        "Highway", "Hotel lobby", "Hotel room", "Bus or train interior"]
    let swimScenes = ["Beach or shoreline", "Pool", "Natural water"]
    var currCategory = ""

    @IBOutlet weak var recHeader: UITextView!
    @IBOutlet weak var rec1: UIButton!
    @IBOutlet weak var rec2: UIButton!
    @IBOutlet weak var rec3: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var analysisText: UITextView!
    
    @IBAction func takeAndAnalyzePhoto(_ sender: UIButton) {
        
        // Get photo

        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true) {
            // After it is complete
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Reset text views
        self.analysisText.text = ""
        self.recHeader.text = ""
        self.rec1.setTitle("", for: .normal)
        self.rec2.setTitle("", for: .normal)
        self.rec3.setTitle("", for: .normal)
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = chosenImage
            
            // convert UIImage to base64
            let imageData = UIImageJPEGRepresentation(chosenImage, 0.4)! as NSData
            let imageStr = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            // Initialize the service with a valid access token - UPLOAD BEARER TOKEN
            let service = PredictionService(bearerToken: "B7Z6U3QVNR5PUEQQJ6RRKSR3FQ3S5UWD6KU62SLXTTW72ER4EAXPMDET3MITKU35LWHSITOSLA4MPPBZTEKKA7NHRGJYAJVJ4NKSMBA")

            // Upload base64 for prediction on the Scene Classifier Model
            service?.predictBase64(modelId: "SceneClassifier", base64: imageStr, sampleId: "", completion: { (result) in
                var probLabels = [String]()
                // Save scene probabilities
                if (result != nil) {
                    if (result?.probabilities!)!.count < 3 {
                        for prob in (result?.probabilities!)! {
                            probLabels.append(prob.label!)
                        }
                    }
                    else {
                        for i in 0 ..< 3 {
                            let prob = (result?.probabilities!)![i]
                            probLabels.append(prob.label!)
                        }
                    }
                    self.generateRecs(probLabels: probLabels)
                } else {
                    self.analysisText.text = "No data found"
                }
            })
        }
        else {
            self.analysisText.text = "Error choosing image"
            print("Error choosing image")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func generateRecs(probLabels: [String]) {
        let probLabels = Array(Set(probLabels)) // Make into a unique array
        var output = [String]()
        
        // Categorize scenes into apparel categories
        for label in probLabels {
            if travelScenes.contains(label) && !output.contains("travel clothing") && output.count <= 3 {
                output.append("travel clothing")
            }
            else if swimScenes.contains(label) && !output.contains("swimwear") && output.count <= 3 {
                output.append("paddling clothing")
                output.append("swimwear")
            }
        }
        
        // Assign output text to respective button
        if output.count == 1 {
            self.recHeader.text = "Choose a category:"
            self.rec1.setTitle(output[0], for: .normal)
            self.rec1.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
        }
        else if output.count == 2 {
            self.recHeader.text = "Choose a category:"
            self.rec1.setTitle(output[0], for: .normal)
            self.rec1.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
            self.rec2.setTitle(output[1], for: .normal)
            self.rec2.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
        }
        else if output.count == 3 {
            self.recHeader.text = "Choose a category:"
            self.rec1.setTitle(output[0], for: .normal)
            self.rec1.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
            self.rec2.setTitle(output[1], for: .normal)
            self.rec2.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
            self.rec3.setTitle(output[2], for: .normal)
            self.rec3.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
        }
        else {
            self.analysisText.text = "Error: no recommendations for this photo"
        }
        
    }
    
    func action(sender:UIButton!) {
        // Prepare data for segue
        self.currCategory = (sender.titleLabel?.text)!
        self.performSegue(withIdentifier: "showDisplay", sender: self)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make text read-only
        self.analysisText.isUserInteractionEnabled = false
        self.analysisText.isEditable = false
        self.recHeader.isUserInteractionEnabled = false
        self.recHeader.isEditable = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToView(segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDisplay" {
            if let navController = segue.destination as? UINavigationController {
                if let controller = navController.topViewController as? DisplayController {
                    controller.currCategory = self.currCategory
                }
            }
            
            
        }
    }

}

