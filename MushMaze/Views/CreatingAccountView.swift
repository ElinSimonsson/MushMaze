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
    let db = Firestore.firestore()
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userModel : UserModel
    @State var emailAddress = ""
    @State var password = ""
    @State var repeatPassword = ""
    @State var firstName = ""
    @State var lastName = ""
    @State var showError = false
    @State var showErrorFirstName = false
    @State var showErrorLastName = false
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
                .padding(.top, 30)
            InputTextField(hintText: "First Name", inputText: $firstName, showError: $showErrorFirstName)
                .padding(.top, 30)
            InputTextField(hintText: "Last Name", inputText: $lastName, showError: $showErrorLastName)
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
        .simultaneousGesture(
            DragGesture().onChanged({ gesture in
                if (gesture.location.y < gesture.predictedEndLocation.y){
                    dismissKeyBoard()
                }
            }))
    }
    
    func dismissKeyBoard () {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        keyWindow!.endEditing(true)
    }
    
    func createAccount() {
        if firstName == "", lastName == "", emailAddress == "", password == "", repeatPassword == "" {
            showErrorFirstName = true
            showErrorLastName = true
            showErrorEmailAddress = true
            showErrorPassword = true
            showErrorRepeatPassword = true
        } else if firstName == "" {
            showErrorFirstName = true
        } else if lastName == "" {
            showErrorLastName = true
        } else if emailAddress == "" {
            showErrorEmailAddress = true
        } else if password == "" {
            showErrorPassword = true
        } else if repeatPassword == "" {
            showErrorRepeatPassword = true
        } else if password != repeatPassword {
            passwordsDoNotMatch = true
        } else {
            userModel.createUserAndSaveToFirestore(firstName: $firstName.wrappedValue,
                                                       lastName: $lastName.wrappedValue,
                                                       emailAddress: $emailAddress.wrappedValue,
                                                       password: $password.wrappedValue)
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
    let fernGreen = Color(red: 113/255, green: 188/255, blue: 120/255)
    var body: some View {
        Text("Create Account")
            .font(.title3)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(fernGreen)
            .cornerRadius(15.0)
    }
}


//struct CreatingAccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreatingAccountView()
//    }
//}
