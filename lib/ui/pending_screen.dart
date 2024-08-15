// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Pending Tasks',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tasksProvider.future),
        child: tasksAsyncValue.when(
          data: (tasks) => _buildTaskList(context, ref, tasks),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, WidgetRef ref, List<Task> tasks) {
    final pendingTasks =
        tasks.where((task) => task.status == 'pending').toList();
    final pendingTaskCount = pendingTasks.length;

    return Column(
      children: [
        _buildPendingTasksCard(context, pendingTaskCount),
        Expanded(
          child: ListView.builder(
            itemCount: pendingTasks.length,
            itemBuilder: (context, index) =>
                _buildTaskCard(context, ref, pendingTasks[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTasksCard(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.red[100],
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Tasks',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 10,
          height: double.infinity,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            task.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'complete':
                await _markTaskAsComplete(context, ref, task);
                break;
              case 'edit':
                await _showEditTaskDialog(context, ref, task);
                break;
              case 'delete':
                await _deleteTask(context, ref, task);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            _buildPopupMenuItem('Complete', Icons.check, Colors.green),
            _buildPopupMenuItem('Edit', Icons.edit, Colors.black),
            _buildPopupMenuItem('Delete', Icons.delete, Colors.red),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String text, IconData icon, Color color) {
    return PopupMenuItem<String>(
      value: text.toLowerCase(),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markTaskAsComplete(
      BuildContext context, WidgetRef ref, Task task) async {
    try {
      await ref.read(tasksNotifierProvider.notifier).updateStatus(task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task marked as a complete',
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          backgroundColor: Colors.green[200],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark task as complete: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTask(
      BuildContext context, WidgetRef ref, Task task) async {
    try {
      await ref.read(tasksNotifierProvider.notifier).removeTask(task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task deleted successfully',
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          backgroundColor: Colors.green[200],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete task: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditTaskDialog(
      BuildContext context, WidgetRef ref, Task task) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Task',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () => _updateTask(context, ref, task,
                  titleController.text, descriptionController.text),
              child: Text('Update', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTask(BuildContext context, WidgetRef ref, Task task,
      String title, String description) async {
    if (title.isNotEmpty && description.isNotEmpty) {
      try {
        await ref
            .read(tasksNotifierProvider.notifier)
            .updateTask(task.id, title, description);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task updated successfully',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
            backgroundColor: Colors.green[200],
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and description cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
