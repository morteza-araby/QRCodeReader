//
//  ViewController.swift
//  QRCodeReader
//
//  Created by admin on 2016-10-27.
//  Copyright © 2016 Moteza Araby. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeframView: UIView?
    
    @IBOutlet weak var qLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var openURL: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        cancelBtn.isHidden = true
        qLabel.isHidden = true
        openURL.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func scanMe(_ sender: AnyObject) {
        
        cancelBtn.isHidden = false
        qLabel.isHidden = false
        openURL.isHidden = false
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        let input: AnyObject?
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        if (error != nil){
            print("\(error?.localizedDescription)")
            return
        }
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
        
        //put label on top
        view.bringSubview(toFront: qLabel)
        view.bringSubview(toFront: cancelBtn)
        view.bringSubview(toFront: openURL)
        
        qrCodeframView = UIView()
        qrCodeframView?.layer.borderColor = UIColor.green.cgColor
        qrCodeframView?.layer.borderWidth = 2
        view.addSubview(qrCodeframView!)
        view.bringSubview(toFront: qrCodeframView!)
        
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeframView?.frame = CGRect.zero
            qLabel.text = "No QR code detected"
            return
        }
        
        let metadateObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadateObj.type == AVMetadataObjectTypeQRCode {
            let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadateObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeframView?.frame = barcodeObject.bounds
            
            if metadateObj.stringValue != nil {
                qLabel.text = metadateObj.stringValue
                
                captureSession?.stopRunning()
            }
        }
        
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        
        cancelBtn.isHidden = true
        qLabel.isHidden = true
        openURL.isHidden = true
        
        captureSession?.stopRunning()
        qrCodeframView?.removeFromSuperview()
        videoPreviewLayer?.removeFromSuperlayer()
        
    }
    
    @IBAction func openURL(_ sender: AnyObject) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "passData") {
            let wvc = segue.destination as! WebViewController
            
            wvc.QRLink = qLabel.text
        }
    }
}

