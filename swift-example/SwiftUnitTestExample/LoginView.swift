//
//  LoginView.swift
//  SwiftUnitTestExample
//
//  Created by Drew Hosford on 5/23/25.
//

import SwiftUI

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

struct LoginView: View {
    @State var username = ""
    @State var password = ""
    @State var showAlert = false
    @State var alertMessage = ""
    @State var errorMessage = ""
    
    var urlSession: URLSessionProtocol = URLSession.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Unit Test Demonstration")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
                .accessibilityIdentifier("usernameTextField")
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .accessibilityIdentifier("passwordTextField")
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .accessibilityIdentifier("errorLabel")
            }
            
            Button("Login") {
                Task {
                    await login()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .accessibilityIdentifier("loginButton")
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Status"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func login() async {
        // Clear any previous error
        errorMessage = ""
        
        guard let url = URL(string: "https://innovira.co/testing/login") else {
            errorMessage = "Invalid URL"
            return
        }
        
        // Validate input
        if username.isEmpty {
            errorMessage = "Username is required"
            return
        }
        
        if password.isEmpty {
            errorMessage = "Password is required"
            return
        }
        
        let credentials = [
            "username": username,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials) else {
            errorMessage = "Error preparing request"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        await withCheckedContinuation { continuation in
            urlSession.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        alertMessage = "Error: \(error.localizedDescription)"
                        showAlert = true
                        continuation.resume()
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        alertMessage = "Invalid response"
                        showAlert = true
                        continuation.resume()
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        alertMessage = "Login successful"
                    } else {
                        alertMessage = "Login failed: Status \(httpResponse.statusCode)"
                    }
                    showAlert = true
                    continuation.resume()
                }
            }.resume()
        }
    }
}

#Preview {
    LoginView()
}
