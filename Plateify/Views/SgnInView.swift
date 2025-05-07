//
//  LoginView.swift
//  Plateify
//
//  Created by Eduard Gaspar on 28.03.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 150, height: 150)
                
                Spacer()
                
                HStack{
                    VStack(alignment: .leading){
                        Text("Welcome back!")
                            .font(.title)
                            .foregroundColor(.black)
                        
                        Text("Sign in")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                    }
                    
                    Spacer()
                    
                }.padding(.horizontal)
                
                AuthenticationFields(email: $email, password: $password)
                
                
                VStack(){
                    
                    Button(action: {
                       //Action
                    }) {
                        Text("Sign in")
                    }.buttonStyle(PrimaryButtonStyle(primaryColor: .white, accentColor: .blue)  )
                    
                    
                    VStack(alignment: .leading){
                        
                        Text("Don't have an account?")
                        
                        Button(action: {
                            //Action
                        }) {
                            Text("Sign Up")
                        }.buttonStyle(PrimaryButtonStyle(primaryColor: .white, accentColor: .blue)  )
                    }
                    
                    
                }.padding(.horizontal)
                
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}

struct AuthenticationFields: View {
    @Binding var email: String
    @Binding var password: String
    
    
    var body: some View {
        VStack {
            CustomFormField(value: $email, icon: "at", isSecure: false, placeHolder: "email")
            
            CustomFormField(value: $password, icon: "lock", isSecure: true, placeHolder: "email")
            
        }.padding(.horizontal)
    }
}
