//
//  Device+Exec.swift
//  Axchange
//
//  Created by Lakr Aream on 2022/7/27.
//

import AuxiliaryExecute
import Foundation

extension Device {
    func executeADB(
        withParameters parameters: [String],
        timeout: Double = -1,
        output: ((String) -> Void)? = nil
    ) -> AuxiliaryExecute.ExecuteRecipe {
        let recipe = Executor.executeADB(
            withParameters: ["-s", adbIdentifier] + parameters,
            timeout: timeout,
            output: output
        )
        DispatchQueue.main.async {
            self.deviceLog.append(.init(
                command: "adb \(parameters.joined(separator: " "))",
                recipt: recipe
            ))
            while self.deviceLog.count > 256 {
                self.deviceLog.removeLast()
            }
        }
        return recipe
    }

    func executeADB(command: String) -> String {
        let parms = command.components(separatedBy: " ").filter { !$0.isEmpty }
        let recipe: AuxiliaryExecute.ExecuteRecipe = executeADB(
            withParameters: parms
        )
        return recipe.stdout
    }
}
