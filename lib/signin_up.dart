// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:filmstock/main.dart';
import 'package:filmstock/current_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class SigninUp extends StatefulWidget {


  const SigninUp({super.key});

  @override
  State<SigninUp> createState() => SigninUpState();
}

class SigninUpState extends State<SigninUp> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginPage(onSwitch: () => setState(() => showLogin = false))
        : SignupPage(onSwitch: () => setState(() => showLogin = true));
  }
}

// Refactor LoginPageState and SignupPageState to stateless widgets that accept onSwitch callback
class LoginPage extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginPage({required this.onSwitch, super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool redirecting = false;
  late final TextEditingController emailController = TextEditingController();
  late final StreamSubscription<AuthState> authStateSubscription;

  Future<void> signin() async {
    final enteredEmail = emailController.text.trim();
    if (enteredEmail.isEmpty) {
      context.showSnackBar('Please Enter an email', isError: false);
    }

    try {
      final emailResponse = await supabase
          .from('profiles')
          .select('*')
          .eq('email', enteredEmail);
      final emails = emailResponse as List;
      if (emails.isEmpty) {
        context.showSnackBar(
          'Email is not registered please sign up',
          isError: true,
        );
        setState(() {
          isLoading = false;
        });
        return;
      }
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

        emailController.clear();
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

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return FutureBuilder(
                  future: Currentuser.instance.loadUserInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return MyHomePage();
                    }
                    return Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              },
            ),
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
    authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Column(
        children: [
          SizedBox(height: Screen.height(context) * .03),
          Row(
            children: [
              Container(
                height: Screen.height(context) * .1,
                width: Screen.width(context) * .5,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: primary, width: 5),
                    right: BorderSide(color: primary, width: .2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(fontSize: 24, color: textColor),
                  ),
                ),
              ),
              InkWell(
                onTap: widget.onSwitch,
                child: Container(
                  height: Screen.height(context) * .1,
                  width: Screen.width(context) * .5,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: primary, width: .2),

                      left: BorderSide(color: primary, width: .2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 24, color: textColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: Screen.height(context) * .3,
              left: Screen.width(context) * .1,
              right: Screen.width(context) * .1,
              bottom: Screen.height(context) * .02,
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

class SignupPage extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignupPage({required this.onSwitch, super.key});

  @override
  State<SignupPage> createState() => SignupPageState();
}
class SignupPageState extends State<SignupPage> {
  bool isLoading = false;
  bool redirecting = false;
  String? pendName;
  String? pendEmail;
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
          if (pendName != null && pendEmail != null) {
            try {
              await supabase.from('profiles').insert({
                'user_id': session.user.id,
                'username': pendName,
                'email': pendEmail,
              });
              pendName = null;
              pendEmail = null;
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
            MaterialPageRoute(
              builder: (context) {
                return FutureBuilder(
                  future: Currentuser.instance.loadUserInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return MyHomePage();
                    }
                    return Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              },
            ),
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
    final enteredEmail = emailController.text.trim();
    if (enteredName.isEmpty) {
      context.showSnackBar('Please enter a username', isError: true);
      return;
    }
    if (enteredEmail.isEmpty) {
      context.showSnackBar('Please enter an email', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final nameResponse = await supabase
          .from('profiles')
          .select('username')
          .eq('username', enteredName);

      final usernames = nameResponse as List;
      if (usernames.isNotEmpty) {
        context.showSnackBar('Username Taken', isError: true);
        setState(() {
          isLoading = false;
        });
        return;
      }

      final emailResponse = await supabase
          .from('profiles')
          .select('email')
          .eq('email', enteredEmail);

      final emails = emailResponse as List;
      if (emails.isNotEmpty) {
        context.showSnackBar('Email Taken', isError: true);
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
        pendEmail = enteredEmail;
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
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: Screen.height(context) * .03),
            Row(
              children: [
                InkWell(
                  onTap: widget.onSwitch,
                  child: Container(
                    height: Screen.height(context) * .1,
                    width: Screen.width(context) * .5,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: primary, width: .2),
                        right: BorderSide(color: primary, width: .2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Log In',
                        style: TextStyle(fontSize: 24, color: textColor),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: Screen.height(context) * .1,
                  width: Screen.width(context) * .5,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: primary, width: 5),
                      left: BorderSide(color: primary, width: .2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 24, color: textColor),
                    ),
                  ),
                ),
              ],
            ),
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
                      child: Text(
                        isLoading ? 'Sending....' : 'Send Magic Link',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
