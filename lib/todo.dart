class ToDo{
  final int? id;
  final String task;
  final bool completed;

  ToDo({this.id, required this.task, required this.completed});

  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      task: json['task'],
      completed: json['completed']
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'completed': completed
    };
  }
}