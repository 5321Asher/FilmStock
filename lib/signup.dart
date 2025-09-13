// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:filmstock/main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => LoginPageState();
}

class LoginPageState extends State<SignupPage> {
  bool isLoading = false;
  bool redirecting = false;
  String? pendName;
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController nameController = TextEditingController();
  late final StreamSubscription<AuthState> authStateSubscription;

  Future<void> signin() async {
    try {
      setState(() {
        isLoading = true;
      });
      await supabase.auth.signInWithOtp(
        email: emailController.text.trim(),
        emailRedirectTo: kIsWeb
            ? null
            : 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        context.showSnackBar('check your email for a login link');

        pendName = nameController.text.trim();

        emailController.clear();
        nameController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected Error Occured', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) async {
        if (redirecting) return;
        final session = data.session;
        if (session != null) {
          redirecting = true;

          if (username == null) {
            if (pendName != null && pendName!.isNotEmpty) {
              await supabase.auth.updateUser(
                UserAttributes(data: {'display_name': pendName}),
              );
            }
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
      },
      onError: (error) {
        if (error is AuthException) {
          context.showSnackBar(error.message, isError: true);
        } else {
          context.showSnackBar('Unexpected Error Occured');
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    //final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(title: Text('Sign In')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: Screen.height(context) * .25,
              left: Screen.width(context) * .1,
              right: Screen.width(context) * .1,
              bottom: Screen.height(context) * .02,
            ),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                label: Text('Username'),
                hint: Text('E.g 5321Asher'),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Screen.width(context) * .1,
              vertical: Screen.height(context) * .02,
            ),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                label: Text('Email'),
                hint: Text('E.g johndoe@email.com'),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          SizedBox(height: Screen.height(context) * .05),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Screen.width(context) * .1,
            ),
            child: Material(
              color: scaffoldBg,
              child: InkWell(
                onTap: () {
                  if (!isLoading) signin();
                },
                child: Container(
                  width: Screen.width(context) * .8,
                  height: Screen.height(context) * .07,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primary,
                      width: Screen.width(context) * .01,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(isLoading ? 'Sending....' : 'Send Magic Link'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
