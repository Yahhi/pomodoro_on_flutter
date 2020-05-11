class SavedInterval {
  final int minutes;
  final int seconds;
  final DateTime started;
  final int projectId;

  SavedInterval(this.minutes, this.seconds, this.started, {this.projectId = 0});

  Map<String, dynamic> get map => {
    'minutes': minutes,
    'seconds': seconds,
    'started': started.millisecondsSinceEpoch,
    'project_id': projectId,
  };

  SavedInterval.fromMap(Map<String, dynamic> map) : minutes = map['minutes'],
        seconds = map['seconds'], started = DateTime.fromMillisecondsSinceEpoch(map['started']), projectId = map['project_id'];
}
