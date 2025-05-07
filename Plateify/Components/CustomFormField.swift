//
//  CustomFormField.swift
//  Plateify
//
//  Created by Eduard Gaspar on 28.03.2025.
//

import SwiftUI

struct CustomFormField: View {
    @Binding var value : String
    var icon : String
    var isSecure : Bool
    var placeHolder : String
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(style:StrokeStyle(lineWidth: 2))
                .frame(maxWidth: .infinity,maxHeight: 50)
                .foregroundColor(.black).opacity(0.2)
                
                
                
            HStack{
                Image(systemName: icon)
                    .foregroundColor(Color.black)
                Group{
                    if !isSecure{
                        TextField(placeHolder, text: $value)
                    }
                    else{
                        SecureField(placeHolder, text: $value)
                    }
                }.autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .frame(height: 50)
                    .foregroundColor(Color(.black))
            }.padding(.horizontal)
                .frame(maxWidth: .infinity,maxHeight: 50)
        }
    }
}

/*
 struct FormField_Previews: PreviewProvider {
 @State private var email = ""
 
 static var previews: some View {
 FormField(value: email, icon: "at", isSecure: false, placeHolder: "email")
 }
 }
 */
#Preview {
    CustomFormField(value: .constant(""), icon: "at", isSecure: false, placeHolder: "email")
}
