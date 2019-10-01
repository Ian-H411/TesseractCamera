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
import CoreGraphics

class ViewController: UIViewController, G8TesseractDelegate, AVCapturePhotoCaptureDelegate {
    let tesseract: G8Tesseract = G8Tesseract(language: "eng")
    
    var isTesseractEnabled:Bool = false
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBOutlet weak var outputlabel: UILabel!
    
    var session: AVCaptureSession?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var stillImageOutput: AVCapturePhotoOutput!

 
    
    var guideRectangle:CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("running ocr")
        imagePreview.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        session = AVCaptureSession()

        guard let backCamera = AVCaptureDevice.default(for: .video)
            else {
                print("no camera")
                return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            let dimensions = CMVideoFormatDescriptionGetDimensions(input.device.activeFormat.formatDescription)
            let rectangle = CGRect(x: view.frame.width, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
        
            guideRectangle = rectangle
            if session!.canAddInput(input) && session!.canAddOutput(stillImageOutput){
                session!.addInput(input)
                session!.addOutput(stillImageOutput)
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
        let drawnRectangle = Draw(frame: guideRectangle!)
        
        view.layer.addSublayer(videoPreviewLayer)
        DispatchQueue.main.async {
            self.session?.startRunning()
            self.videoPreviewLayer?.frame = self.view.frame
            self.view.addSubview(drawnRectangle)
    
        }
        
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {return}
        guard let image = UIImage(data: imageData) else {return}
        imagePreview.isHidden = false
        guard let imageToFeedReference = image.cgImage?.cropping(to: guideRectangle!) else {return}
        let imagetofeed = UIImage(cgImage: imageToFeedReference)
        startTesseract(image: imagetofeed)
    }
    
    
    @IBAction func takeAPicButtonTapped(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    func startTesseract(image:UIImage){
        tesseract.delegate = self
        tesseract.charWhitelist = "ABCDEFGHJKLMNPRSTUVWXYZ1234567890"
        
        tesseract.image = image
        tesseract.rect = guideRectangle!
        tesseract.sourceResolution = 300
        tesseract.recognize()
        DispatchQueue.main.async {
            self.imagePreview.image = self.tesseract.image
        }
        outputlabel.text = tesseract.recognizedText
   
    }

}

