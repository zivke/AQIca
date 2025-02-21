import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Weather;

class Status {
  enum Code {
    UNKNOWN_ERROR = -11,
    INVALID_DATA_RECEIVED = -10,
    NO_STATIONS_FOUND = -9,
    API_TOKEN_OVER_QUOTA = -8,
    API_TOKEN_INVALID = -7,
    API_TOKEN_NOT_FOUND = -6,
    POSITION_INVALID = -5,
    POSITION_NOT_AVAILABLE = -4,
    WEATHER_CONDITIONS_NOT_AVAILABLE = -3,
    WEATHER_NOT_SUPPORTED = -2,
    NOT_INITIALIZED = -1,
    INITIALIZING = 0,
    INITIALIZED = 1,
    LOADING = 2,
    FINDING_NEARBY_STATIONS = 3,
    FINDING_CLOSEST_STATION = 4,
    FETCHING_DATA = 5,
    DONE = 6,
  }

  private var _code as Code = NOT_INITIALIZED;

  function getCode() as Code {
    return _code;
  }

  function setCode(code as Code) {
    self._code = code;
    WatchUi.requestUpdate();
  }

  function hasError() {
    return _code < 0;
  }

  function getMessage() as String {
    switch (self._code) {
      case INVALID_DATA_RECEIVED:
        return "Invalid data received";
      case NO_STATIONS_FOUND:
        return "There are no active measuring stations in the vicinity";
      case API_TOKEN_OVER_QUOTA:
        return "API token over quota. Please contact support.";
      case API_TOKEN_INVALID:
        return "API token not valid";
      case API_TOKEN_NOT_FOUND:
        return "API token cannot be found";
      case POSITION_INVALID:
        return "Current position is invalid";
      case POSITION_NOT_AVAILABLE:
        return "Position not available - Please check the position permission";
      case WEATHER_CONDITIONS_NOT_AVAILABLE:
        return "Current weather conditions are not available";
      case WEATHER_NOT_SUPPORTED:
        return "Not supported on this watch model";
      case NOT_INITIALIZED:
        return "Not initialized yet";
      case INITIALIZING:
        return "Initializing...";
      case INITIALIZED:
        return "Initialized successfully";
      case LOADING:
        return "Loading...";
      case FINDING_NEARBY_STATIONS:
        return "Finding nearby measuring stations...";
      case FINDING_CLOSEST_STATION:
        return "Finding the closest measuring station...";
      case FETCHING_DATA:
        return "Measuring station found. Fetching data...";
      case DONE:
        return "Done";
      default: {
        if (_code < 0) {
          return "Unknown error";
        } else {
          return "Status unknown";
        }
      }
    }
  }
}

class AqiData {
  private var _status as Status;

  private var _latitude as Double?;
  private var _longitude as Double?;

  private var _attributions as String = "N/A";
  private var _stationName as String = "N/A";
  private var _stationDistanceKm as Double?;
  private var _aqi as Number?;
  private var _dominantPollutant as String = "N/A";
  private var _pm25 as Number?;
  private var _pm10 as Number?;
  private var _co as Float?;
  private var _no2 as Float?;
  private var _o3 as Float?;
  private var _so2 as Float?;
  private var _temperature as Number?;
  private var _humidity as Number?;
  private var _pressure as Number?;
  private var _wind as Float?;
  private var _dewPoint as Number?;

  private var _boxSizeIncrement as Double = 0.02d;

  private var _apiToken as String?;

  function initialize() {
    self._status = new Status();

    _status.setCode(Status.INITIALIZING);

    // Check compatibility
    if (Toybox has :Weather) {
      var currentConditions = Weather.getCurrentConditions();
      if (currentConditions == null) {
        _status.setCode(Status.WEATHER_CONDITIONS_NOT_AVAILABLE);
      }

      if (currentConditions.observationLocationPosition == null) {
        _status.setCode(Status.POSITION_NOT_AVAILABLE);
      }
    } else {
      _status.setCode(Status.WEATHER_NOT_SUPPORTED);
    }

    _status.setCode(Status.INITIALIZED);
  }

  function load() {
    if (_status.hasError()) {
      return;
    }

    _status.setCode(Status.LOADING);

    reset();

    if (_latitude == null || _longitude == null) {
      _status.setCode(Status.POSITION_INVALID);
      return;
    }

    // System.println("Last known location: " + _latitude + "; " + _longitude);

    if (_apiToken == null || _apiToken.equals("")) {
      _status.setCode(Status.API_TOKEN_NOT_FOUND);
      return;
    }

    _status.setCode(Status.FINDING_NEARBY_STATIONS);

    requestHttpDataByPositionBox(
      _latitude + _boxSizeIncrement,
      _longitude - _boxSizeIncrement,
      _latitude - _boxSizeIncrement,
      _longitude + _boxSizeIncrement
    );
  }

  function destroy() {
    Communications.cancelAllRequests();
  }

  function getStatus() as Status {
    return _status;
  }

  function getAttributions() as String {
    return _attributions;
  }

  function getStationName() as String {
    return _stationName;
  }

  function getStationDistanceKm() as Double? {
    return _stationDistanceKm;
  }

  function getAqi() as Number? {
    return _aqi;
  }

  function getDominantPollutant() as String {
    return _dominantPollutant;
  }

  function getPm25() as Number? {
    return _pm25;
  }

  function getPm10() as Number? {
    return _pm10;
  }

  function getCo() as Float? {
    return _co;
  }

  function getNo2() as Float? {
    return _no2;
  }

  function getO3() as Float? {
    return _o3;
  }

  function getSo2() as Float? {
    return _so2;
  }

  function getTemperature() as Number? {
    return _temperature;
  }

  function getHumidity() as Number? {
    return _humidity;
  }

  function getPressure() as Number? {
    return _pressure;
  }

  function getWind() as Float? {
    return _wind;
  }

  function getDewPoint() as Number? {
    return _dewPoint;
  }

  private function reset() {
    var lastKnownLocation =
      Weather.getCurrentConditions().observationLocationPosition.toDegrees();

    _latitude = lastKnownLocation[0] as Double;
    _longitude = lastKnownLocation[1] as Double;

    _stationName = "N/A";
    _stationDistanceKm = null;
    _aqi = null;
    _dominantPollutant = "N/A";
    _pm25 = null;
    _pm10 = null;
    _co = null;
    _no2 = null;
    _o3 = null;
    _so2 = null;
    _temperature = null;
    _humidity = null;
    _pressure = null;
    _wind = null;
    _dewPoint = null;

    _boxSizeIncrement = 0.02d;

    _apiToken = Properties.getValue("ApiKey") as String?;
  }

  private function requestHttpDataByPositionBox(
    latitude1 as Double,
    longitude1 as Double,
    latitude2 as Double,
    longitude2 as Double
  ) {
    var url =
      "https://api2.waqi.info/map/bounds?latlng=" +
      latitude1.toString() +
      "," +
      longitude1.toString() +
      "," +
      latitude2.toString() +
      "," +
      longitude2.toString() +
      "&networks=all&token=" +
      _apiToken;

    makeHttpRequest(url);
  }

  private function requestHttpDataByStationUid(uid as Number) {
    var url = "https://api2.waqi.info/feed/@" + uid + "/?token=" + _apiToken;

    makeHttpRequest(url);
  }

  private function makeHttpRequest(url as String) as Void {
    // System.println("Request sent: " + url);

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
    };
    Communications.makeWebRequest(url, {}, options, method(:onHttpResponse));
  }

  function onHttpResponse(
    responseCode as Number,
    response as Null or Dictionary or String
  ) as Void {
    if (responseCode == 200) {
      if (response != null && response instanceof Dictionary) {
        if (response.hasKey("status")) {
          if (response.get("status").equals("ok")) {
            // System.println("Data received: " + response);

            if (response.hasKey("data")) {
              if (response.get("data") instanceof Array) {
                var data = response.get("data") as Array<Dictionary>;
                if (data.size() == 0) {
                  // Increase the box and repeat the request
                  _boxSizeIncrement *= 2;
                  if (_boxSizeIncrement < 0.5) {
                    // Repeat the request/response cycle with a larger box
                    requestHttpDataByPositionBox(
                      _latitude + _boxSizeIncrement,
                      _longitude - _boxSizeIncrement,
                      _latitude - _boxSizeIncrement,
                      _longitude + _boxSizeIncrement
                    );
                  } else {
                    // The box is too large, there is no point in searching any more
                    _status.setCode(Status.NO_STATIONS_FOUND);
                  }

                  return;
                } else if (data.size() == 1) {
                  // Success - we were lucky and there is only one station in the vicinity
                  // Get the station index, request the data using the index and extract the data
                  _status.setCode(Status.FETCHING_DATA);

                  var station = data[0] as Dictionary;
                  if (station.hasKey("uid")) {
                    // Repeat the request/response cycle for the found measuring station
                    var uid = station.get("uid") as Number;
                    requestHttpDataByStationUid(uid);
                    return;
                  } else {
                    // Malformed response
                    System.println("Malformed response received: " + response);

                    _status.setCode(Status.INVALID_DATA_RECEIVED);
                  }
                } else {
                  // Multiple stations found in the box
                  // Go through all of the received stations and select the closest one, get its index
                  // and request the data using the index and then extract the data
                  _status.setCode(Status.FINDING_CLOSEST_STATION);

                  var closestUid = null;
                  var minDistance = null;
                  for (var i = 0; i < data.size(); i++) {
                    var station = data[i] as Dictionary;
                    if (station.hasKey("lat") && station.hasKey("lon")) {
                      var latitude = station.get("lat") as Double;
                      var longitude = station.get("lon") as Double;
                      var distance =
                        (_latitude - latitude).abs() +
                        (_longitude - longitude).abs();

                      if (station.hasKey("uid")) {
                        var uid = station.get("uid") as Number;
                        if (closestUid == null) {
                          closestUid = uid;
                        }

                        if (minDistance == null) {
                          minDistance = distance;
                        }

                        if (distance < minDistance) {
                          minDistance = distance;
                          closestUid = uid;
                        }
                      } else {
                        // Malformed response
                        System.println(
                          "Malformed response received: " + response
                        );

                        _status.setCode(Status.INVALID_DATA_RECEIVED);
                      }
                    } else {
                      // Malformed response
                      System.println(
                        "Malformed response received: " + response
                      );

                      _status.setCode(Status.INVALID_DATA_RECEIVED);
                    }
                  }

                  if (closestUid != null) {
                    // Repeat the request/response cycle
                    _status.setCode(Status.FETCHING_DATA);
                    requestHttpDataByStationUid(closestUid);
                    return;
                  } else {
                    _status.setCode(Status.UNKNOWN_ERROR);
                    return;
                  }
                }
              } else if (response.get("data") instanceof Dictionary) {
                // The station has been requested by index and received
                var data = response.get("data") as Dictionary;
                extractData(data);
                _status.setCode(Status.DONE);
                return;
              } else {
                // Malformed response
                System.println("Malformed response received: " + response);

                _status.setCode(Status.INVALID_DATA_RECEIVED);
              }
            } else {
              // Malformed response
              System.println("Malformed response received: " + response);

              _status.setCode(Status.INVALID_DATA_RECEIVED);
            }
          } else if (response.get("status").equals("error")) {
            if (response.hasKey("data")) {
              var message = response.get("data") as String;
              if (message.equals("Invalid key")) {
                _status.setCode(Status.API_TOKEN_INVALID);
              } else if (message.equals("Over quota")) {
                _status.setCode(Status.API_TOKEN_OVER_QUOTA);
              } else {
                _status.setCode(Status.UNKNOWN_ERROR);
              }
            } else {
              // Malformed response
              System.println("Malformed response received: " + response);

              _status.setCode(Status.INVALID_DATA_RECEIVED);
            }
          } else {
            // Malformed response
            System.println("Malformed response received: " + response);

            _status.setCode(Status.INVALID_DATA_RECEIVED);
          }
        } else {
          // Malformed response
          System.println("Malformed response received: " + response);

          _status.setCode(Status.INVALID_DATA_RECEIVED);
        }
      } else {
        // Invalid data received
        System.println("Invalid response received: " + response);

        _status.setCode(Status.INVALID_DATA_RECEIVED);
      }
    } else {
      // responseCode != 200
      System.println("Error response code: " + responseCode);

      _status.setCode(Status.INVALID_DATA_RECEIVED);
    }
  }

  private function extractData(data as Dictionary) {
    if (data.hasKey("attributions")) {
      var attributions = data.get("attributions") as Array;
      if (attributions[0].hasKey("name")) {
        _attributions = attributions[0].get("name") as String;
      }
    }

    if (data.hasKey("city")) {
      var city = data.get("city") as Dictionary;
      if (city.hasKey("location")) {
        _stationName = city.get("location") as String;
        if (city.hasKey("name")) {
          var name = city.get("name") as String;
          _stationName =
            name.length() > _stationName.length() ? name : _stationName;
        }
      } else {
        // Malformed response received
        System.println("Malformed data received: " + data);
      }

      if (city.hasKey("geo")) {
        var geo = city.get("geo") as Array<Double>?;
        if (geo != null && geo.size() == 2) {
          var stationLatitude = geo[0];
          var stationLongitude = geo[1];

          if (stationLatitude == null || stationLongitude == null) {
            _stationDistanceKm = null;
          } else {
            _stationDistanceKm = distance(
              _latitude,
              _longitude,
              stationLatitude,
              stationLongitude
            );
          }
        }
      }
    } else {
      // Malformed response received
      System.println("Malformed data received: " + data);
    }

    if (data.hasKey("aqi")) {
      _aqi = data.get("aqi") as Number;
    } else {
      // Malformed response received
      System.println("Malformed data received: " + data);

      _status.setCode(Status.INVALID_DATA_RECEIVED);
    }

    if (data.hasKey("dominentpol")) {
      switch (data.get("dominentpol") as String) {
        case "pm25":
          _dominantPollutant = "PM 2.5";
          break;
        case "pm10":
          _dominantPollutant = "PM 10";
          break;
        case "co":
          _dominantPollutant = "CO";
          break;
        case "no2":
          _dominantPollutant = "NO2";
          break;
        case "o3":
          _dominantPollutant = "O3";
          break;
        case "so2":
          _dominantPollutant = "SO2";
          break;
        default:
          _dominantPollutant = "N/A";
          break;
      }
    }

    if (data.hasKey("iaqi")) {
      var iaqi = data.get("iaqi") as Dictionary;
      var tmp;
      if (iaqi.hasKey("pm25")) {
        tmp = iaqi.get("pm25") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _pm25 = tmp.get("v") as Number?;
        }
      }
      if (iaqi.hasKey("pm10")) {
        tmp = iaqi.get("pm10") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _pm10 = tmp.get("v") as Number?;
        }
      }
      if (iaqi.hasKey("co")) {
        tmp = iaqi.get("co") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _co = tmp.get("v") as Float?;
        }
      }
      if (iaqi.hasKey("no2")) {
        tmp = iaqi.get("no2") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _no2 = tmp.get("v") as Float?;
        }
      }
      if (iaqi.hasKey("o3")) {
        tmp = iaqi.get("o3") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _o3 = tmp.get("v") as Float?;
        }
      }
      if (iaqi.hasKey("so2")) {
        tmp = iaqi.get("so2") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _so2 = tmp.get("v") as Float?;
        }
      }
      if (iaqi.hasKey("t")) {
        tmp = iaqi.get("t") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _temperature = tmp.get("v") as Number?;
        }
      }
      if (iaqi.hasKey("h")) {
        tmp = iaqi.get("h") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _humidity = tmp.get("v") as Number?;
        }
      }
      if (iaqi.hasKey("p")) {
        tmp = iaqi.get("p") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _pressure = tmp.get("v") as Number?;
        }
      }
      if (iaqi.hasKey("w")) {
        tmp = iaqi.get("w") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _wind = tmp.get("v") as Float?;
        }
      }
      if (iaqi.hasKey("dew")) {
        tmp = iaqi.get("dew") as Dictionary?;
        if (tmp != null && tmp.hasKey("v")) {
          _dewPoint = tmp.get("v") as Number?;
        }
      }
    } else {
      // Malformed response
      System.println("Malformed data received: " + data);
    }
  }

  function distance(
    latitude1 as Double,
    longitude1 as Double,
    latitude2 as Double,
    longitude2 as Double
  ) as Double {
    var dx, dy, dz;
    longitude1 -= longitude2;
    longitude1 = Math.toRadians(longitude1);
    latitude1 = Math.toRadians(latitude1);
    latitude2 = Math.toRadians(latitude2);

    dz = Math.sin(latitude1) - Math.sin(latitude2);
    dx = Math.cos(longitude1) * Math.cos(latitude1) - Math.cos(latitude2);
    dy = Math.sin(longitude1) * Math.cos(latitude1);

    return Math.asin(Math.sqrt(dx * dx + dy * dy + dz * dz) / 2) * 2 * 6371;
  }
}
