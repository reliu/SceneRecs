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
    //var webView = UIWebView()
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
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = chosenImage
            
            // convert UIImage to base64
            let imageData = UIImageJPEGRepresentation(chosenImage, 0.4)! as NSData
            let imageStr = imageData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            // Initialize the service with a valid access token - CHANGE THIS OFTEN
            let service = PredictionService(bearerToken: "IVHH6KEIDDH7WBWZ5UR7UBMBBAXBWRVZW5PAXCWYJGEV6RRL7KHRCNA26635AJ2W26MJ42RKRKT5ROIUNXCU442BRXYGLORQVW7WHMI")

            // Upload base64 for prediction on the Scene Classifier Model
            service?.predictBase64(modelId: "SceneClassifier", base64: imageStr, sampleId: "", completion: { (result) in
                var resultString = ""
                
                if (result != nil) {
                    resultString = ((result?.probabilities!)?[0].label!)! // Get scene with highest probability
                    print(resultString)
                    self.handleScene(resultString: resultString)
                    //UIApplication.shared.open(URL(string: "http://www.rei.com")!) //opens safari
                    //self.webView.loadRequest(URLRequest(url: URL(string: "http://www.rei.com")!)) //opens in-app
//                    for prob in (result?.probabilities!)! {
//                        resultString = resultString + prob.label! + " (" + String(prob.probability!) + ")\n"
//                    }
                } else {
                    resultString = "No data found"
                }
                
                //self.analysisText.text = resultString
            })

        }
        else {
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func handleScene(resultString: String) {
        if travelScenes.contains(resultString) {
            UIApplication.shared.open(URL(string: "https://www.rei.com/s/travel-clothing")!) //opens safari
        }
        else if swimScenes.contains(resultString) {
            UIApplication.shared.open(URL(string: "https://www.rei.com/c/womens-swimwear")!) //opens safari
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

