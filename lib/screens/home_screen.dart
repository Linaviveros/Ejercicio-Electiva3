import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TaskController taskController = Get.put(TaskController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recordatorio de Pastillas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: 'Poppins',
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 183, 178),
                  Color.fromARGB(255, 255, 218, 185),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Imágenes animadas de pastillas
          Positioned(
            top: 100,
            left: 30,
            child: AnimatedBuilder(
              animation: _animationController,
              child: Image.asset('assets/images/pill1.png', width: 330, height: 330),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 0.4,
                  child: child,
                );
              },
            ),
          ),
         
          Column(
            children: [
              Expanded(
                child: Obx(
                  () {
                    return ListView.builder(
                      itemCount: taskController.taskList.length,
                      itemBuilder: (context, index) {
                        Task task = taskController.taskList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            transform: Matrix4.translationValues(0, index.isEven ? 20.0 : -20.0, 0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 253, 250, 250).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              leading: Icon(
                                Icons.medication_liquid,
                                color: Colors.deepOrange,
                                size: 36,
                              ),
                              title: Text(
                                task.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(221, 244, 243, 243),
                                ),
                              ),
                              subtitle: Text(
                                'Cantidad restante: ${task.quantity}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Text(
                                'Hora: ${task.time.hour}:${task.time.minute}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddTaskDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text(
                    'Añadir Pastilla',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepOrangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TimeOfDay currentTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 240, 236, 236).withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Añadir Pastilla',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la pastilla',
                  icon: Icon(Icons.medical_services),
                ),
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Cantidad disponible',
                  icon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: currentTime,
                  );
                  if (selectedTime != null) {
                    final now = DateTime.now();
                    final alarmTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
                    final newTask = Task(
                      name: nameController.text,
                      time: alarmTime,
                      quantity: int.parse(quantityController.text),
                    );
                    taskController.addTask(newTask);
                    Get.back(); // Cerrar el diálogo
                  }
                },
                child: Text(
                  'Seleccionar hora',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 250, 244, 244)),
              ),
            ),
          ],
        );
      },
    );
  }
}
