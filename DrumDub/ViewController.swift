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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func selectTrack(sender: AnyObject!) {
    let picker = MPMediaPickerController(mediaTypes: .AnyAudio)
    picker.delegate = self
    picker.allowsPickingMultipleItems = false
    picker.prompt = "Choose a song"
    presentViewController(picker, animated: true, completion: nil)
  }

}

