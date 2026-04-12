import 'package:flutter/material.dart';

import 'signs_study_screen.dart';

@Deprecated('Dùng SignsStudyScreen hoặc SignsExamScreen thay cho SignsQuizScreen.')
class SignsQuizScreen extends StatelessWidget {
  const SignsQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignsStudyScreen();
  }
}