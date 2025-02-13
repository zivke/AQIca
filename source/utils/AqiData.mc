import Toybox.Application;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.Weather;

class AqiData {
  private var _city as String = "N/A";
  private var _aqi as Number?;
  private var _pm25 as Number?;
  private var _pm10 as Number?;

  private var _apiToken as String?;

  function load() {
    reset();

    if (Toybox has :Weather) {
      var currentConditions = Weather.getCurrentConditions();
      if (currentConditions == null) {
        throw new FatalErrorException("Current weather conditions  not available");
      }

      if (currentConditions.observationLocationPosition == null) {
        throw new FatalErrorException("Last know position not available");
      }

      var lastKnownLocation =
        currentConditions.observationLocationPosition.toDegrees();

      var latitude = lastKnownLocation[0];
      var longitude = lastKnownLocation[1];

    //   System.println("Last known location: " + latitude + "; " + longitude);

      requestHttpDataByPosition(latitude, longitude);
    } else {
      throw new UnsupportedException("Weather module not supported");
    }
  }

  function destroy() {
    Communications.cancelAllRequests();
  }

  function getCity() as String {
    return _city;
  }

  function getAqi() as Number? {
    return _aqi;
  }

  function getPm25() as Number? {
    return _pm25;
  }

  function getPm10() as Number? {
    return _pm10;
  }

  private function reset() {
    _city = "N/A";
    _aqi = null;
    _pm25 = null;
    _pm10 = null;
    _apiToken = Properties.getValue("ApiKey") as String?;
  }

  private function requestHttpDataByPosition(
    latitude as Double,
    longitude as Double
  ) {
    var url =
      "https://api.waqi.info/feed/geo:" +
      latitude.toString() +
      ";" +
      latitude.toString() +
      "/?token=" +
      _apiToken;

    makeHttpRequest(url);
  }

  private function makeHttpRequest(url as String) as Void {
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
            var data = response.get("data") as Dictionary;
            if (data.hasKey("city")) {
              var city = data.get("city") as Dictionary;
              if (city.hasKey("name")) {
                _city = city.get("name") as String;
              } else {
                // TODO: Malformed response received
                System.println("Malformed response received: " + response);
              }
            } else {
              // TODO: Malformed response received
              System.println("Malformed response received: " + response);
            }

            if (data.hasKey("aqi")) {
              _aqi = data.get("aqi") as Number;
            } else {
              // TODO: Malformed response received
              System.println("Malformed response received: " + response);
            }

            if (data.hasKey("iaqi")) {
              var iaqi = data.get("iaqi") as Dictionary;
              if (iaqi.hasKey("pm25")) {
                var pm25 = iaqi.get("pm25") as Dictionary;
                if (pm25.hasKey("v")) {
                  _pm25 = pm25.get("v") as Number;
                } else {
                  // TODO: Malformed response received
                  System.println("Malformed response received: " + response);
                }
              } else {
                // TODO: Malformed response received
                System.println("Malformed response received: " + response);
              }

              if (iaqi.hasKey("pm10")) {
                var pm10 = iaqi.get("pm10") as Dictionary;
                if (pm10.hasKey("v")) {
                  _pm10 = pm10.get("v") as Number;
                } else {
                  // TODO: Malformed response
                  System.println("Malformed response received: " + response);
                }
              } else {
                // TODO: Malformed response
                System.println("Malformed response received: " + response);
              }
            } else {
              // TODO: Malformed response
              System.println("Malformed response received: " + response);
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
}
