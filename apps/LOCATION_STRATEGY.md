# Location Strategy Decision (MVP Freeze)

- The official and only supported location package for all RoverGo Flutter apps is:

  **geolocator**

- All other packages (flutter_background_geolocation, background_location_tracker) are removed and unsupported.
- All location logic must use geolocator APIs.
- If background location is needed, use geolocator's background mode features.

---

## Migration Notes
- Remove any references to other location packages in code and pubspec.yaml.
- If you need to add new location features, update this document and notify the team.

---

This decision is locked for Play Store compliance and build stability.
