import 'package:flutter/material.dart';
import 'package:habitt_app/services/habit_service.dart'; // import HabitService

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, List<int>> weeklyData = {};
  List<String> selectedHabits = [];
  final List<String> daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    // ✅ fetch selected habits from HabitService
    final habits = await HabitService.getSelectedHabits();
    selectedHabits = habits.map((h) => h['name'] as String).toList();

    if (selectedHabits.isEmpty) {
      setState(() => weeklyData = {});
      return;
    }

    // ✅ fetch weeklyData from HabitService
    final data = await HabitService.getWeeklyData();
    setState(() {
      weeklyData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Weekly Report',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: weeklyData.isEmpty
          ? const Center(
              child: Text(
                'No data available. Please configure habits first.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: constraints.maxWidth, // ✅ take full screen width
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.blue.shade50,
                      ),
                      dataRowHeight: 60,
                      columnSpacing: 28,
                      columns: _buildColumns(),
                      rows: _buildRows(),
                    ),
                  ),
                );
              },
            ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      const DataColumn(
        label: Text('Habit', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      ...daysOfWeek.map(
        (day) => DataColumn(
          label: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    ];
  }

  List<DataRow> _buildRows() {
    return selectedHabits.map((habit) {
      return DataRow(
        cells: [
          DataCell(Text(habit)),
          ...List.generate(daysOfWeek.length, (index) {
            bool isCompleted = weeklyData[habit]?[index] == 1;
            return DataCell(
              Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: isCompleted ? Colors.green : Colors.red,
                size: 26,
              ),
            );
          }),
        ],
      );
    }).toList();
  }
}
