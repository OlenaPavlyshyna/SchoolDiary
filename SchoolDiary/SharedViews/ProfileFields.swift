//
//  ProfileFields.swift
//  SchoolDiary
//
//  Created by Olena Pavlyshyna on 18.05.2026.
//

import SwiftUI

struct ProfileFields: View {
   
    @Bindable var profile: DiaryProfile

    var body: some View {
        Section("Власник щоденника") {
            TextField("Імʼя", text: $profile.firstName)
                .textContentType(.givenName)

            TextField("Прізвище", text: $profile.lastName)
                .textContentType(.familyName)

            TextField("Клас", text: $profile.schoolClassName)
                .textContentType(.organizationName)
                .autocorrectionDisabled()
                
        }
    }
}

#Preview {
    ProfileFields(profile: DiaryProfile())
}
