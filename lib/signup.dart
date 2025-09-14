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

  @override
  void initState() {
    authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) async {
        if (redirecting) return;
        final session = data.session;
        if (session != null) {
          if (pendName != null) {
            try {
              await supabase.from('profiles').insert({
                'user_id': session.user.id,
                'username': pendName,
              });
              pendName = null; 
            } catch (error) {
     
              if (mounted) {
                context.showSnackBar(
                  'Error saving username: ${error.toString()}',
                  isError: true,
                );
              }
       
              return;
            }
          }

          redirecting = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
      },
      onError: (error) {
        if (error is AuthException) {
          context.showSnackBar(error.message, isError: true);
        } else {
          context.showSnackBar('Unexpected Error Occurred');
        }
      },
    );
    super.initState();
  }

  Future<void> signin() async {
    final enteredName = nameController.text.trim();
    if (enteredName.isEmpty) {
      context.showSnackBar('Please enter a username', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
   
      final response = await supabase
          .from('profiles') 
          .select('username')
          .eq('username', enteredName);

      final usernames = response as List;
      if (usernames.isNotEmpty) {
        context.showSnackBar('Username Taken', isError: true);
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Send magic link
      await supabase.auth.signInWithOtp(
        email: emailController.text.trim(),
        emailRedirectTo: kIsWeb
            ? null
            : 'io.supabase.flutterquickstart://login-callback/',
      );

  

      if (mounted) {
        context.showSnackBar('Check your email for a login link');
        emailController.clear();
        nameController.clear();
     
        pendName = enteredName;
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar(
          'Unexpected Error Occurred: ${error.toString()}',
          isError: true,
        );
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
