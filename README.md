### Running 'pod install'
Before running this app for the first time, you have to install pod files. To do this, ensure that you are in the '/ios' directory and execute the following command:
```bash
cd 
pod install
```
If there are any issues with version mismatches, delete the 'podfile.lock' file and re-run the same commmand.

# Project Architecture

![alt text](./passportArchitecture.png)

# Directory Structure:

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


