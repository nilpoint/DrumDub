//
//  ViewController.swift
//  DrumDub
//
//  Created by John Alstru on 9/8/15.
//  Copyright (c) 2015 nilpoint.sample. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
  
  var musicPlayer: MPMusicPlayerController {
    if musicPlayer_Lazy == nil {
      musicPlayer_Lazy = MPMusicPlayerController()
      musicPlayer_Lazy?.shuffleMode = .Off
      musicPlayer_Lazy?.repeatMode = .None
      
      let center = NSNotificationCenter.defaultCenter()
      center.addObserver(self, selector: "playbackStateDidChange:", name: MPMusicPlayerControllerPlaybackStateDidChangeNotification, object: musicPlayer_Lazy)
      center.addObserver(self, selector: "playingItemDidChange:", name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: musicPlayer_Lazy)
      
      musicPlayer_Lazy!.beginGeneratingPlaybackNotifications()
    }
    return musicPlayer_Lazy!
  }
  private var musicPlayer_Lazy: MPMusicPlayerController?
  
  let soundNames = ["snare", "bass", "tambourine", "maraca"]
  var players = [AVAudioPlayer]()
  
  @IBOutlet var playButton: UIBarButtonItem!
  @IBOutlet var pauseButton: UIBarButtonItem!
  @IBOutlet var albumView: UIImageView!
  @IBOutlet var songLabel: UILabel!
  @IBOutlet var albumLabel: UILabel!
  @IBOutlet var artistLabel: UILabel!
  
  // MARK - User Action
  
  @IBAction func selectTrack(sender: AnyObject!) {
    let picker = MPMediaPickerController(mediaTypes: .AnyAudio)
    picker.delegate = self
    picker.allowsPickingMultipleItems = false
    picker.prompt = "Choose a song"
    presentViewController(picker, animated: true, completion: nil)
  }
  
  @IBAction func play(sender: AnyObject!) {
    musicPlayer.play()
  }
  
  @IBAction func pause(sender: AnyObject!) {
    musicPlayer.stop()
  }
  
  @IBAction func bang(sender: AnyObject!) {
    if let button = sender as? UIButton {
      let index = button.tag - 1
      if index >= 0 && index < players.count {
        let player = players[index]
        player.pause()
        player.currentTime = 0.0
        player.play()
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    activateAudioSession()
    let center = NSNotificationCenter.defaultCenter()
    center.addObserver(self, selector: "audioInterruption:", name: AVAudioSessionInterruptionNotification, object: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK - Notification
  
  func playbackStateDidChange(notification: NSNotification) {
    let playing = (musicPlayer.playbackState == .Playing)
    playButton!.enabled = !playing
    pauseButton!.enabled = playing
  }
  
  func playingItemDidChange(notification: NSNotification) {
      let nowPlaying = musicPlayer.nowPlayingItem
      
      var albumImage: UIImage!
      if let artwork = nowPlaying?.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
        albumImage = artwork.imageWithSize(albumView.bounds.size)
      }
      if albumImage == nil {
        albumImage = UIImage(named: "noartwork")
      }
      albumView.image = albumImage
      
      songLabel.text = nowPlaying?.valueForProperty(MPMediaItemPropertyTitle) as? String
      albumLabel.text = nowPlaying?.valueForProperty(MPMediaItemPropertyAlbumTitle) as? String
      artistLabel.text = nowPlaying?.valueForProperty(MPMediaItemPropertyArtist) as? String
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
  
  // MARK - AVAudioPlayer helper
  
  func createAudioPlayers() {
    destroyAudioPlayers()
    for soundName in soundNames {
      if let soundURL = NSBundle.mainBundle().URLForResource(soundName, withExtension: "m4a") {
        let player = AVAudioPlayer(contentsOfURL: soundURL, error: nil)
        player.prepareToPlay()
        players.append(player)
      }
    }
  }
  
  func destroyAudioPlayers() {
    players = []
  }
  
  func activateAudioSession() {
    let active = AVAudioSession.sharedInstance().setActive(true, error: nil)
    if active {
      if players.count == 0 {
        createAudioPlayers()
      }
    } else {
      destroyAudioPlayers()
    }
    for i in 0..<soundNames.count {
      if let button = view.viewWithTag(i+1) as? UIButton {
        button.enabled = active
      }
    }
  }
  
  func audioInterruption(notification: NSNotification) {
    if let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber {
      // Prior to Swift version 1.2 
//      if let type = AVAudioSessionInterruptionType.fromRaw(typeValue.unsignedLongValue) {
      // Swift version 1.2
      if let type = AVAudioSessionInterruptionType(rawValue: typeValue.unsignedLongValue) {
        switch type {
        case .Began:
          for player in players {
            player.pause()
          }
          break;
        case .Ended:
          activateAudioSession()
          break;
        }
      }
    }
  }
}

