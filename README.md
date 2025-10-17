# Vitesse iOS App

Vitesse is a complete iOS application developed for the fictional automotive company "Vitesse". It serves as a candidate management tool for the Human Resources department, demonstrating a modern, test-driven approach to iOS development.

## 🚀 Features

* **Secure Authentication**: User login and registration system for HR staff.
* **Candidate Management**: View, create, and update a list of candidates.
* **Favorite System**: Mark candidates as favorites for easy access.
* **Dynamic Filtering**: Filter the candidate list to show only favorites.
* **Live Search**: Instantly search for candidates by first or last name.
* **Detailed View & Editing**: View detailed candidate information and edit it directly within the app.

## 🏛️ Architecture & Tech Stack

This project was built with a strong focus on clean architecture, testability, and modern development practices.

* **MVVM (Model-View-ViewModel)**: The core architecture provides a clear separation of concerns between the UI (View), the presentation logic (ViewModel), and the data (Model).
* **SwiftUI**: The entire user interface is built declaratively with SwiftUI, leveraging its powerful state management tools like `@StateObject` and `@Published`.
* **Modern Concurrency**: The app makes extensive use of Swift's modern concurrency features (`async/await` and `@MainActor`) for clean, safe, and efficient asynchronous operations.
* **Protocol-Oriented Programming (POP)**: Services and dependencies are abstracted using protocols (`AuthenticationServiceProtocol`, `CandidateServiceProtocol`), which is key to the app's testability.
* **Dependency Injection (DI)**: Dependencies are injected into ViewModels and Services, allowing for easy replacement with mocks in unit tests.
* **Service Layer**: All API communication is isolated in a dedicated Service Layer (`AuthService`, `CandidateService`), which was refactored into a generic `APIService` to reduce code duplication.
* **Secure Keychain**: Authentication tokens are securely stored in the device's Keychain for persistent and safe sessions.
* **Unit Testing**: The project has a high unit test coverage (>95%) for its business logic, using the native **Swift Testing** framework and a comprehensive suite of mocks.

## 📂 Project Structure

The project is organized into logical layers to facilitate navigation and maintainability:
```
Vitesse/
├── Models/
│   ├── Candidate.swift   # Business model
│   └── DTOs/             # Data Transfer Objects for API communication
├── Services/
│   ├── APIService.swift  # Generic, refactored network logic
│   ├── AuthService.swift # Authentication-specific endpoints
│   └── CandidateService.swift # Candidate-specific endpoints
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── CandidateListViewModel.swift
│   └── CandidateDetailViewModel.swift
├── Views/
│   ├── AuthView.swift
│   ├── CandidateListView.swift
│   └── CandidateDetailView.swift
├── Utils/                # Helper protocols and extensions
└── VitesseApp.swift      # Main app entry point
```

## ⚙️ Getting Started

To clone and run the project locally, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/Habano78/Vitesse-iOS-App.git](https://github.com/Habano78/Vitesse-iOS-App.git)
    ```

2.  **Open the project in Xcode:**
    ```bash
    cd Vitesse-iOS-App
    open Vitesse.xcodeproj
    ```

3.  **Run the application:**
    * Select a simulator or a physical device.
    * Press `Cmd+R` to build and run the app.

_Note: The application is configured to communicate with a local API server at `http://127.0.0.1:8080`. A running instance of the corresponding backend is required for the network features to work._

## ✅ Running Tests

The project includes a comprehensive suite of unit tests. To run them:

1.  Open the Test Navigator in Xcode (`Cmd+6`).
2.  Click the play button next to the `VitesseTests` target or press `Cmd+U`.
