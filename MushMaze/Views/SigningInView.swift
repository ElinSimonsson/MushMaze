//
//  SigningInView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-25.
//

import SwiftUI
import FirebaseAuth

struct SigningInView: View {
    //let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    
    @Binding var signedIn : Bool
    @Binding var signedOut : Bool
    @State var email = ""
    @State var password = ""
    @State var showCreatingAccountView = false
    @State var isSecured = true
    @State var emailIsMissing = false
    @State var passwordIsMissing = false
    
    var body: some View {
        VStack {
            Spacer()
            WelcomeText()
            Spacer()
            UserImage()
            EmailTextField(email: $email, emailMissing: $emailIsMissing)
            PasswordFieldView(password: $password,
                                  passwordMissing: $passwordIsMissing,
                                  isSecured: $isSecured,
                                  action: logIn)
            Button(action: {
                showCreatingAccountView = true
            }) {
                Text("Not registered yet? Sign up here")
            }
            .fullScreenCover(isPresented: $showCreatingAccountView, content: {
                CreatingAccountView(signedIn: $signedIn, signedOut: $signedOut)
            })
            Spacer()
            Button(action: {
                logIn()
            }) {
                LogInButtonContent()
            }
            Spacer()
        }
        .onAppear() {
            checkIfUserIsLoggedIn()
        }
        .padding()
    }
    
    func logIn () {
        if email == "" && password == "" {
            emailIsMissing = true
            passwordIsMissing = true
        } else if email == "" {
            emailIsMissing = true
        } else if password == "" {
            passwordIsMissing = true
        } else {
        
        let email = $email.wrappedValue
        let password = $password.wrappedValue
        
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("error signing in \(error)")
                } else {
                    signedIn = true
                    signedOut = false
                    // if the user have logged out, and then logged in again - we need to change the signedOut
                    // to false to show TappedView
                }
            }
        }
        
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser != nil {
            signedIn = true
        }
    }
}

struct EmailTextField : View {
    @Binding var email : String
    @Binding var emailMissing : Bool
    
    var body: some View {
        ZStack {
            TextField("Email Address", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocorrectionDisabled(true)
            if emailMissing {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 1)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct PasswordFieldView: View {
    @Binding var password: String
    @Binding var passwordMissing : Bool
    @Binding var isSecured : Bool
    var action: () -> Void
    
    var body: some View {
        if isSecured {
            ZStack {
                HStack {
                    SecureField("Password", text: $password) {
                        self.action()
                    }
                    Button(action: {
                        self.isSecured.toggle()
                    }) {
                        EyeImageButton(isSecured: $isSecured)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocorrectionDisabled(true)
                if passwordMissing {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red, lineWidth: 1)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .padding(.bottom, 20)
                }
            }
        } else {
            ZStack {
                HStack {
                    TextField("Password", text: $password) {
                        self.action()
                    }
                    Button(action: {
                        self.isSecured.toggle()
                    }) {
                        EyeImageButton(isSecured: $isSecured)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocorrectionDisabled(true)
                if passwordMissing {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.red, lineWidth: 1)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .padding(.bottom, 20)
                }
            }
        }
    }
}




struct EyeImageButton : View {
    @Binding var isSecured : Bool
    var body: some View {
        
            Image(systemName: isSecured ? "eye.slash.fill" : "eye.fill")
                .foregroundColor(.gray)
                .font(.system(size: 22))
    }
}

struct WelcomeText : View {
    var body : some View {
        Text("Welcome back!")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage : View {
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
    }
}

struct LogInButtonContent : View {
  let darkTurquoise = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    var body: some View {
        Text("Log in")
            .font(.title3)
            .foregroundColor(.black)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(darkTurquoise))
            .cornerRadius(15.0)
    }
}

//struct SigningInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SigningInView()
//    }
//}
