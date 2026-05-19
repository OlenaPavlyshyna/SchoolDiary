//
//  DiaryProfile.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//
import SwiftData

@Model
final class DiaryProfile {
    var firstName: String
    var lastName: String
    var schoolClassName: String

    init(firstName: String = "", lastName: String = "", schoolClassName: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.schoolClassName = schoolClassName
    }
}
