/// **Use your own key for your project!**  
///  
/// This key will be rotated occasionally.  
class MapStyles {  
  // MapTiler Style URLs  
  static const maptilerStreets =  
      'https://api.maptiler.com/maps/streets-v2/style.json?key=$_maptilerKey';  
  static const maptilerSatellite =  
      'https://api.maptiler.com/maps/satellite/style.json?key=$_maptilerKey';  
  static const maptilerHybrid =  
      'https://api.maptiler.com/maps/hybrid/style.json?key=$_maptilerKey';  
  static const maptilerTopo =  
      'https://api.maptiler.com/maps/topo/style.json?key=$_maptilerKey';  
  static const maptilerWinter =  
      'https://api.maptiler.com/maps/winter/style.json?key=$_maptilerKey';  
  static const maptilerBasic =  
      'https://api.maptiler.com/maps/basic/style.json?key=$_maptilerKey';  
  static const maptilerBright =  
      'https://api.maptiler.com/maps/bright/style.json?key=$_maptilerKey';  
  static const maptilerOutdoor =  
      'https://api.maptiler.com/maps/outdoor/style.json?key=$_maptilerKey';  
  static const maptilerVoyager =  
      'https://api.maptiler.com/maps/voyager/style.json?key=$_maptilerKey';  
  static const maptilerDarkMatter =  
      'https://api.maptiler.com/maps/darkmatter/style.json?key=$_maptilerKey';  
  static const maptilerPositron =  
      'https://api.maptiler.com/maps/positron/style.json?key=$_maptilerKey';  

  // New MapTiler styles
  static const maptilerDataviz =
      'https://api.maptiler.com/maps/dataviz/style.json?key=$_maptilerKey';
  static const maptilerOpenstreetmap =
      'https://api.maptiler.com/maps/openstreetmap/style.json?key=$_maptilerKey';
  static const maptilerLandscape =
      'https://api.maptiler.com/maps/landscape/style.json?key=$_maptilerKey';
  static const maptilerOcean =
      'https://api.maptiler.com/maps/ocean/style.json?key=$_maptilerKey';
  static const maptilerM1 =
      'https://api.maptiler.com/maps/0195cf1d-7710-7e7b-a3b3-aaccaf0d7521/style.json?key=$_maptilerKey';

  // Display names for MapTiler styles (for UI)  
  static const maptilerStreetsName = 'Maptiler Streets';  
  static const maptilerSatelliteName = 'Maptiler Satellite';  
  static const maptilerHybridName = 'Maptiler Hybrid';  
  static const maptilerTopoName = 'Maptiler Topo';  
  static const maptilerWinterName = 'Maptiler Winter';  
  static const maptilerBasicName = 'Maptiler Basic';  
  static const maptilerBrightName = 'Maptiler Bright';  
  static const maptilerOutdoorName = 'Maptiler Outdoor';  
  static const maptilerVoyagerName = 'Maptiler Voyager';  
  static const maptilerDarkMatterName = 'Maptiler Dark Matter';  
  static const maptilerPositronName = 'Maptiler Positron';  

  // Names for new MapTiler styles
  static const maptilerDatavizName = 'Maptiler Dataviz';
  static const maptilerOpenstreetmapName = 'Maptiler Openstreetmap';
  static const maptilerLandscapeName = 'Maptiler Landscape';
  static const maptilerOceanName = 'Maptiler Ocean';
  static const maptilerM1Name = 'M1';

  // API keys  
  static const _maptilerKey = 'SovRGVsIsJ1GuVGu2753';  

  // Get all styles as a map of URL -> display name  
  static Map<String, String> getAllStyles() {  
    return {  
      // MapTiler styles  
      maptilerStreets: maptilerStreetsName,  
      maptilerSatellite: maptilerSatelliteName,  
      maptilerHybrid: maptilerHybridName,  
      maptilerTopo: maptilerTopoName,  
      maptilerWinter: maptilerWinterName,  
      maptilerBasic: maptilerBasicName,  
      maptilerBright: maptilerBrightName,  
      maptilerOutdoor: maptilerOutdoorName,  
      maptilerVoyager: maptilerVoyagerName,  
      maptilerDarkMatter: maptilerDarkMatterName,  
      maptilerPositron: maptilerPositronName,  
      
      // New MapTiler styles
      maptilerDataviz: maptilerDatavizName,
      maptilerOpenstreetmap: maptilerOpenstreetmapName,
      maptilerLandscape: maptilerLandscapeName,
      maptilerOcean: maptilerOceanName,
      maptilerM1: maptilerM1Name,
    };  
  }  
  
  // Get MapTiler styles only  
  static Map<String, String> getMapTilerStyles() {  
    return {  
      maptilerStreets: maptilerStreetsName,  
      maptilerSatellite: maptilerSatelliteName,  
      maptilerHybrid: maptilerHybridName,  
      maptilerTopo: maptilerTopoName,  
      maptilerWinter: maptilerWinterName,  
      maptilerBasic: maptilerBasicName,  
      maptilerBright: maptilerBrightName,  
      maptilerOutdoor: maptilerOutdoorName,  
      maptilerVoyager: maptilerVoyagerName,  
      maptilerDarkMatter: maptilerDarkMatterName,  
      maptilerPositron: maptilerPositronName,  
      
      // New MapTiler styles
      maptilerDataviz: maptilerDatavizName,
      maptilerOpenstreetmap: maptilerOpenstreetmapName,
      maptilerLandscape: maptilerLandscapeName,
      maptilerOcean: maptilerOceanName,
      maptilerM1: maptilerM1Name,
    };  
  }  
} 