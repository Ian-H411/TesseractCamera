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
            var rectangle = CGRect(x: view.frame.height, y: view.frame.minY, width: view.frame.width, height: view.frame.height / 22)
            rectangle.origin = CGPoint(x: 0, y: (view.frame.height/2) - rectangle.height)
        
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
        videoPreviewLayer?.videoGravity = .resize
        videoPreviewLayer?.connection?.videoOrientation = .portrait
        guard let videoPreviewLayer = videoPreviewLayer else {return}
        let drawnRectangle = Draw(frame: guideRectangle!)
        
       view.layer.insertSublayer(videoPreviewLayer, at: 0)
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
        var cropArea = CGRect(x:0, y: 0, width: image.size.height / 8, height: image.size.width)
        cropArea.origin = CGPoint(x: (image.size.width/2) - image.size.width, y: 0)
//        cropArea.size.width *= image.scale
//        cropArea.size.height *= image.scale
//        cropArea.origin.x *= image.scale
//        cropArea.origin.y *= image.scale

        startTesseract(image: image)
       
    }
    
    
    @IBAction func takeAPicButtonTapped(_ sender: Any) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    
    func startTesseract(image:UIImage){
        tesseract.delegate = self
        tesseract.charWhitelist = "ABCDEFGHJKLMNPRSTUVWXYZ1234567890"
        guard var guideRectangle = guideRectangle else {return}
        guideRectangle.size.width = image.size.width
        guideRectangle.size.height = image.size.height/22
                guideRectangle.origin.x *= image.scale
                guideRectangle.origin.y *= image.scale
        guideRectangle.origin.y += 470
        tesseract.image = image
        tesseract.rect = guideRectangle
        
        tesseract.sourceResolution = 300
        tesseract.recognize()
        DispatchQueue.main.async {
            self.imagePreview.image = self.tesseract.thresholdedImage
        }
        outputlabel.text = tesseract.recognizedText
   
    }
    func rotateRect(_ rect: CGRect) -> CGRect {
        let x = rect.minX
        let y = rect.minY
        let transform = CGAffineTransform(translationX: -x, y: -y)
                            .rotated(by: .pi / 2)
                            .translatedBy(x: x, y: y)
        return rect.applying(transform)
    }

}


extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
