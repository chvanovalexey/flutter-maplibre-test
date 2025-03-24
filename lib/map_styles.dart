/// **Use your own key for your project!**
///
/// This key will be rotated occasionally.
class MapStyles {
  // Style URLs
  static const protomapsLight =
      'https://api.protomaps.com/styles/v2/light.json?key=$_protomapsKey';
  static const protomapsDark =
      'https://api.protomaps.com/styles/v2/dark.json?key=$_protomapsKey';
  static const maptilerStreets =
      'https://api.maptiler.com/maps/streets-v2/style.json?key=$_maptilerKey';

  // Display names for styles (for UI)
  static const protomapsLightName = 'Protomaps Light';
  static const protomapsDarkName = 'Protomaps Dark';
  static const maptilerStreetsName = 'Maptiler Streets';

  // API keys
  static const _maptilerKey = 'OPCgnZ51sHETbEQ4wnkd';
  static const _protomapsKey = 'a6f9aebb3965458c';

  // Get all styles as a map of URL -> display name
  static Map<String, String> getAllStyles() {
    return {
      protomapsLight: protomapsLightName,
      protomapsDark: protomapsDarkName,
      maptilerStreets: maptilerStreetsName,
    };
  }
}
