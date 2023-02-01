//
//  CreatingAccountView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct CreatingAccountView: View {
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    let db = Firestore.firestore()
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var signedIn : Bool
    @Binding var signedOut : Bool
    @State var fullName = ""
    @State var emailAddress = ""
    @State var password = ""
    @State var repeatPassword = ""
    @State var showError = false
    @State var showErrorFullName = false
    @State var showErrorEmailAddress = false
    @State var showErrorPassword = false
    @State var showErrorRepeatPassword = false
    @State var passwordsDoNotMatch = false
    
    var body: some View {
        VStack {
         HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("< Back")
            }
            Spacer()
        }
         .padding(.top, 1)
         .frame(alignment: .leading)
            
            SignUpText()
                .padding(.top, 70)
            Spacer()
            
            InputTextField(hintText: "Full Name" , inputText: $fullName, showError: $showErrorFullName)
            InputTextField(hintText: "Email Address", inputText: $emailAddress, showError: $showErrorEmailAddress)
            InputPasswordField(hintText: "Password", inputPassword: $password, showError: $showErrorPassword, showErrorPasswordsNotMatching: $passwordsDoNotMatch)
            InputPasswordField(hintText: "Repeat Password", inputPassword: $repeatPassword, showError: $showErrorRepeatPassword, showErrorPasswordsNotMatching: $passwordsDoNotMatch)
            
            Spacer()
            Button(action: {
                createAccount()
            }) {
                CreateAccountButtonContent()
            }
            Spacer()
            
        }
        .padding()
    }
    
    func createAccount() {
        let userEmail = $emailAddress.wrappedValue
        let userPassword = $password.wrappedValue
        
        if fullName == "" && emailAddress == "" && password == "" && repeatPassword == "" {
            showErrorFullName = true
            showErrorEmailAddress = true
            showErrorPassword = true
            showErrorRepeatPassword = true
        } else if fullName == "" {
            showErrorFullName = true
        } else if emailAddress == "" {
            showErrorEmailAddress = true
        } else if password == "" {
            showErrorPassword = true
        } else if repeatPassword == "" {
            showErrorRepeatPassword = true
        } else if password != repeatPassword {
            passwordsDoNotMatch = true
        } else {
            Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authResult, error in
                if let error = error {
                    print("error signing up \(error.localizedDescription)")
                } else {
                    print("account created successfully")
                    saveUserDataToFirestore()
                }
            }
        }
    }
    
    func saveUserDataToFirestore () {
        guard let currentUser = Auth.auth().currentUser else {return}
        
        let user = User(fullName: $fullName.wrappedValue, emailAddress: $emailAddress.wrappedValue, userId: currentUser.uid)
        do {
            _ = try
            db.collection("users").document(currentUser.uid).setData(from: user)
            print("successed to save")
            signedIn = true
            signedOut = false
        } catch {
            print("Error saving to Firebase")
        }
    }
}


struct InputTextField : View {
    var hintText : String
    @Binding var inputText : String
    @Binding var showError : Bool
   
    
    var body: some View {
        ZStack {
            TextField(hintText, text: $inputText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocorrectionDisabled(true)
            if showError {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 1)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct InputPasswordField : View {
    var hintText : String
    @Binding var inputPassword : String
    @Binding var showError : Bool
    @Binding var showErrorPasswordsNotMatching : Bool
    
    var body: some View {
        ZStack {
            SecureField(hintText, text: $inputPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocorrectionDisabled(true)
                .alert(isPresented: $showErrorPasswordsNotMatching) {
                    Alert(title: Text("The passwords do not match"), message: Text("Please try again with the same password in both fields"),
                          dismissButton: .default(Text("Ok")))
                }
            if showError {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 1)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct SignUpText : View {
    var body : some View {
        Text("Sign up")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct CreateAccountButtonContent : View {
  let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    var body: some View {
        Text("Create Account")
            .font(.title3)
            .foregroundColor(.black)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(darkTurquoise))
            .cornerRadius(15.0)
    }
}


//struct CreatingAccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreatingAccountView()
//    }
//}
