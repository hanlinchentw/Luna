//
//  SSHClient.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import Foundation
import NIO
import NIOSSH

final class SSHClient {
    private let hostKeyValidator = HostKeyValidatorImpl()
    private let passwordPrompt = PasswordPromptImpl()
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

    func connectAndAuthenticate(host: String, port: Int, username: String, password: String, sessionHandler: @escaping (Channel) -> Void) {
        let bootstrap = ClientBootstrap(group: eventLoopGroup)
            .channelInitializer { channel in
                channel.pipeline.addHandlers([
                    NIOSSHHandler(
                        role: .client(
                            .init(
                                userAuthDelegate: UserAuthenticator(username: username, password: password),
                                serverAuthDelegate: ServerAuthenticator(host: host, hostKeyValidator: HostKeyValidatorImpl())
                            )
                        ),
                        allocator: channel.allocator,
                        inboundChildChannelInitializer: { childChannel, channelType in
                            switch channelType {
                            case .session:
                                sessionHandler(childChannel) // Pass the session channel
                                return childChannel.pipeline.addHandler(SSHClientSessionHandler())
                            default:
                                return childChannel.eventLoop.makeFailedFuture(SshClientError.unsupportedRole)
                            }
                        }
                    ),
                    SSHClientHandler()
                ])
            }
            .connectTimeout(TimeAmount.seconds(10))
        
        let connection = bootstrap.connect(host: host, port: port)
        connection.whenComplete { result in
            switch result {
            case .success(let channel):
                sessionHandler(channel)
                print("Connected to \(host) on \(port)")
            case .failure(let error):
                print("Failed to connect: \(error)")
            }
        }
    }
}

class SSHClientHandler: ChannelInboundHandler {
    typealias InboundIn = SSHChannelData

    func channelRead(context _: ChannelHandlerContext, data: NIOAny) {
        let sshData = unwrapInboundIn(data)
        if case let .byteBuffer(buffer) = sshData.data {
            let response = buffer.getString(at: buffer.readerIndex, length: buffer.readableBytes) ?? ""
            print("Received: \(response)")
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("Error: \(error)")
        context.close(promise: nil)
    }
}

class SSHClientSessionHandler: ChannelInboundHandler {
    typealias InboundIn = SSHChannelData
    typealias OutboundOut = SSHChannelData

    func channelActive(context: ChannelHandlerContext) {
        print("SSH session activated")

        // Example: Send a command (like `ls` in this case) to the server
        let command = "ls\n"
        var buffer = context.channel.allocator.buffer(capacity: command.utf8.count)
        buffer.writeString(command)
        let data = SSHChannelData(type: .channel, data: .byteBuffer(buffer))

        context.writeAndFlush(self.wrapOutboundOut(data), promise: nil)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let sshData = self.unwrapInboundIn(data)
        if case .byteBuffer(let buffer) = sshData.data {
            let response = buffer.getString(at: buffer.readerIndex, length: buffer.readableBytes) ?? ""
            print("Command Output: \(response)")
        }
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("SSH session error: \(error)")
        context.close(promise: nil)
    }
}
