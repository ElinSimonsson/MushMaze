//
//  SigningInView.swift
//  MushMaze
//
//  Created by Elin Simonsson on 2023-01-25.
//

import SwiftUI
import FirebaseAuth

struct SigningInView: View {
    @Binding var signedIn : Bool
    let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
    @State var email = ""
    @State var password = ""
    @State var showCreatingAccountView = false
    @State var isSecured = true
    
    var body: some View {
        VStack {
            Spacer()
            WelcomeText()
            Spacer()
            UserImage()
            
            EmailTextField(email: $email, lightGreyColor: lightGreyColor)
            
            ZStack {
                PasswordFieldView(password: $password,
                                  isSecured: isSecured,
                                  action: logIn,
                                  lightGreyColor: lightGreyColor)
                HStack {
                    Spacer()
                    Button(action: {
                        self.isSecured.toggle()
                    }) {
                        EyeImageButton(isSecured: $isSecured)
                    }
                }
            }
            Button(action: {
                showCreatingAccountView = true
            }) {
                Text("Not registered yet? Sign up here")
            }
            .fullScreenCover(isPresented: $showCreatingAccountView, content: {
                CreatingAccountView(signedIn: self.$signedIn)
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
        let email = $email.wrappedValue
        let password = $password.wrappedValue
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("error signing in \(error)")
            } else {
                print("signed in \(authResult?.user.uid)")
                signedIn = true
                
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
    let lightGreyColor : Color
    
    var body: some View {
        TextField("Email Address", text: $email)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct PasswordFieldView: View {
    @Binding var password: String
    var isSecured: Bool
    var action: () -> Void
    var lightGreyColor : Color
    
    var body: some View {
        if isSecured {
            SecureField("Password", text: $password) {
                self.action()
            }
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
        } else {
            TextField("Password", text: $password) {
                self.action()
            }
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
        }
    }
}


struct EyeImageButton : View {
    @Binding var isSecured : Bool
    var body: some View {
        Image(systemName: isSecured ? "eye.slash.fill" : "eye.fill")
            .foregroundColor(.black)
            .font(.system(size: 22))
            .padding(.bottom, 14)
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
