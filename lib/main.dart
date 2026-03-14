import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const SpeakOutApp());
}

class SpeakOutApp extends StatelessWidget {
  const SpeakOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpeakOut',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class Reminder {
  final String text;
  final TimeOfDay time;

  Reminder({required this.text, required this.time});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reminder> reminders = [];
  FlutterTts flutterTts = FlutterTts();
  void openAddReminder() async {
    final newReminder = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );

    if (newReminder != null) {
      setState(() {
        reminders.add(newReminder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SpeakOut Reminders"),
      ),
      body: reminders.isEmpty
          ? const Center(
              child: Text(
                "No reminders yet",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final r = reminders[index];
                return ListTile(
                  title: Text(r.text),
                  subtitle: Text(r.time.format(context)),
                  onTap: () {
                    speakReminder(r.text);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddReminder,
        child: const Icon(Icons.add),
      ),
    );
  }
  Future speakReminder(String text) async {
    await flutterTts.speak("Reminder: $text");
  }
}

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController reminderController = TextEditingController();
  TimeOfDay? selectedTime;

  Future<void> pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void saveReminder() {
    String text = reminderController.text;

    if (text.isNotEmpty && selectedTime != null) {
      Navigator.pop(
        context,
        Reminder(
          text: text,
          time: selectedTime!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reminder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: reminderController,
              decoration: const InputDecoration(
                labelText: "Reminder Text",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickTime,
              child: Text(
                selectedTime == null
                    ? "Select Time"
                    : "Time: ${selectedTime!.format(context)}",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveReminder,
              child: const Text("Save Reminder"),
            ),
          ],
        ),
      ),
    );
  }
}