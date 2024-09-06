//
//  SSHClientError.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import Foundation

enum SshClientError: Error {
    case authenticationFailed
    case invalidHostKey
    case unsupportedRole
}
