<h1 align="center">CineList - iOS App</h1>

<p align="center">
  ( Interview Assignment )
</p>

<p align="center">
  <img src="https://img.shields.io/badge/swift-5.0-orange" alt="Swift Badge" />
  <img src="https://img.shields.io/badge/platform-iOS-blue" alt="Platform Badge" />
  <img src="https://img.shields.io/badge/ui-UIKit-7F52FF" alt="UIKit Badge" />
  <img src="https://img.shields.io/badge/architecture-MVC-purple" alt="Architecture Badge" />
</p>

**CineList** is an iOS app built with **UIKit** and Storyboards. It demonstrates clean project structure, networking with `URLSession`, and a simple image-driven UI. The launch screen includes attribution: "Samsung Company assignment Done by :\nDeepanshu Bajaj".

---

## ✨ Features

- **UIKit + Storyboards**: Uses Interface Builder for the launch screen and UI
- **Image Display**: Loads and displays images efficiently
- **Navigation**: Simple, responsive layout that adapts to device sizes
- **Clean Architecture**: MVC-style separation

---

## 📦 Requirements

- iOS **15.0+** (adjust if your deployment target differs)
- Xcode **14+**
- Swift **5.0**

---

## ⛓ Project Structure

    CineList
    .
    ├── CineList                   # App target sources
    │   ├── AppDelegate.swift / SceneDelegate.swift
    │   ├── ViewController.swift (or feature view controllers)
    │   ├── ImageLoader.swift (utility for image loading)
    │   ├── Assets.xcassets
    │   └── Base.lproj            # Storyboards (Main.storyboard, LaunchScreen.storyboard)
    ├── CineListTests            # Unit tests
    ├── CineListUITests         # UI tests
    └── CineList.xcodeproj

> Note: File names may vary slightly. Update this section if your structure differs.

---

## 🛠️ Installation

1. Clone the repository:
   ```bash
   git clone <your-repo-url>.git
