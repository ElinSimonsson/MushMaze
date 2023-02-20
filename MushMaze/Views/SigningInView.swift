//
//  SigningInView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-25.
//

import SwiftUI
import FirebaseAuth

struct SigningInView: View {

    @EnvironmentObject var userModel : UserModel
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
                CreatingAccountView()
            })
            Spacer()
            Button(action: {
                logIn()
                
            }) {
                LogInButtonContent()
            }
            Spacer()
        }
        .padding()
        .onAppear() {
            checkIfUserIsLoggedIn()
        }
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
    
    func logIn () {
        if email == "" && password == "" {
            emailIsMissing = true
            passwordIsMissing = true
        } else if email == "" {
            emailIsMissing = true
        } else if password == "" {
            passwordIsMissing = true
        } else {
            userModel.logIn(email: $email.wrappedValue, password: $password.wrappedValue)
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser != nil {
            userModel.signedIn = true
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
