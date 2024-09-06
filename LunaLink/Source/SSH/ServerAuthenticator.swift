//
//  ServerAuthenticator.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import Foundation
import NIO
import NIOSSH

final class ServerAuthenticator: NIOSSHClientServerAuthenticationDelegate {
    private let host: String
    private let hostKeyValidator: HostKeyValidator

    init(host: String, hostKeyValidator: HostKeyValidator) {
        self.host = host
        self.hostKeyValidator = hostKeyValidator
    }

    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        if hostKeyValidator.isValidKey(hostKey, for: host) {
            validationCompletePromise.succeed(())
        } else {
            validationCompletePromise.fail(SshClientError.invalidHostKey)
        }
    }
}
