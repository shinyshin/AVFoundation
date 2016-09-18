//
//  ViewController.swift
//  AVfoundationTest
//
//  Created by shinsungil on 2016. 9. 14..
//  Copyright © 2016년 shinsungil. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    // 캡쳐 세션
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    // 카메라 영상 미리보기
    var previewLayer : AVCaptureVideoPreviewLayer?
    var delegate : AVCaptureFileOutputRecordingDelegate?
    
    // 비디오 파일 저장관련 Class
    var fileOutput : AVCaptureMovieFileOutput!
    
    // 파일 저장 경로 변수
    var fileURL : NSURL?
    
    
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var stopBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // camera capture session
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            if(device.hasMediaType(AVMediaTypeVideo)){
                // check the position and confirm back camera
                print(device)
                if(device.position == AVCaptureDevicePosition.Back){
                    captureDevice = device as? AVCaptureDevice
                
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    // recording 버튼
    @IBAction func recordAction(sender: AnyObject) {
        
        fileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(fileOutput)
        delegate = self
        
        recordBtn.hidden = true
        stopBtn.hidden = false
        
        // dateFormatter를 사용하여 촬영시간을 파일명으로 한다.
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateTimePrefix: String = formatter.stringFromDate(NSDate())
        
        // 파일 저장 폴더 지정
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        var filePath: String? //video file path
        var fileNamePostfix = 0
        
        // 파일명 중복 확인
        repeat{
            filePath = "\(documentsDirectory)/\(dateTimePrefix)-\(fileNamePostfix).mp4"
            fileNamePostfix += 1
        } while (NSFileManager.defaultManager().fileExistsAtPath(filePath!))
        
        // 파일 경로는 NSURL 형식으로 지정
        fileURL = NSURL(fileURLWithPath: filePath!)
        // 지정 경로에 파일 저장 시작
        fileOutput.startRecordingToOutputFileURL(fileURL, recordingDelegate: delegate)
        
    }
    
    

    @IBAction func stopAction(sender: AnyObject) {
        fileOutput.stopRecording()
    }
    
    func focusTo(value : Float) {
        if let device = captureDevice {
            do{
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(value, completionHandler: {(time) -> Void in
                })
                device.unlockForConfiguration()
            } catch let error as NSError{
                print(error.code)
            }

        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let screenSize = previewLayer!.bounds.size
        let frameSize:CGSize = view.frame.size
        if let touchPoint = touches.first {
            
            let location:CGPoint = touchPoint.locationInView(self.view)
            
            let x = location.x / frameSize.width
            let y = 1.0 - (location.x / frameSize.width)
            
            let focusPoint = CGPoint(x: x, y: y)
            
            print("POINT : X: \(x), Y: \(y)")
            
            
            let captureDevice = (AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]).filter{$0.position == .Back}.first
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    
                    let support:Bool = device.focusPointOfInterestSupported
                    
                    if support  {
                        
                        print("focusPointOfInterestSupported: \(support)")
                        
                        device.focusPointOfInterest = focusPoint
                        
                        // device.focusMode = .ContinuousAutoFocus
                        device.focusMode = .AutoFocus
                        // device.focusMode = .Locked
                        
                        device.unlockForConfiguration()
                        
                        print("Focus point was set successfully")
                    }
                    else{
                        print("focusPointOfInterestSupported is not supported: \(support)")
                    }
                }
                catch {
                    // just ignore
                    print("Focus point error")
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
            print("\(touch)")
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first{
            print("\(touch)")
        }
        super.touchesMoved(touches, withEvent: event)
    }
    func beginSession() {
        
        configureDevice()
        
        try! captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        // Cannot invoke initializer for type 'AVCaptureDeviceInput' with an argument list of type '(device: AVCaptureDevice?, error: inout NSError?)'
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        self.view.bringSubviewToFront(self.view)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .AutoFocus
                device.unlockForConfiguration()
            } catch let error as NSError {
                print(error.code)
            }
        }
        
    }
    

    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("recording")
        print(captureOutput.recording)
        print(fileURL)
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("stop")
        print(captureOutput.recording)
        // didFinishRecordingToOutputFileAtURL 가 실행 될 때 performSegueWithIdentifier를 동작 시켜라
        self.performSegueWithIdentifier("stopRecording", sender: self.fileURL)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording"){
            // segue로 data를 넘길 view를 선택
            let playVideoVC = segue.destinationViewController as! PlayVideoViewController
            let fileURL = sender as! NSURL
            // video 가 저장되어 있는 경로를 playVideoViewController의 변수에 접근하여 path를 넣어줌
            playVideoVC.playFileURL = fileURL
        }
    }
    
    

  


}

