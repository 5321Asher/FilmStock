// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:filmstock/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'current_user.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  bool edit = false;

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return edit
        ? Edit(
            onSwitch: () {
              setState(() => edit = false);
              refresh(); // <-- Force rebuild after edit
            },
            onRefresh: refresh, // <-- Pass refresh callback
          )
        : View(onSwitch: () => setState(() => edit = true));
  }
}

class Edit extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onRefresh; // <-- Add this
  const Edit({required this.onSwitch, required this.onRefresh, super.key});

  @override
  State<Edit> createState() => EditState();
}

class EditState extends State<Edit> {
  late final TextEditingController nameController = TextEditingController(
    text: username ?? '',
  );
  late final TextEditingController emailController = TextEditingController(
    text: userEmail ?? '',
  );
  late final TextEditingController bioController = TextEditingController(
    text: userBio ?? '',
  );

  String? enteredName;
  String? enteredEmail;
  String? enteredBio;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> overwrite() async {
    enteredName = nameController.text.trim();
    enteredEmail = emailController.text.trim();
    enteredBio = bioController.text.trim();

    final nameResponse = await supabase
        .from('profiles')
        .select('username, user_id')
        .eq('username', enteredName!);
    final usernames = nameResponse as List;
    final takenByOtherName = usernames.any((row) => row['user_id'] != userId);

    final emailResponse = await supabase
        .from('profiles')
        .select('email, user_id')
        .eq('email', enteredEmail!);
    final emails = emailResponse as List;
    final takenByOtherEmail = emails.any((row) => row['user_id'] != userId);

    if (enteredName!.isEmpty || enteredEmail!.isEmpty) {
      context.showSnackBar('Please Fill in All Fields');
      return;
    } else if (takenByOtherName) {
      context.showSnackBar('Username Taken');
      return;
    } else if (takenByOtherEmail) {
      context.showSnackBar('Email Taken');
      return;
    } else {
      if (userId != null) {
        try {
          await supabase
              .from('profiles')
              .update({
                'username': enteredName,
                'email': enteredEmail,
                'bio': enteredBio,
              })
              .eq('user_id', userId!);

          await Currentuser.instance.loadUserInfo();

          context.showSnackBar('Profile Updated');
          widget.onRefresh(); // <-- Force parent to rebuild
          widget.onSwitch();
        } catch (e) {
          context.showSnackBar('Update failed: $e');
        }
      } else {
        print('user id missing');
        context.showSnackBar('User ID missing');
      }
    }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: Screen.height(context) * .2),
            EditItem(title: 'Username', controller: nameController),
            EditItem(title: 'Email', controller: emailController),
            EditItem(title: 'Bio', controller: bioController),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Screen.width(context) * .04,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Screen.width(context) * .03,
                    ),
                    child: InkWell(
                      onTap: widget.onSwitch,
                      child: Container(
                        height: Screen.height(context) * .1,
                        width: Screen.width(context) * .4,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: primary),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Discard Changes',
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                            Icon(
                              Icons.cancel_outlined,
                              color: primary,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Screen.width(context) * .03,
                    ),
                    child: InkWell(
                      onTap: () {
                        overwrite();
                      },
                      child: Container(
                        height: Screen.height(context) * .1,
                        width: Screen.width(context) * .4,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: primary),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Apply Changes',
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                            Icon(Icons.check, color: primary, size: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditItem extends StatelessWidget {
  final String? title;
  final TextEditingController controller;

  const EditItem({required this.title, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Screen.width(context) * .05,
        vertical: Screen.height(context) * .02,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              '$title:',
              style: TextStyle(color: textColor, fontSize: 20),
            ),
          ),

          SizedBox(
            width: Screen.width(context) * .89,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                label: Text(title ?? ''),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class View extends StatefulWidget {
  final VoidCallback onSwitch;
  const View({required this.onSwitch, super.key});

  @override
  State<View> createState() => ViewState();
}

class ViewState extends State<View> {
  late final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text('View', style: TextStyle(color: textColor)),
        actions: [
          IconButton(
            onPressed: widget.onSwitch,
            icon: Icon(Icons.edit, color: primary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: Screen.height(context) * .05),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Screen.width(context) * .03,
              ),
              child: Row(
                children: [
                  StatItem(title: 'Movies Watched', stat: 3),
                  StatItem(title: 'Movie Streak', stat: 6),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Screen.width(context) * .03,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Screen.width(context) * .03),
                    child: Container(
                      height: Screen.height(context) * .12,
                      width: Screen.width(context) * .4,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: primary),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Screen.width(context) * .03),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Memer Since',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),

                            SizedBox(height: Screen.height(context) * .01),

                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                DateFormat.yMMMd().format(
                                  userCreatedAt ?? DateTime.now(),
                                ),
                                style: TextStyle(color: primary, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  StatItem(title: 'Average Rating', stat: 7.7),
                ],
              ),
            ),
            SizedBox(height: Screen.height(context) * .05),
            ProfileItem(
              label: 'Name',
              item: username ?? 'Username',
              maxLines: 2,
            ),
            ProfileItem(
              label: 'Email',
              item: userEmail ?? 'Email',
              maxLines: 2,
            ),
            ProfileItem(label: 'Bio', item: userBio ?? 'bio', maxLines: 6),
          ],
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String label;
  final String item;
  final int maxLines;

  const ProfileItem({
    required this.label,
    required this.item,
    required this.maxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return SizedBox(
      width: Screen.width(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Screen.width(context) * .05),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$label:',
                style: TextStyle(color: textColor, fontSize: 25),
              ),
            ),
            SizedBox(width: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item,
                style: TextStyle(color: primary, fontSize: 25),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: Screen.height(context) * .05),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String title;
  final double stat;

  const StatItem({required this.title, required this.stat, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return Padding(
      padding: EdgeInsets.all(Screen.width(context) * .03),
      child: Container(
        height: Screen.height(context) * .12,
        width: Screen.width(context) * .4,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: primary),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(Screen.width(context) * .03),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  title,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),

              SizedBox(height: Screen.height(context) * .01),

              Align(
                alignment: Alignment.center,
                child: Text(
                  stat % 1 == 0 ? stat.toInt().toString() : stat.toString(),
                  style: TextStyle(color: primary, fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
