//
//  ViewController.swift
//  EinsteinVisionExample
//
//  Created by René Winkelmeyer on 15/03/2017.
//  Copyright © 2017 René Winkelmeyer. All rights reserved.
//

import UIKit
import SalesforceEinsteinVision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let travelScenes = ["Airplane interior", "Airport check-in", "Airport exterior", "Airport terminal",
                        "Highway", "Hotel lobby", "Hotel room", "Bus or train interior"]
    let swimScenes = ["Beach or shoreline", "Pool", "Natural water"]
    var currCategory = ""
    
    //var webView = UIWebView()
    
    @IBOutlet weak var rec1: UIButton!
    @IBOutlet weak var rec2: UIButton!
    @IBOutlet weak var rec3: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker: UIImagePickerController!

    @IBOutlet weak var analysisText: UITextView!
    
    @IBAction func takeAndAnalyzePhoto(_ sender: UIButton) {

        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true) {
            // After it is complete
        }
        
//        imagePicker =  UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
//        
//        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.analysisText.text = ""
        self.rec1.setTitle("", for: .normal)
        self.rec2.setTitle("", for: .normal)
        self.rec3.setTitle("", for: .normal)
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = chosenImage
            
            // convert UIImage to base64
            let imageData = UIImageJPEGRepresentation(chosenImage, 0.4)! as NSData
            let imageStr = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            // Initialize the service with a valid access token - CHANGE THIS OFTEN
            let service = PredictionService(bearerToken: "VFTC5TLQUAKY27K6YB45TYOKKZ2VZBSYWE5GZVFUDD6FRZ74YCKHTFOHL5OKRFJ536MU4MX4A36OY2XNR5QKEWGOGJAYC46HK4TRBPY")

            // Upload base64 for prediction on the Scene Classifier Model
            service?.predictBase64(modelId: "SceneClassifier", base64: imageStr, sampleId: "", completion: { (result) in
                var resultString = ""
                var probLabels = [String]()
                
                if (result != nil) {
//                    resultString = ((result?.probabilities!)?[0].label!)! // Get scene with highest probability
//                    self.handleScene(resultString: resultString)
                    //UIApplication.shared.open(URL(string: "http://www.rei.com")!) //opens safari
                    //self.webView.loadRequest(URLRequest(url: URL(string: "http://www.rei.com")!)) //opens in-app
                    if (result?.probabilities!)!.count < 3 {
                        for prob in (result?.probabilities!)! {
                            //resultString = resultString + prob.label! + " (" + String(prob.probability!) + ")\n"
                            probLabels.append(prob.label!)
                        }
                    }
                    else {
                        for i in 0 ..< 3 {
                            let prob = (result?.probabilities!)![i]
                            //resultString = resultString + prob.label! + " (" + String(prob.probability!) + ")\n"
                            probLabels.append(prob.label!)
                        }
                    }
                    self.generateRecs(probLabels: probLabels)
                } else {
                    resultString = "No data found"
                }
//                print(resultString)
//                self.analysisText.text = resultString
            })
        }
        else {
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func generateRecs(probLabels: [String]) {
        let probLabels = Array(Set(probLabels)) //make into a unique array
        var output = [String]()
        
        // generate rec output
        for label in probLabels {
            if travelScenes.contains(label) && !output.contains("travel clothing") && output.count <= 3 {
                output.append("travel clothing")
            }
            else if swimScenes.contains(label) && !output.contains("swimwear") && output.count <= 3 {
                output.append("paddling clothing")
                output.append("swimwear")
            }
        }
        
        // assign output text to respective button
        if output.count == 1 {
            self.rec1.setTitle(output[0], for: .normal)
            self.rec1.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
        }
        else if output.count == 2 {
            self.rec1.setTitle(output[0], for: .normal)
            self.rec1.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
            self.rec2.setTitle(output[1], for: .normal)
            self.rec2.addTarget(self, action: #selector(action(sender:)), for: UIControlEvents.touchUpInside)
        }
        else if output.count == 3 {
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
        
        //print(output)
    }
    
    func action(sender:UIButton!) {
        self.currCategory = (sender.titleLabel?.text)!
        self.performSegue(withIdentifier: "showDisplay", sender: self)
        
        
//        print("Button Clicked")
//        if sender.titleLabel?.text == "travel clothing" {
//            UIApplication.shared.open(URL(string: "https://www.rei.com/s/travel-clothing")!) //opens safari
//        }
//        else if sender.titleLabel?.text == "paddling clothing" {
//            UIApplication.shared.open(URL(string: "https://www.rei.com/c/paddling-clothing")!) //opens safari
//        }
//        else if sender.titleLabel?.text == "swimwear" {
//            UIApplication.shared.open(URL(string: "https://www.rei.com/c/swimwear")!) //opens safari
//        }
//        else {
//            print("Could not parse button text")
//        }
        
    }
    
    func handleScene(resultString: String) {
        if travelScenes.contains(resultString) {
            UIApplication.shared.open(URL(string: "https://www.rei.com/s/travel-clothing")!) //opens safari
        }
        else if swimScenes.contains(resultString) {
            UIApplication.shared.open(URL(string: "https://www.rei.com/c/swimwear")!) //opens safari
        }
        else {
            self.analysisText.text = "Error: could not recognize scene."
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.analysisText.isUserInteractionEnabled = false
        self.analysisText.isEditable = false
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

