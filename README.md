# WiFi-IndoorLocalization-iOS
iOS app for collecting WiFi-based signal data per room and using it for indoor localization. The app allows the user to record WiFi samples in different rooms and later uses this data to estimate the current location based on proximity to known signals.

It uses Apple’s ```NEHotspotNetwork``` API to retrieve basic information about the currently connected WiFi network, such as SSID and BSSID.
Due to system limitations, signal strength (RSSI) is not available via public APIs. As a result, this app works with limited, less precise information and focuses on BSSID to distinguish room environments.

## Features

- Add and manage rooms.
- Record WiFi and location data while moving within a room.
- Export and import collected data as .json.
- Preview data for each recorded room.
- Room detection mode for real-time estimation.


Made for the University of Milan, 2025

<img width="777" height="442" alt="WiFi-Loc-intro" src="https://github.com/user-attachments/assets/3aae562c-6bd2-4ed4-8c13-e6f9e431cf3d" />

<img width="777" height="431" alt="Goal-project" src="https://github.com/user-attachments/assets/3c717e5a-7aff-41c2-a384-4c133f7ba22a" />

<img width="783" height="435" alt="image" src="https://github.com/user-attachments/assets/5d928778-23ea-4111-a441-eea1c5e2138c" />

<img width="764" height="430" alt="image" src="https://github.com/user-attachments/assets/9c56ec83-f836-4550-bcf7-a01d0703c758" />

<img width="789" height="438" alt="image" src="https://github.com/user-attachments/assets/c578bb07-3d25-46e9-8700-43b85250ce6d" />
