import 'dart:io';

import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.leisure;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Invalid Input'),
          content: const Text(
              'Please make sure a valid Title, Amount, Date and Category was entered.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("Okay")),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Input'),
          content: const Text(
              'Please make sure a valid Title, Amount, Date and Category was entered.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("Okay")),
          ],
        ),
      );
    }
  }

  void _submitExpense() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;
    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      _showDialog();
      return;
    }

    widget.onAddExpense(
      Expense(
        category: _selectedCategory,
        date: _selectedDate!,
        title: _titleController.text.toUpperCase(),
        amount: enteredAmount,
      ),
    );
    Navigator.pop(context);
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickerDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickerDate;
    });
  }

  Widget title() => TextField(
        controller: _titleController,
        textCapitalization: TextCapitalization.characters,
        maxLength: 50,
        decoration: const InputDecoration(
          label: Text('Title'),
        ),
      );

  Widget amount() => Expanded(
        child: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '\$',
            label: Text('Amount'),
          ),
        ),
      );

  Widget category() => DropdownButton(
      value: _selectedCategory,
      items: Category.values
          .map(
            (category) => DropdownMenuItem(
              value: category,
              child: Text(
                category.name.toUpperCase(),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedCategory = value;
        });
      });

  Widget date() => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _selectedDate == null
                  ? 'No date selected'
                  : formatter.format(_selectedDate!),
            ),
            IconButton(
                onPressed: _presentDatePicker,
                icon: const Icon(Icons.calendar_month))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;

        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
              child: Column(
                children: [
                  if (width >= 600)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: title(),
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        amount(),
                      ],
                    )
                  else
                    title(),
                  if (width >= 600)
                    Row(
                      children: [
                        category(),
                        date(),
                      ],
                    )
                  else
                    Row(
                      children: [
                        amount(),
                        const SizedBox(width: 16),
                        date(),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (width <= 600)
                    Row(
                      children: [
                        category(),
                        const Spacer(),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                        ElevatedButton(
                            onPressed: _submitExpense,
                            child: const Text('Save Expense'))
                      ],
                    )
                  else
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                        ElevatedButton(
                            onPressed: _submitExpense,
                            child: const Text('Save Expense'))
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
