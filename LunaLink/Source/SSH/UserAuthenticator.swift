//
//  UserAuthenticator.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import Foundation
import NIO
import NIOSSH

final class UserAuthenticator: NIOSSHClientUserAuthenticationDelegate {
    private let queue: DispatchQueue
    private let username: String
    private let password: String?
    private let passwordPrompt: PasswordPrompt?
    private var attemptedNoAuthentication: Bool
    private var attemptedPassword: Bool

    init(username: String,
         password: String? = nil,
         passwordPrompt: PasswordPrompt? = nil)
    {
        queue = DispatchQueue(label: "SshClientUserAuthenticator")
        self.username = username
        self.password = password
        self.passwordPrompt = passwordPrompt
        attemptedNoAuthentication = false
        attemptedPassword = false
    }

    func nextAuthenticationType(availableMethods: NIOSSHAvailableUserAuthenticationMethods, nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>) {
        if !attemptedNoAuthentication {
            attemptedNoAuthentication = true
            nextChallengePromise.succeed(NIOSSHUserAuthenticationOffer(username: username, serviceName: "", offer: .none))
            return
        }

        if !attemptedPassword &&
            availableMethods.contains(.password)
        {
            if let password = password {
                attemptedPassword = true
                nextChallengePromise.succeed(NIOSSHUserAuthenticationOffer(username: username, serviceName: "", offer: .password(.init(password: password))))
                return
            }

            if let passwordPrompt = passwordPrompt {
                queue.async {
                    let password = passwordPrompt.getPassword()
                    self.attemptedPassword = true
                    nextChallengePromise.succeed(NIOSSHUserAuthenticationOffer(username: self.username, serviceName: "", offer: .password(.init(password: password))))
                }
                return
            }
        }

        // No more authentication methods
        nextChallengePromise.fail(SshClientError.authenticationFailed)
    }
}
