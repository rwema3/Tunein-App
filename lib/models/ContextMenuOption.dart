import 'package:flutter/material.dart';

class ContextMenuOptions {
  ContextMenuOptions({this.title, this.icon, this.function, this.id});
  String title;
  IconData icon;
  VoidCallback function;
  int id;
  @override
  String toString() {
    return "ContextMenuOptions{title:${this.title},icon:${this.icon},id:${this.id}";
  }

}