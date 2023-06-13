//
//  Client.swift
//  TCP_IP_Client
//
//  Created by 장준석 on 2023/04/27.
//

import Network
import Foundation

public class TCPClient {
    private let connection: NWConnection
    public var flag = false
    public var flag2 = false
    public var serverOk = 0
    
    init(shost: String, sport: Int) {
        let host = NWEndpoint.Host(shost)
        let port = NWEndpoint.Port("\(sport)")!
        connection = NWConnection(host: host, port: port, using: .tcp)
    }

    func start() {
        NSLog("will start")
        self.connection.stateUpdateHandler = self.didChange(state:)
        self.receive()
        self.connection.start(queue: .main)
        self.connection.stateUpdateHandler = {(newState) in
            switch(newState){
            case .ready:
                print("대기중")
                break
            case .waiting(let error):
                print("\(error) 발생")
                break
            default:
                break
            }
        }
    }
    
    func stop() {
            self.connection.cancel()
            NSLog("did stop")
        }
    
    private func didChange(state: NWConnection.State){
        switch state {
                case .setup:
                    break
                case .waiting(let error):
                    NSLog("is waiting: %@", "\(error)")
                case .preparing:
                    break
                case .ready:
                    break
                case .failed(let error):
                    NSLog("did fail, error: %@", "\(error)")
                    self.stop()
                case .cancelled:
                    NSLog("was cancelled")
                    self.stop()
                @unknown default:
                    break
                }
    }

    func send(message: String) {
        let content = message.data(using: .utf8)
        connection.send(content: content, completion: .contentProcessed { error in
            if let error = error {
                print("Error sending data: \(error)")
            } else {
                print("Data sent successfully!")
            }
        })
    }

    func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 30) { (data, context, isComplete, error) in
            if let data = data, !data.isEmpty {
                let msg = String(data: data, encoding: .utf8)!
                print(msg)
                if(msg.hasPrefix("go")){
                    self.flag = true
                }
                else if(msg.hasPrefix("ok")){
                    self.serverOk += 1
                }
                else{
                    print("Received data: \(msg)")
                }
                }
            if let error = error {
                print("Error receiving data: \(error)")
            }
            if isComplete {
                print("All data received!")
            } else {
                self.receive()
            }
        }
    }

    func cancel() {
        connection.cancel()
    }
}
