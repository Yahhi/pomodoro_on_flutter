class Setting {
  static const TYPE_SELECT = 1;
  static const TYPE_SWITCH = 2;

  String key;
  String title;
  int type;
  String _defaultValue;
  String _actualValue;
  List<String> possibleOptions;

  Setting(this.key, this.title, this.type, this._defaultValue);

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
