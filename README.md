# Simplify Golf

Simplify Golf is a free golf GPS app and rangefinder designed to help golfers simplify their game. This app offers accurate GPS distances, a community-driven golf course database, and an easy-to-use interface for scoring and course management.

## Features

- **Accurate GPS Distances**: Get precise distances to the front, center, and back of the green.
- **Scorecard Keeper**: Keep track of your scores and manage your rounds easily.
- **Community-Driven Course Database**: Add new courses to the database and share them with the community.
- **Battery Efficient**: Designed to use minimal battery so you can focus on your game.

## Screenshots

<div align="center">
  <img src="Screenshots/screenshot1.png" alt="Simplify Golf Main Menu" width="18%">
  <img src="Screenshots/screenshot2.png" alt="Simplify Golf Course View" width="18%">
  <img src="Screenshots/screenshot3.png" alt="Simplify Golf Scorecard" width="18%">
  <img src="Screenshots/screenshot4.png" alt="Simplify Golf Statistics" width="18%">
  <img src="Screenshots/screenshot5.png" alt="Simplify Golf Round Details" width="18%">
</div>

## Getting Started

### Prerequisites

- Xcode 15 or later
- CocoaPods (for managing dependencies)
- A Google Firebase account for using Firebase services like authentication and Firestore.

### Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/simplify-golf.git
   cd simplify-golf
   ```

2. **Install CocoaPods Dependencies**

   Run the following command to install the necessary dependencies:

   ```bash
   pod install
   ```

3. **GoogleService-Info.plist**

   - This project uses Firebase for backend services. You need to create your own Firebase project and download the `GoogleService-Info.plist` file.
   - Place the `GoogleService-Info.plist` file in the root of your Xcode project.
   - Note: The `GoogleService-Info.plist` file has been added to the `.gitignore` to protect sensitive information. You need to import your own file.

4. **Open the Xcode Workspace**

   Open the project workspace:

   ```bash
   open SimplifyGolf.xcworkspace
   ```

5. **Build and Run**

   Build the project and run it on a simulator or a real device.

## Contributing

We welcome contributions! If you'd like to contribute, please fork the repository and create a pull request with your changes. Please ensure your code follows the coding standards used in the project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

If you have any questions or suggestions, feel free to open an issue or contact the developer at [jayson@simplifygolf.app](mailto:jayson@simplifygolf.app).
