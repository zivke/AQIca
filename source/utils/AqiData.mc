import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Weather;

class AqiData {
  private var _latitude as Double?;
  private var _longitude as Double?;

  private var _stationName as String = "N/A";
  private var _aqi as Number?;
  private var _iaqi as Dictionary?;

  private var _boxSizeIncrement as Double = 0.02d;

  private var _apiToken as String?;

  function initialize() {
    // Check compatibility
    if (Toybox has :Weather) {
      var currentConditions = Weather.getCurrentConditions();
      if (currentConditions == null) {
        throw new FatalErrorException(
          "Current weather conditions not available"
        );
      }

      if (currentConditions.observationLocationPosition == null) {
        throw new FatalErrorException("Last know position not available");
      }
    } else {
      throw new UnsupportedException("Weather module not supported");
    }
  }

  function load() {
    reset();

    if (_latitude == null || _longitude == null) {
      throw new FatalErrorException("Invalid last known location");
    }

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

    // System.println("Last known location: " + _latitude + "; " + _longitude);

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
                requestHttpDataByPositionBox(
                  _latitude + _boxSizeIncrement,
                  _longitude - _boxSizeIncrement,
                  _latitude - _boxSizeIncrement,
                  _longitude + _boxSizeIncrement
                );
                return; // Do not update the UI, but repeat the request/response cycle

                // TODO: Inform the user what is happening
              } else if (data.size() == 1) {
                // Success - we were lucky and there is only one station in the vicinity
                // Get the station index, request the data using the index and extract the data
                var station = data[0] as Dictionary;
                if (station.hasKey("uid")) {
                  var uid = station.get("uid") as Number;
                  requestHttpDataByStationUid(uid);
                  return; // Do not update the UI, but repeat the request/response cycle

                  // TODO: Inform the user what is happening
                } else {
                  // TODO: Malformed response
                  System.println("Malformed response received: " + response);
                }
              } else {
                // Multiple stations found in the box
                // Go through all of the received stations and select the closest one, get its index
                // and request the data using the index and then extract the data
                var closestUid = null;
                var minDistance = null;
                for (var i = 0; i < data.size(); i++) {
                  var station = data[i] as Dictionary;
                  if (station.hasKey("lat") && station.hasKey("lon")) {
                    var latitude = station.get("lat") as Double;
                    var longitude = station.get("lon") as Double;
                    var distance =
                      _latitude - latitude + _longitude - longitude;

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
                  requestHttpDataByStationUid(closestUid);
                  return; // Do not update the UI, but repeat the request/response cycle

                  // TODO: Inform the user what is happening
                } else {
                  // TODO: Something went horribly wrong
                }
              }
            } else {
              // The station has been requested by index and received
              var data = response.get("data") as Dictionary;
              extractData(data);
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

    WatchUi.requestUpdate();
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
