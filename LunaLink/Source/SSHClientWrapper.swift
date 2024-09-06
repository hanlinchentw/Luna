//
//  SSHClientWrapper.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import Combine
import SwiftUI
import NIO
import NIOSSH

class SSHClientWrapper: ObservableObject {
    @Published var output: String = ""
    @Published var isConnected: Bool = false
    @Published var errorMessage: String? = nil
    
    private var sshClient: SSHClient?
    private var sessionChannel: Channel? // This will hold the session channel for command execution
    
    func connect(host: String, port: Int, username: String, password: String) {
        sshClient = SSHClient()
        sshClient?.connectAndAuthenticate(
            host: host,
            port: port,
            username: username,
            password: password,
            sessionHandler: { [weak self] sessionChannel in
                self?.sessionChannel = sessionChannel
                DispatchQueue.main.async {
                    self?.isConnected = true
                    self?.output = "Connected to \(host) as \(username)"
                }
            }
        )
    }
    
    func sendCommand(_ command: String) {
        guard let sessionChannel = sessionChannel else {
            self.errorMessage = "Not connected to a session"
            return
        }
        
        // Send the command via the session channel
        var buffer = sessionChannel.allocator.buffer(capacity: command.utf8.count)
        buffer.writeString(command + "\n") // Add newline to simulate pressing 'Enter'
        let data = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
        
        sessionChannel.writeAndFlush(NIOAny(data)).whenComplete { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.output += "\n$ \(command)\n"
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send command: \(error)"
                }
            }
        }
    }
    
    func disconnect() {
        sshClient = nil
        self.isConnected = false
        self.output = ""
    }
}
