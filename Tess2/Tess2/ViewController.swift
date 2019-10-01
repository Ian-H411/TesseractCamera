//
//  ViewController.swift
//  Tess2
//
//  Created by Ian Hall on 9/30/19.
//  Copyright © 2019 Ian Hall. All rights reserved.
//

import UIKit
import TesseractOCR
import AVFoundation

class ViewController: UIViewController, G8TesseractDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let tesseract: G8Tesseract = G8Tesseract(language: "eng")
    
    var isTesseractEnabled:Bool = false
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var outputlabel: UILabel!
    
    var session: AVCaptureSession?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCapturePhotoOutput!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("running ocr")
                
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        session = AVCaptureSession()
        session?.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: .video)
            else {
                print("no camera")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if session!.canAddInput(input) && session!.canAddOutput(stillimageoutput){
                session!.addInput(input)
                session!.addOutput(stillimageoutput)
                setUpLivePreview()
            }
        } catch  {
            print("there was an error in \(#function) :\(error) : \(error.localizedDescription)")
        }
        
        
    }
    func shouldCancelImageRecognition(for tesseract: G8Tesseract!) -> Bool {
        isTesseractEnabled
    }
    func setUpLivePreview(){
        guard let session = session else {return}
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.videoGravity = .resizeAspect
        videoPreviewLayer?.connection?.videoOrientation = .portrait
        guard let videoPreviewLayer = videoPreviewLayer else {return}
        view.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.main.async {
            self.session?.startRunning()
            self.videoPreviewLayer?.frame = self.view.bounds
        }
        
    }
    
    
    @IBAction func takeAPicButtonTapped(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: <#T##AVCapturePhotoSettings#>, delegate: <#T##AVCapturePhotoCaptureDelegate#>)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage{
      
            startTesseract(image: pickedImage)
        }
         picker.dismiss(animated: true, completion: nil)
    }
    func startTesseract(image:UIImage){
        tesseract.delegate = self
    
        tesseract.image = image
        tesseract.recognize()
        outputlabel.text = tesseract.recognizedText
   
    }

}

