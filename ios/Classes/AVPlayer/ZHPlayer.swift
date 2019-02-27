import UIKit
import AVKit

@objc public protocol ZHPlayerDelegate: NSObjectProtocol {
    @objc optional func playerReady(_ player: ZHPlayer)
    @objc optional func playerPlaybackStateDidChange(_ player: ZHPlayer)
    @objc optional func playerBufferingStateDidChange(_ player: ZHPlayer)
    @objc optional func playerBufferTimeDidChange(_ bufferTime: TimeInterval)
    @objc optional func playerCurrentTimeDidChange(_ player: ZHPlayer)
    @objc optional func playerPlaybackDidEnd(_ player: ZHPlayer)
}

private extension ZHPlayer {
    struct PlayerKey {
        static let tracks = "tracks"
        static let playable = "playable"
        static let duration = "duration"
        static let rate = "rate"
        static let status = "status"
        static let emptyBuffer = "playbackBufferEmpty"
        static let keepUp = "playbackLikelyToKeepUp"
        static let loadedTime = "loadedTimeRanges"
    }
}

public class ZHPlayer: NSObject {
    
    public enum PlaybackState: String, CustomStringConvertible {
        case stopped,playing,pause,fail
        public var description: String {
            return self.rawValue
        }
    }
    
    public enum BufferingState: String, CustomStringConvertible {
        case unknown
        case playable
        case through
        case stalled
        public var description: String {
            return self.rawValue
        }
    }
    
    public weak var delegate: ZHPlayerDelegate?
    
    public var playbackState: ZHPlayer.PlaybackState = .stopped {
        didSet {
            guard playbackState != oldValue else { return }
            self.delegate?.playerPlaybackStateDidChange?(self)
        }
    }
    
    public var bufferingState: ZHPlayer.BufferingState = .unknown {
        didSet {
            guard bufferingState != oldValue else { return }
            self.delegate?.playerBufferingStateDidChange?(self)
        }
    }

    public var url: URL? {
        didSet {
            guard let url = url else { return }
            validateAsset(AVAsset(url: url))
        }
    }
    
    public let view = ZHPlayerView(frame: CGRect.zero)
    
    public var autoplay: Bool = true
    
    public var pausesWhenResigningActive: Bool = true
    
    public var pausesWhenBackgrounded: Bool = true
    
    public var resumesWhenBecameActive: Bool = true
    
    public var resumesWhenEnteringForeground: Bool = true
    
    public var muted: Bool {
        get {
            return player.isMuted
        }
        set {
            player.isMuted = newValue
        }
    }

    public var volume: Float {
        get {
            return player.volume
        }
        set {
            player.volume = newValue
        }
    }
    
    public var fillMode: AVLayerVideoGravity {
        get {
            return view.playerLayer.videoGravity
        }
        set {
            view.playerLayer.videoGravity = newValue
        }
    }

    public var duration: TimeInterval {
        get {
            guard let playerItem = player.currentItem else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
            return CMTimeGetSeconds(playerItem.duration)
        }
    }
    
    public var currentTime: TimeInterval {
        get {
            guard let playerItem = player.currentItem else {
                return CMTimeGetSeconds(kCMTimeIndefinite)
            }
            return CMTimeGetSeconds(playerItem.currentTime())
        }
    }
    
    public var naturalSize: CGSize {
        get {
            guard let playerItem = player.currentItem, let track = playerItem.asset.tracks(withMediaType: .video).first else {
                return .zero
            }
            let size = track.naturalSize.applying(track.preferredTransform)
            return CGSize(width: fabs(size.width), height: fabs(size.height))
        }
    }
    
    public var layerBackgroundColor: UIColor = .black {
        didSet {
            view.layerColor = layerBackgroundColor
        }
    }
    
    public func play() {
        guard let _ = player.currentItem else { return }
        guard playbackState != .playing else { return }
        playbackState = .playing
        player.play()
    }
    
    public func pause() {
        guard let _ = player.currentItem else { return }
        guard playbackState != .pause else { return }
        playbackState = .pause
        player.pause()
    }
    
    public func stop() {
        guard playbackState != .stopped else { return }
        playbackState = .stopped
        player.pause()
        player.replaceCurrentItem(with: nil)
        url = nil
        error = nil
    }
    
    public func seek(to time: CMTime, completionHandler: ((Bool) -> Swift.Void)? = nil) {
        
        guard let playerItem = player.currentItem  else { return }
        
        bufferingState = .stalled
        
        playerItem.seek(to: time) { (finish) in
            if finish { self.bufferingState = .through }
            completionHandler?(finish)
        }
    }
    
    public func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    var error: Error?
    
    private let player = AVPlayer()
    
    private var _timeObserver: Any?
    
    public override init() {
        super.init()
        
        view.layerColor = layerBackgroundColor
        view.player = player

        addPlayerObservers()
        addApplicationObservers()
    }
    
    deinit {
        if _timeObserver != nil {
            player.removeTimeObserver(_timeObserver!)
            _timeObserver = nil
        }
        removeObservers()
        NotificationCenter.default.removeObserver(self)
    }
}

private extension ZHPlayer {
    
    func validateAsset(_ asset: AVAsset) {
        
        let keys = [PlayerKey.tracks, PlayerKey.playable, PlayerKey.duration]
        
        asset.loadValuesAsynchronously(forKeys: keys, completionHandler: { () -> Void in
            
            DispatchQueue.main.async {
                
                let deferror = NSError(domain: "Video resources are not available", code: 999, userInfo: [ NSLocalizedDescriptionKey : "Video resources are not available"])
                
                for key in keys {
                    var error: NSError? = nil
                    let status = asset.statusOfValue(forKey: key, error:&error)
                    if status == .failed {
                        self.error = error ?? deferror
                        self.playbackState = .fail
                    }
                }
                
                if !asset.isPlayable {
                    self.error = deferror
                    self.playbackState = .fail
                }
                else {
                    
                    self.error = nil
                    self.bufferingState = .playable
                    
                    self.removeObservers()
                    let playerItem = AVPlayerItem(asset:asset)
                    self.registerObservers(playerItem)
                    self.player.replaceCurrentItem(with: playerItem)
                }
            }
            
        })
    }
    
}

extension ZHPlayer {
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath, let item = player.currentItem else { return }
        
        if keyPath == PlayerKey.keepUp {
            guard item.isPlaybackLikelyToKeepUp else { return }
            self.bufferingState = .through
            delegate?.playerBufferingStateDidChange?(self)
            guard autoplay else { return }
            if (playbackState == .playing) {
                player.play()
            }
        }
        else if keyPath == PlayerKey.emptyBuffer {
            guard item.isPlaybackBufferEmpty else { return }
            self.bufferingState = .stalled
            delegate?.playerBufferingStateDidChange?(self)
            guard autoplay else { return }
            player.pause()
        }
        else if keyPath == PlayerKey.loadedTime {
            let timeRanges = item.loadedTimeRanges
            guard let timeRange = timeRanges.first?.timeRangeValue else { return }
            
            let bufferedTime = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
            delegate?.playerBufferTimeDidChange?(bufferedTime)
        }
        else if keyPath == PlayerKey.status {
            
            switch player.status {
            case .failed:
                let deferror = NSError(domain: "Video play failed!", code: 1999, userInfo: [ NSLocalizedDescriptionKey : "Video play failed!"])
                self.error = player.error ?? deferror
                playbackState = .fail
                
            case .readyToPlay:
                delegate?.playerReady?(self)
                if autoplay {
                    play()
                }
                if bufferingState == .playable {
                    bufferingState = .stalled
                }
                
            case .unknown:
                break
            }
            
        }
    }
    
    @objc private func playerItemDidPlayToEndTime(_ aNotification: Notification) {
        playbackState = .stopped
        delegate?.playerPlaybackDidEnd?(self)
    }
    
    @objc private func playerItemFailedToPlayToEndTime(_ aNotification: Notification) {
        error = NSError(domain: "Player failed to play to end time!", code: 1999, userInfo: [ NSLocalizedDescriptionKey : "Player failed to play to end time!"])
        playbackState = .fail
    }
}

// MARK: - Observer & Notification
private extension ZHPlayer {
    func addPlayerObservers() {
        self._timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 2), queue: DispatchQueue.main, using: { [weak self] timeInterval in
            guard let this = self else { return }
            this.delegate?.playerCurrentTimeDidChange?(this)
        })
    }
    
    func registerObservers(_ playerItem: AVPlayerItem) {
        
        playerItem.addObserver(self, forKeyPath: PlayerKey.emptyBuffer, options: [.new, .old], context: nil)
        playerItem.addObserver(self, forKeyPath: PlayerKey.keepUp, options: [.new, .old], context: nil)
        playerItem.addObserver(self, forKeyPath: PlayerKey.status, options: [.new, .old], context: nil)
        playerItem.addObserver(self, forKeyPath: PlayerKey.loadedTime, options: [.new, .old], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        
    }
    
    func removeObservers() {
        
        guard let playerItem = player.currentItem else { return }
        
        playerItem.removeObserver(self, forKeyPath: PlayerKey.emptyBuffer, context: nil)
        playerItem.removeObserver(self, forKeyPath: PlayerKey.keepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: PlayerKey.status, context: nil)
        playerItem.removeObserver(self, forKeyPath: PlayerKey.loadedTime, context: nil)
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
    }
    
    func addApplicationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillResignActive(_:)), name: .UIApplicationWillResignActive, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationDidEnterBackground(_:)), name: .UIApplicationDidEnterBackground, object: UIApplication.shared)
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: UIApplication.shared)
    }
    
    @objc func handleApplicationWillResignActive(_ aNotification: Notification) {

        guard self.playbackState == .playing && self.pausesWhenResigningActive else { return }
        
        self.pause()
    }
    
    @objc func handleApplicationDidBecomeActive(_ aNotification: Notification) {
        
        guard self.playbackState != .playing && self.resumesWhenBecameActive else { return }
        
        self.play()
    }
    
    @objc func handleApplicationDidEnterBackground(_ aNotification: Notification) {
        
        guard self.playbackState == .playing && self.pausesWhenBackgrounded else { return }
        
        self.pause()
    }
    
    @objc func handleApplicationWillEnterForeground(_ aNoticiation: Notification) {
        
        guard self.playbackState != .playing && self.resumesWhenEnteringForeground else { return }
        
        self.play()
    }
    
}

public class ZHPlayerView: UIView {
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    public var playerLayer: AVPlayerLayer {
        get {
            return layer as! AVPlayerLayer
        }
    }
    
    public var layerColor: UIColor? {
        get {
            guard let cgColor = playerLayer.backgroundColor else { return nil }
            return  UIColor(cgColor: cgColor)
        }
        set {
            guard let value = newValue else { return }
            playerLayer.backgroundColor = value.cgColor
        }
    }
    
    public var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
        }
    }
    
}

