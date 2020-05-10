class Setting {
  static const TYPE_SELECT = 1;
  static const TYPE_SWITCH = 2;

  final String key;
  final String title;
  final int type;
  final String _defaultValue;
  String _actualValue;
  final List<String> possibleOptions;

  Setting(this.key, this.title, this.type, this._defaultValue,
      {this.possibleOptions});

  set value(String value) {
    _actualValue = value;
  }

  String get value {
    if (_actualValue == null) {
      return _defaultValue;
    } else {
      return _actualValue;
    }
  }
}
