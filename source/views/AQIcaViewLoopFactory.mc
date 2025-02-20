import Toybox.Lang;
import Toybox.WatchUi;

class AQIcaViewLoopFactory extends WatchUi.ViewLoopFactory {
  private var _aqiData as AqiData;
  private var _views as Array<View>;

  function initialize(aqiData as AqiData) {
    self._aqiData = aqiData;

    self._views = [
      new AQIcaMainView(_aqiData),
      new AQIcaDetailsView(_aqiData),
      new AQIcaInfoView("Measuring\nstation:", _aqiData.getStationName()),
      new AQIcaInfoView("Data\nsource:", _aqiData.getAttributions()),
    ];

    ViewLoopFactory.initialize();
  }

  public function getSize() {
    return _views.size();
  }

  public function getView(index as Number) {
    return [_views[index], new BehaviorDelegate()];
  }
}
