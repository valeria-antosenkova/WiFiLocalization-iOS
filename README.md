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

<img width="1157" height="649" alt="intro" src="https://github.com/user-attachments/assets/f1559bf9-717a-43b4-b591-6b72fa98c248" />
<img width="1157" height="649" alt="goal" src="https://github.com/user-attachments/assets/ca7dc721-bc7a-4a2a-aa65-22125890db4c" />
<img width="1157" height="649" alt="phase1" src="https://github.com/user-attachments/assets/42ac79a3-ba86-41b4-9424-4f195dae588d" />
<img width="1157" height="649" alt="phase2" src="https://github.com/user-attachments/assets/73218ae5-02e4-492a-9f5b-86284c403a0f" />
<img width="1157" height="649" alt="demo" src="https://github.com/user-attachments/assets/5be6d188-2c53-447b-9de9-6aa0438b08b3" />


