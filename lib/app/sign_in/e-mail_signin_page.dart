import 'package:flutter/material.dart';
import 'package:login/app/sign_in/e-mail_sign_in_form_bloc_based.dart';


class EmailSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: EmailSignInFormBlocBased.create(context),
          ),
        ),
      ),
            backgroundColor: Colors.grey[200],
      );
    }
}