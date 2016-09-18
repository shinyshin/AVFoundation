//
//  PlayVideoViewController.swift
//  AVfoundationTest
//
//  Created by shinsungil on 2016. 9. 16..
//  Copyright © 2016년 shinsungil. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PlayVideoViewController: UIViewController {
    
    // 파일 재생 Class 선언
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    
    
    // 파일 저장 경로
    var playFileURL : NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getVideoList()
    }
    
    func getVideoList(){
        let fileManager = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0]
        print(dirPaths, docsDir)
        if fileManager.fileExistsAtPath(docsDir){
           let files = fileManager.enumeratorAtPath(docsDir)
            while let file = files?.nextObject(){
                print(file)
            }
            
        }else{
            print("No Video")
        }
    }

    @IBAction func playbackAction(sender: AnyObject) {
        playerView = AVPlayer(URL: playFileURL!)
        playerViewController.player = playerView
        
        // 새로운 뷰를 불러와 비디오 재생
        self.presentViewController(playerViewController, animated: true){
            self.playerViewController.player?.play()
        }
    }
}
