import Toybox.Lang;

class AqiException extends Exception {
  function initialize(message as String) {
    Exception.initialize();
    self.mMessage = "Unknown exception: " + message;
  }
}

class UnsupportedException extends AqiException {
  function initialize(message as String) {
    AqiException.initialize(message);
    self.mMessage = "Unsupported: " + message;
  }
}

class FatalErrorException extends AqiException {
  function initialize(message as String) {
    AqiException.initialize(message);
    self.mMessage = "Fatal error: " + message;
  }
}
