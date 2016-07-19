//
//  VideoPlayer.swift
//  Alfredo
//
//  Created by Nick Lee on 8/11/15.
//  Copyright (c) 2015 TENDIGI, LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public protocol VideoPlayerDelegate: class {

    /**
    A method called when the player finishes looping

    - parameter player: The player that triggered the event

    */
    func playerFinished(_ player: VideoPlayer)

    /**
    A method called as the video player's progress advances

    - parameter player: The player that triggered the progress event
    - parameter progress: The current progress of the player

    */
    func playerProgressed(_ player: VideoPlayer, progress: Float)
}

public final class VideoPlayer: UIView {

    // MARK: Properties

    /// A boolean representing whether or not the content has loaded
    public private(set) var loaded: Bool = false

    /// The object that acts as the delegate for the video player
    public weak var delegate: VideoPlayerDelegate?

    /// Whether or not the player is playing
    public var playing: Bool {
        if let p = player {
            return p.rate > 0
        }
        return false
    }

    /// Whether or not the player is muted
    public var muted: Bool {
        get {
            return player?.isMuted ?? false
        }
        set {
            player?.isMuted = newValue
        }
    }

    // MARK: Private Properties

    private var player: AVPlayer?
    private var timeObserver: AnyObject?
    private let playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        return layer
        }()

    // MARK: Constants

    private struct VideoPlayerConstants {
        static let ProgressTimeInterval = CMTimeMakeWithSeconds(1.0 / 60.0, 44100)
    }

    // MARK: Initialization

    /**
    Initializes and returns a newly allocated video player view object with the specified frame rectangle.

    - parameter frame: The frame rectangle for the video player, measured in points.

    - returns: An initialized video player object

    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.addSublayer(playerLayer)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        removeTimeObserver()
    }

    // MARK: Player Config

    /// Whether the player allows switching to external playback mode.
    public var allowsExternalPlayback: Bool {
        set {
            player?.allowsExternalPlayback = newValue
        } get {
            return (player?.allowsExternalPlayback ?? false)
        }
    }

    /// Whether the player should automatically switch to external playback mode while the external screen mode is active in order to play video content.
    public var usesExternalPlaybackWhileExternalScreenIsActive: Bool {
        set {
            player?.usesExternalPlaybackWhileExternalScreenIsActive = newValue
        } get {
            return (player?.usesExternalPlaybackWhileExternalScreenIsActive ?? false)
        }
    }

    private func configurePlayerWithItem(_ item: AVPlayerItem) {

        NotificationCenter.default.removeObserver(self)

        if let thePlayer = player {
            thePlayer.replaceCurrentItem(with: item)
        } else {
            player = AVPlayer(playerItem: item)
            playerLayer.player = player
        }

        NotificationCenter.default.addObserver(self, selector: #selector(VideoPlayer.playbackEnded(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)

    }

    // MARK: Playback

    /// Unloads the currently loaded asset (if necessary)
    public func unload() {
        player?.replaceCurrentItem(with: nil)
        loaded = false
    }

    /**
    Loads an asset at the passed URL

    - parameter url: The url of the asset to load
    - parameter loops: The number of times the asset's playback should loop

    */
    public func load(_ url: URL, loops: Int = 1) {
        let asset = AVURLAsset(url: url, options: [ AVURLAssetPreferPreciseDurationAndTimingKey: true ])
        let composition = AVMutableComposition(asset: asset, loops: loops)
        let playerItem = AVPlayerItem(asset: composition)
        configurePlayerWithItem(playerItem)
        loaded = true

    }

    /// Plays the loaded asset
    public func play() {
        if let thePlayer = player {

            if playing {
                return
            }

            if thePlayer.status == .readyToPlay {
                removeTimeObserver()
                thePlayer.play()
                thePlayer.addPeriodicTimeObserver(forInterval: VideoPlayerConstants.ProgressTimeInterval, queue: DispatchQueue.main, using: playbackTimeChanged)
            }
        }
    }

    /// Rewinds the player to the beginning of its player item
    public func rewind() {
        player?.seek(to: kCMTimeZero)
    }

    /// Pauses the currently playing asset (if necessary)
    public func pause() {
        if playing {
            player?.pause()
            removeTimeObserver()
        }
    }

    // MARK: Progress

    private func removeTimeObserver() {
        if let o: AnyObject = timeObserver {
            player?.removeTimeObserver(o)
            timeObserver = nil
        }
    }

    private func playbackTimeChanged(_ time: CMTime) {
        if let item = player?.currentItem {
            let durationSeconds = CMTimeGetSeconds(item.duration)
            let currentSeconds = CMTimeGetSeconds(time)
            let progress = Float(currentSeconds / durationSeconds)
            delegate?.playerProgressed(self, progress: progress)
        }
    }

    // MARK: Notifications

    private dynamic func playbackEnded(_ note: Notification) {
        delegate?.playerFinished(self)
    }

    // MARK: Layout

    /// :nodoc:
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

}
