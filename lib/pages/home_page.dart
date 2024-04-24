// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import 'package:provider/provider.dart';

// video is 30:00
// url -> https://www.youtube.com/watch?v=TLaWibjFArw&t=13s

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
  }

  TextEditingController textEditingController = TextEditingController();
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: "Create a new habit",
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(20)],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              textEditingController.clear();
            },
            child: const Text(
              "Cancel",
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (textEditingController.text.isNotEmpty) {
                  String newHabitName = textEditingController.text;

                  context.read<HabitDatabase>().addHabit(newHabitName);
                  Navigator.pop(context);
                  textEditingController.clear();
                }
              },
              child: const Text(
                "Create",
              )),
        ],
      ),
    );
  }

  void checkHabitOnOf(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit) {
    textEditingController.text = habit.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: "Update a habit",
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(20)],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (textEditingController.text.isNotEmpty) {
                  String newHabitName = textEditingController.text;

                  context
                      .read<HabitDatabase>()
                      .updateHabitName(habit.id, newHabitName);
                  Navigator.pop(context);
                  textEditingController.clear();
                }
              },
              child: const Text(
                "Update",
              )),
        ],
      ),
    );
  }

  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Habit?"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              textEditingController.clear();
            },
            child: const Text(
              "Cancel",
            ),
          ),
          ElevatedButton(
              onPressed: () {
                context.read<HabitDatabase>().deleteHabit(habit.id);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawerWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createNewHabit(),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        
        children: [
          buildHeatMap(),
          buildHabitList(),
        ],
      ),
    );
  }

  Widget buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLouchData(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return MyHeatMap(startDate: snapshot.data!, datasets: prepHeatMapDataset(currentHabits));
        }else{
          return Container();
        }
      },
    );
  }

  Widget buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        final habit = currentHabits[index];
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
        return MyHabitTile(
          isCompleted: isCompletedToday,
          text: habit.name,
          onChanged: (value) => checkHabitOnOf(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
    // return null;
  }
}
