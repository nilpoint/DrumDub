//
//  ViewController.swift
//  DrumDub
//
//  Created by John Alstru on 9/8/15.
//  Copyright (c) 2015 nilpoint.sample. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
  
  var musicPlayer: MPMusicPlayerController {
    if musicPlayer_Lazy == nil {
      musicPlayer_Lazy = MPMusicPlayerController()
      musicPlayer_Lazy?.shuffleMode = .Off
      musicPlayer_Lazy?.repeatMode = .None
    }
    return musicPlayer_Lazy!
  }
  private var musicPlayer_Lazy: MPMusicPlayerController?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK - MPMediaPickerControllerDelegate
  func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
    if let songChoices = mediaItemCollection {
      if songChoices.count != 0 {
        musicPlayer.setQueueWithItemCollection(songChoices)
        musicPlayer.play()
      }
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK - User Action
  
  @IBAction func selectTrack(sender: AnyObject!) {
    let picker = MPMediaPickerController(mediaTypes: .AnyAudio)
    picker.delegate = self
    picker.allowsPickingMultipleItems = false
    picker.prompt = "Choose a song"
    presentViewController(picker, animated: true, completion: nil)
  }

}

