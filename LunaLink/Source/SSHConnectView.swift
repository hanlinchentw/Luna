//
//  SSHConnectView.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import SwiftUI

struct SSHConnectView: View {
    @ObservedObject var sshClient = SSHClientWrapper()
    
    @State private var host: String = "your.ssh.server"
    @State private var port: String = "22"
    @State private var username: String = "yourUsername"
    @State private var password: String = "yourPassword"
    @State private var command: String = ""
    
    var body: some View {
        VStack {
            if sshClient.isConnected {
                VStack {
                    Text("Connected to \(host)")
                        .font(.headline)
                        .padding(.top)
                    
                    ScrollView {
                        Text(sshClient.output)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding()

                    TextField("Enter Command", text: $command, onCommit: {
                        sshClient.sendCommand(command)
                        command = ""
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                    Button(action: {
                        sshClient.disconnect()
                    }) {
                        Text("Disconnect")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            } else {
                VStack {
                    Text("SSH Connection")
                        .font(.largeTitle)
                        .padding(.top)
                    
                    TextField("Host", text: $host)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    TextField("Port", text: $port)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .keyboardType(.numberPad)
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        if let portInt = Int(port) {
                            sshClient.connect(host: host, port: portInt, username: username, password: password)
                        }
                    }) {
                        Text("Connect")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top)
                    
                    if let errorMessage = sshClient.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    SSHConnectView()
}
