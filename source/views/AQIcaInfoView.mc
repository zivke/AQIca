import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class AQIcaInfoView extends AQIcaBaseView {
  private var _title as String?;
  private var _message as String;

  function initialize(
    title as String?,
    message as String,
    index as Number?,
    totalPages as Number?
  ) {
    self._title = title;
    self._message = message;

    AQIcaBaseView.initialize(index, totalPages);
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.InfoLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    AQIcaBaseView.onShow();
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Set the info title
    var infoTitleTextArea = View.findDrawableById("InfoTitle") as TextArea?;
    if (infoTitleTextArea != null && _title != null) {
      infoTitleTextArea.setText(_title);
    }

    // Set the info text area value
    var infoTextArea = View.findDrawableById("InfoMessageValue") as TextArea?;
    if (infoTextArea != null) {
      infoTextArea.setText(_message);
    }

    // Call the parent onUpdate function to redraw the layout
    AQIcaBaseView.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}
}
