# BU Arts Passport

### Description
BU Arts Passport is a simple and lightweight mobile app that promotes and tracks student engagement in arts events hosted by the BU Arts Initiative and College of Fine Arts. 
Students can browse upcoming events, register to attend, and check in at the event to recieve points and stickers. 
Additionally, the [admin dashboard](https://github.com/BU-Spark/se-bu-passport-arts/tree/main/bu_arts_admin#readme) is a web application that allows administrators to update event information and view more detailed information about student attendance.

### Prerequisites and Configuration
Before you begin, ensure you have met the following requirements:
- **Flutter**: Your system must have Flutter installed. This project was built using Flutter 3.19.2. Ensure that you are using this version or later. For installation instructions, see [Flutter's official installation guide](https://flutter.dev/docs/get-started/install).
- **Dart SDK**: Dart 3.3.0 or later is required. However, this typically comes with the Flutter installation.
- **Android or iOS Setup**: For Android, you must have Android SDK setup. Windows or Mac users can choose Android development. For iOS, you need to Xcode installed to run the simulator. Only Mac users can run the iOS emulator. Ensure that these emulators are configured for your IDE of choice. The app should be tested on both systems, so it's best to have at least one team member on each platform.
- **Google Places API Key**: The Geolocation check in relies on the Google Places API, which requires an API key.
  - Create a directory under 'bu_passport/lib' named 'config'
  - Create a file named 'secrets.dart' and add your API key in this file as follows:
  ```plaintext
  final String googlePlacesApiKey=your_api_key_here;
  ```
  - The application is set up to read the API key from here, and it has already been added to the '.gitignore' file

### Installation and Usage
1. Clone into the repository
```bash
# Use either HTTPS or SSH
git clone https://github.com/BU-Spark/se-bu-passport-arts.git

cd se-bu-passport-arts/bu_passport
```

2. Install Dependencies
```bash
flutter pub get
```
Since our application is built using Flutter, the command above will download all the necessary dependencies to run the project.

3. Install pod Files (only Mac users)
Before running this app for the first time, you have to install pod files. To do this, ensure that you are in the '/ios' directory and execute the following command:
```bash
pod install
```
Link to [Troubleshooting](#troubleshooting) for potential errors related to pod install.

4. Run the application locally
```bash
flutter run
```
Running this command will run the app locally, either via an Android simulator or iOS simulator. Ensure that you have either simulators installed and 
selected before running this command. \
Link to [Troubleshooting](#troubleshooting) for errors with running the app or missing dependencies.

### Features
- **Login and Profile**
  - Users can easily login with their BU email
  - Users can update their name, profile photo, and other personal details on their profile page
- **Event browsing**
  - Users are able to see upcoming and ongoing events either in a list view format in the explore page or in a calendar format
  - Users can search for events using specific criteria such as location, tags, and point values
- **Event Saving**
  - Users are able to save the events they are interested in, which will also be reflected onto their profile page
- **Geolocation Checkin**
  - When it is the day of the event, and the user is within 400 meters to the event location, they are able to checkin and track their participation
- **Point Tracking**
  - When a user successfully checks in to an event, they are awarded points
  - These points are saved to the user, and earning 100 points will reward them with a raffle ticket
  - There is a leaderboard page to showcase the highest raffle ticket earners
-  **Passport**
   - Certain events award users stickers for attending. They can add these stickers to their collection on the passport page

### Testing
To run all the automated tests under the '/test' directory for this project, ensure that you are in the '/bu_passport' directory and execute the following command:
```bash
flutter test
```
To run a specific test file, execute the following command:
```bash
flutter test test/file_name_here.dart
```

### Project Architecture

![alt text](./architecture.png)

### Directory Structure

auth/ \
Handles authentication of user by checking if they are logged in or not

classes/ \
All classes will be here

components/ \
Reusable widgets such as an event_widget will be placed here
  
pages/ \
All separate pages will be under this directory

services/ \
Handle services such as queries to Firebase and geolocation from here

util/ \
Handle in-app utilities such as profile image selection here

scripts/ \
Web scraper of BU events calendar here

test/ \
All automated testing files are in this directory

<a name="troubleshooting"></a>
### Troubleshooting
- Pod Install Version Mismatches
  - If there are any issues with version mismatches, delete the 'podfile.lock' file and re-run the same commmand.
- Flutter dependencies installing issues or 'flutter run' issues
  - Run 'flutter clean' to clean out all dependencies for a fresh start, and re-install the dependencies and try running the app again
- Error building application for simulator or launching application
  - Re-run 'flutter run' or 'flutter clean' and restart the steps of installing and running to be extra safe

## Future Scope

### Features to be Implemented
- **Interests Page**: Develop a page where students can select their interests, and see events based on their interests
- **Friends**: Develop a friends system where users can add friends, view each other's profile and passport, and invite each other to upcoming events
- **Event comments**: Allow users to comment on events in order to provide feedback to administrators
- **Privacy**: Give users the option to hide their profile from others and/or leave anonymous event comments
