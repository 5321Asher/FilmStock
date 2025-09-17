import 'package:filmstock/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    return edit
        ? Edit(onSwitch: () => setState(() => edit = true))
        : View(onSwitch: () => setState(() => edit = false));
  }
}

class Edit extends StatefulWidget {
  final VoidCallback onSwitch;
  const Edit({required this.onSwitch, super.key});

  @override
  State<Edit> createState() => EditState();
}

class EditState extends State<Edit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('edit')));
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
            onPressed: () {},
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
                                DateFormat.yMMMd().format(userCreatedAt ?? DateTime.now()),
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
