import 'package:get/get.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  // Lista de tareas (pastillas) observables
  var taskList = <Task>[].obs;

  // Agregar nueva tarea
  void addTask(Task task) {
    taskList.add(task);
  }

  // Actualizar la cantidad de una pastilla
  void updateTaskQuantity(Task task, int newQuantity) {
    task.quantity = newQuantity;
    taskList.refresh();
  }

  // Eliminar una tarea
  void deleteTask(Task task) {
    taskList.remove(task);
  }

  // Obtener las tareas que tienen alertas activas en la hora actual
  List<Task> getTasksForNow() {
    DateTime now = DateTime.now();
    return taskList.where((task) => 
      task.time.hour == now.hour && task.time.minute == now.minute
    ).toList();
  }
}
