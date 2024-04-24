# BU Arts Passport

## Description
BU Arts Passport is a simple and lightweight mobile app developed using Flutter that tracks student engagement in arts events hosted by the BU Arts department. 
This project aims to streamline the process of attending art events at school: starting from seeing the ongoing and upcoming events, 
finding out the details of interested events, to finally checking in and tracking the participation to these events.

## Installation and Usage
1. Clone into the repository
```bash
# Use either HTTPS or SSH
git clone https://github.com/BU-Spark/se-bu-passport-arts.git

cd se-bu-passport-arts
```

2. Install Dependencies
```bash
flutter pub get
```
Since our application is built using Flutter, the command above will download all the necessary dependencies to run the project.

3. Run the application locally
```bash
flutter run
```
Running this command will run the app locally, either via an Android simulator or iOS simulator. Ensure that you have either simulators installed and 
selected before running this command.

## Project Architecture

![alt text](./passportArchitecture.png)

## Directory Structure:

auth/  
Handles authentication of user by checking if they are logged in or not
  
pages/  
All separate pages will be under this directory

services/
Handle services such as queries to Firebase from here

classes/
All classes will be here

components/
Reusable widgets such as an event_widget will be placed here
