class SpeedHandler {
  final String _type;
  final double _speed;
  SpeedHandler(this._speed, this._type);

  Map toJson() => {'speed': _speed, 'type': _type};
}

class Calibration {
  final String _type;
  Calibration(this._type);

  Map toJson() => {'type': _type};
}

class AudioVideoHandler {
  final String _type;
  AudioVideoHandler(this._type);

  Map toJson() => {'type': _type};
}
