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
    @State var passwordsNotIdentical = false
    @Binding var signedIn : Bool
    
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
            TextField("Email Address", text: $emailAddress)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            SecureField("Password", text: $password)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            SecureField("Repeat Password", text: $repeatPassword)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 100)
            
            Button(action: {
                print("skapa konto")
                createAccount()
            }) {
                CreateAccountButtonContent()
            }
            
        }
        .alert(isPresented: $passwordsNotIdentical) {
                    Alert(title: Text("Error"), message: Text("Passwords are not identical"), dismissButton: .default(Text("OK")))
                }
        .padding()
    }
    
    func createAccount() {
        let email = $emailAddress.wrappedValue
        let password = $password.wrappedValue
        
        if password == repeatPassword && fullName != "" {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("error signing up \(error.localizedDescription)")
                } else {
                    print("account created successfully")
                    saveUserDataToFirestore()
                }
            }
        } else if fullName == "" {
            
        } else {
            passwordsNotIdentical = true
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
