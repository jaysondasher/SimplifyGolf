//
//  WatchViewModel.swift
//  Simplify Golf
//
//  Created by Jayson Dasher on 10/9/24.
//

import CoreLocation
import Foundation
import WatchConnectivity

class WatchViewModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isRoundActive = false
    @Published var currentHole = 1
    @Published var score = 0
    @Published var distances: (front: Int, middle: Int, back: Int) = (0, 0, 0)

    private var session: WCSession?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func session(
        _ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let action = message["action"] as? String {
                switch action {
                case "startRound":
                    self.isRoundActive = true
                    self.currentHole = 1
                    self.score = 0
                case "updateDistances":
                    if let distances = message["distances"] as? [String: Int] {
                        self.distances = (
                            front: distances["front"] ?? 0,
                            middle: distances["middle"] ?? 0,
                            back: distances["back"] ?? 0
                        )
                    }
                case "endRound":
                    self.isRoundActive = false
                default:
                    break
                }
            }
        }
    }

    func sendScore() {
        guard let session = session, session.isReachable else { return }
        let message: [String: Any] = ["action": "updateScore", "hole": currentHole, "score": score]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending score to phone: \(error.localizedDescription)")
        }
    }

    func nextHole() {
        currentHole += 1
        score = 0
        sendScore()
    }
}

extension WatchViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        sendLocation(location)
    }

    private func sendLocation(_ location: CLLocation) {
        guard let session = session, session.isReachable else { return }
        let message: [String: Any] = [
            "action": "updateLocation",
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
        ]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending location to phone: \(error.localizedDescription)")
        }
    }
}
