#  Chase iOS Take Home Assigment

This is a weather app powered by OpenWeather API

## Installation

Run on Xcode Simulator and/or device

## Key Features
- Uses Combine, Concurrency, & SwiftUI framework
- Added an additonal 10-day forecast for more info
- Users can search for city
- Loads last saved location
- Added error handling
- Listens to CL authStatus changes for error handling
- Added helper methods to calculate information not provided clearly by the API

## Important Notices
- This project was developed using Xcode 15
- Some of the simulators may not behave properly. PLEASE USE PHYSICAL DEVICE IF YOU RUN INTO TROUBLE
- The API response didn't return `Feels Like` value so I used humidity instead
- The API response didn't return the accurate weather description so I used the default value instead
- The app doesn't look good across all devices. The problem is how I laid out the SwiftUI embedded view in the view controller

## Developed By
Chris Rene
