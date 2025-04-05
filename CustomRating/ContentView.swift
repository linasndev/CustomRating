//
//  ContentView.swift
//  CustomRating
//
//  Created by Linas on 05/04/2025.
//

import SwiftUI
import StoreKit


struct ContentView: View {
  
  @State private var showRatingPrompt: Bool = false
  @State private var showFeedbackForm: Bool = false
  
  var body: some View {
    ZStack {
      NavigationStack {
        VStack {
          Text("Hello World!")
        }
        .navigationTitle("My App")
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showRatingPrompt = true
          }
        }
      }
      .blur(radius: showRatingPrompt || showFeedbackForm ? 3 : 0)
      
      if showRatingPrompt || showFeedbackForm {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture {
            dismissOverlays()
          }
          .transition(.opacity)
          .zIndex(1)
      }
      
      if showRatingPrompt {
        OverTopView(
          showOverTop: $showRatingPrompt,
          onNoTapped: {
            switchToFeedbackForm()
          }
        )
        .zIndex(2)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
      }
      
      if showFeedbackForm {
        FeedbackFormView(isPresented: $showFeedbackForm)
          .zIndex(3)
          .transition(.scale(scale: 0.9).combined(with: .opacity))
      }
    }
    .animation(.spring(), value: showRatingPrompt)
    .animation(.spring(), value: showFeedbackForm)
  }
  
  private func dismissOverlays() {
    withAnimation {
      showRatingPrompt = false
      showFeedbackForm = false
    }
  }
  
  private func switchToFeedbackForm() {
    withAnimation {
      showRatingPrompt = false
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      withAnimation {
        showFeedbackForm = true
      }
    }
  }
}


// --- Rating Prompt View ---
struct OverTopView: View {
  
  @Environment(\.requestReview) private var requestReview
  @Binding var showOverTop: Bool
  var onNoTapped: () -> Void
  
  var body: some View {
    VStack(spacing: 15) {
      HStack {
        Spacer()
        Button {
          dismissView()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.title2)
            .foregroundColor(.gray)
        }
      }
      
      Text("Enjoying the App?")
        .font(.headline)
      
      Text("Your feedback helps us improve.")
        .font(.subheadline)
        .multilineTextAlignment(.center)
      
      HStack(spacing: 20) {
        Button {
          dismissView()
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            requestReview()
          }
        } label: {
          Label("Yes", systemImage: "hand.thumbsup.fill")
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        
        Button {
          onNoTapped()
        } label: {
          Label("No", systemImage: "hand.thumbsdown.fill")
            .foregroundStyle(Color.secondary)
        }
        .buttonStyle(.bordered)
      }
    }
    .padding()
    .frame(width: 300)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
  }
  
  private func dismissView() {
    withAnimation(.spring()) {
      showOverTop = false
    }
  }
}


// --- Feedback Form View (Using mailto: URL) ---
struct FeedbackFormView: View {
  @Binding var isPresented: Bool
  @State private var feedbackText: String = ""
  // Removed showMailView and mailResult states
  @State private var showingAlert = false
  @State private var alertMessage = ""
  
  let recipientEmail = "your-feedback-email@example.com" // <<< --- IMPORTANT: Set your email here
  let emailSubject = "App Feedback"
  
  var body: some View {
    VStack(spacing: 15) {
      HStack {
        Text("Send Feedback")
          .font(.headline)
        Spacer()
        Button {
          dismissForm()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.title2)
            .foregroundColor(.gray)
        }
      }
      
      Text("We're sorry you didn't have the best experience. Please let us know what we can improve:")
        .font(.subheadline)
      
      TextEditor(text: $feedbackText)
        .frame(height: 150)
        .border(Color.gray.opacity(0.3), width: 1)
        .cornerRadius(8)
      
      Button {
        sendFeedbackViaMailto()
      } label: {
        Label("Send Feedback", systemImage: "paperplane.fill")
      }
      .buttonStyle(.borderedProminent)
      .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Simplified disabled condition
      
    }
    .padding()
    .frame(width: 320)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    // Removed the .sheet modifier
    .alert("Cannot Send Mail", isPresented: $showingAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text(alertMessage)
    }
  }
  
  private func dismissForm() {
    withAnimation(.spring()) {
      isPresented = false
    }
  }
  
  // Function to send feedback using mailto: URL
  private func sendFeedbackViaMailto() {
    let subject = emailSubject
    let body = feedbackText
    
    guard !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      print("Feedback text is empty.")
      alertMessage = "Please enter your feedback before sending."
      showingAlert = true
      return
    }
    
    let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    let mailtoString = "mailto:\(recipientEmail)?subject=\(encodedSubject)&body=\(encodedBody)"
    
    guard let mailtoURL = URL(string: mailtoString) else {
      print("Could not create mailto URL")
      alertMessage = "An error occurred preparing the email."
      showingAlert = true
      return
    }
    
    // Check if an app can handle the mailto URL scheme
    if UIApplication.shared.canOpenURL(mailtoURL) {
      UIApplication.shared.open(mailtoURL) { success in
        if success {
          print("Successfully opened mailto URL handler.")
          // Dismiss the form after handing off to the OS
          DispatchQueue.main.async {
            dismissForm()
          }
        } else {
          print("Failed to open mailto URL.")
          // This might happen in rare cases even if canOpenURL was true
          DispatchQueue.main.async {
            alertMessage = "Could not open the email application."
            showingAlert = true
          }
        }
      }
    } else {
      // No app found configured to handle mailto:
      print("Cannot open mailto URL: No suitable email app found.")
      alertMessage = "No email application is configured on your device to send this feedback."
      showingAlert = true
    }
  }
}


#Preview {
  ContentView()
}
