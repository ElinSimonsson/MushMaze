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
    @State var fullName = ""
    @State var emailAddress = ""
    @State var password = ""
    @State var repeatPassword = ""
    @State var showError = false
    @Binding var signedIn : Bool
    @State var fullNameIsMissing = false
    @State var emailAddressIsMissing = false
    @State var passwordIsMissing = false
    @State var passwordsDoNotMatch = false
    
    var body: some View {
        VStack {
         HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("< Back")
                    .padding(.leading, 1)
                    .font(.title2)
            }
            Spacer()
        }
         .padding(.top, 1)
         .frame(alignment: .leading)
            
            SignUpText()
                .padding(.top, 70)
            Spacer()
            
            TextField("Full Name", text: $fullName)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .alert(isPresented: $fullNameIsMissing) {
                    Alert(title: Text("Full Name Missing"), message: Text("Please enter your full name"), dismissButton: .default(Text("OK")))
                }

            TextField("Email Address", text: $emailAddress)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .alert(isPresented: $emailAddressIsMissing) {
                    Alert(title: Text ("Email Missing"), message: Text("Please enter your email"), dismissButton: .default(Text("OK")))
                }
            
            SecureField("Password", text: $password)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .alert(isPresented: $passwordIsMissing) { // this alert make sure that BOTH of password field are filled
                    Alert(title: Text("Password Missing"), message: Text("Please make sure to fill in both password fields"),
                          dismissButton: .default(Text("Ok")))
                }
            
            SecureField("Repeat Password", text: $repeatPassword)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 100)
                .alert(isPresented: $passwordsDoNotMatch) { // since the previous alert already checks if this secureField isn´t filled, this one checks if the passwords dont match
                    Alert(title: Text("Password do not match"), message: Text("The passwords entered do not match. Please re-enter your password and confirm it again to proceed"),
                          dismissButton: .default(Text("Ok")))
                }
            
            Button(action: {
                createAccount()
            }) {
                CreateAccountButtonContent()
            }
            
        }
        .padding()
    }
    
    func createAccount() {
        let userEmail = $emailAddress.wrappedValue
        let userPassword = $password.wrappedValue
        
        if fullName == "" {
            fullNameIsMissing = true
        } else if emailAddress == "" {
            emailAddressIsMissing = true
        } else if password == "" || repeatPassword == "" {
            passwordIsMissing = true
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
        
        let user = User(fullName: $fullName.wrappedValue, userId: currentUser.uid)
        do {
            _ = try
                db.collection("usersInformation").addDocument(from: user)
            print("successed to save")
            signedIn = true
        } catch {
            print("Error saving to Firebase")
        }
    }
}

struct ErrorText : View {
    var message : String
    
    var body: some View {
        Text(message)
            .font(.title3)
            .foregroundColor(.red)
            .fontWeight(.semibold)
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
