//
//  PasswordPrompt.swift
//  LunaLink
//
//  Created by leoc on 2024/9/6.
//

import Foundation

public protocol PasswordPrompt {
    /// Prompt for a password.
    ///
    /// - Returns:  The password.
    func getPassword() -> String
}

struct PasswordPromptImpl: PasswordPrompt {
    func getPassword() -> String {
        ""
    }
}
