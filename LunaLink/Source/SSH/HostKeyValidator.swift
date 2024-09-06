//
//  HostKeyValidator.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import Foundation
import NIO
import NIOSSH

/// Protocol for host key validators.
public protocol HostKeyValidator {
    /// Verify a host key.
    ///
    /// - Parameters:
    ///   - key:    The key to verify.
    ///
    ///   - host:   The host to verify the key for.
    ///
    /// - Returns:  Whether the specified key is valid for the specified host.
    func isValidKey(_ key: NIOSSHPublicKey, for host: String) -> Bool
}

struct HostKeyValidatorImpl: HostKeyValidator {
    func isValidKey(_: NIOSSHPublicKey, for _: String) -> Bool {
        return true
    }
}
