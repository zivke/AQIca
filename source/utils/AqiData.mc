import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Weather;

class Status {
  enum Code {
    ERROR_UNKNOWN = -8,
    NO_STATIONS_FOUND = -7,
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
      case NO_STATIONS_FOUND:
        return "There are no active measuring stations in the vicinity";
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
          return "Unknown";
        }
      }
    }
  }
}

class AqiData {
  private var _status as Status;

  private var _latitude as Double?;
  private var _longitude as Double?;

  private var _stationName as String = "N/A";
  private var _aqi as Number?;
  private var _iaqi as Dictionary?;

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

  function getStationName() as String {
    return _stationName;
  }

  function getAqi() as Number? {
    return _aqi;
  }

  function getIaqi() as Dictionary? {
    return _iaqi;
  }

  private function reset() {
    var lastKnownLocation =
      Weather.getCurrentConditions().observationLocationPosition.toDegrees();

    _latitude = lastKnownLocation[0] as Double;
    _longitude = lastKnownLocation[1] as Double;

    _stationName = "N/A";
    _aqi = null;
    _iaqi = null;

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
        if (response.hasKey("status") && response.get("status").equals("ok")) {
          //   System.println("Data received: " + response);

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
                  // TODO: Malformed response
                  System.println("Malformed response received: " + response);
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
                      // TODO: Malformed response
                      System.println(
                        "Malformed response received: " + response
                      );
                    }
                  } else {
                    // TODO: Malformed response
                    System.println("Malformed response received: " + response);
                  }
                }

                if (closestUid != null) {
                  // Repeat the request/response cycle
                  _status.setCode(Status.FETCHING_DATA);
                  requestHttpDataByStationUid(closestUid);
                  return;
                } else {
                  _status.setCode(Status.ERROR_UNKNOWN);
                  return;
                }
              }
            } else {
              // The station has been requested by index and received
              var data = response.get("data") as Dictionary;
              extractData(data);
              _status.setCode(Status.DONE);
              return;
            }
          } else {
            // TODO: Malformed response
            System.println("Malformed response received: " + response);
          }
        } else {
          // TODO: error response received
          System.println("Error response received: " + response);
        }
      } else {
        // TODO: invalid data received
        System.println("Invalid response received: " + response);
      }
    } else {
      // TODO: responseCode != 200
      System.println("Error response code: " + responseCode);
    }
  }

  private function extractData(data as Dictionary) {
    if (data.hasKey("city")) {
      var city = data.get("city") as Dictionary;
      if (city.hasKey("location")) {
        _stationName = city.get("location") as String;
        if (_stationName.equals("")) {
          if (city.hasKey("name")) {
            _stationName = city.get("name") as String;
          }
        } else {
          // TODO: Malformed response received
          System.println("Malformed data received: " + data);
        }
      } else {
        // TODO: Malformed response received
        System.println("Malformed data received: " + data);
      }
    } else {
      // TODO: Malformed response received
      System.println("Malformed data received: " + data);
    }

    if (data.hasKey("aqi")) {
      _aqi = data.get("aqi") as Number;
    } else {
      // TODO: Malformed response received
      System.println("Malformed data received: " + data);
    }

    if (data.hasKey("iaqi")) {
      _iaqi = data.get("iaqi") as Dictionary;
    } else {
      // TODO: Malformed response
      System.println("Malformed data received: " + data);
    }
  }
}
