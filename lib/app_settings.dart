import 'package:filmstock/main.dart';
import 'package:flutter/material.dart';

class MyAppSettings extends StatelessWidget {
  const MyAppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: Text('App Settings')),
      body: ListView(
        children: [
          SettingHeader(title: 'Appearance'),
          Material(
            color: scaffoldBg,
            child: SizedBox(
              height: Screen.height(context) * .06,
              child: Padding(
                padding: EdgeInsetsGeometry.only(
                  left: Screen.width(context) * .03,
                ),
                child: ListTile(
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                  trailing: Switch(
                    value: themeNotifier.value == ThemeMode.dark,
                    onChanged: (bool value) {
                      themeNotifier.value = value
                          ? ThemeMode.dark
                          : ThemeMode.light;
                    },
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: scaffoldBg,
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text('Pick A Color Theme'),
                  actions: <Widget>[ColorPicker()],
                ),
              ),
              child: SizedBox(
                height: Screen.height(context) * .06,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: Screen.width(context) * .065,
                        top: Screen.height(context) * .015,
                      ),
                      child: Text(
                        'Color Theme',
                        style: TextStyle(fontSize: 20, color: textColor),
                      ),
                    ),
                    Positioned(
                      right: Screen.width(context) * .085,
                      top: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.arrow_drop_down_circle_sharp,
                        size: 35,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SettingHeader(title: 'Notifications'),
          Padding(
            padding: EdgeInsetsGeometry.only(left: Screen.width(context) * .03),
            child: ExpansionTile(
              title: Text(
                'Notifications',
                style: TextStyle(fontSize: 20, color: textColor),
              ),
              trailing: Switch(
                value: true,
                onChanged: (bool value) {
                  value = !value;
                },
              ),
              children: [
                ExpandedListTileSwitch(title: 'Release Dates'),
                ExpandedListTileSwitch(title: 'Streak'),
                ExpandedListTileSwitch(title: 'Announcements'),
              ],
            ),
          ),

          SettingHeader(title: 'Parental Controls'),
          Material(
            color: scaffoldBg,
            child: Padding(
              padding: EdgeInsetsGeometry.only(
                left: Screen.width(context) * .03,
              ),
              child: SizedBox(
                height: Screen.height(context) * .06,
                child: ListTile(
                  title: Text(
                    'Show NSFW Content',
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedListTileSwitch extends StatelessWidget {
  final String title;

  const ExpandedListTileSwitch({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;

    return ListTile(
      tileColor: scaffoldBg,
      leading: Container(
        width: Screen.width(context) * .05,
        height: Screen.height(context) * .002,
        color: theme.dividerColor,
      ),
      trailing: Switch(value: true, onChanged: (bool value) {}),
      contentPadding: EdgeInsets.symmetric(
        horizontal: Screen.width(context) * .06,
        vertical: 0,
      ),
      title: Text(title, style: TextStyle(color: textColor)),
    );
  }
}

class ColorPickerTile extends StatelessWidget {
  final String colorName;
  final Color color;

  const ColorPickerTile({
    super.key,
    required this.colorName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;

    return GestureDetector(
      onTap: () => accentColorNotifier.value = color,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 18,
            child: accentColorNotifier.value == color
                ? Icon(Icons.check, color: Colors.white)
                : null,
          ),
          SizedBox(width: Screen.width(context) * .05),
          Text(colorName, style: TextStyle(fontSize: 20, color: textColor)),
        ],
      ),
    );
  }
}

class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final colorNames = {
      Colors.blue: "Blue",
      Colors.red: "Red",
      Colors.green: "Green",
      Colors.orange: "Orange",
      Colors.purple: 'Purple',
      Colors.teal: "Teal",
      Colors.amber: "Amber",
      Colors.pink: "pink",
      Colors.cyan: "Cyan",
      Colors.indigo: "Indigo",
    };
    return Padding(
      padding: EdgeInsets.only(
        left: Screen.width(context) * .02,
        top: Screen.height(context) * .01,
        bottom: Screen.height(context) * .01,
      ),
      child: Wrap(
        runSpacing: Screen.height(context) * .015,
        children: [
          for (final color in colorNames.keys)
            ColorPickerTile(colorName: colorNames[color]!, color: color),
        ],
      ),
    );
  }
}

class SettingHeader extends StatelessWidget {
  final String title;

  const SettingHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: Screen.width(context) * .07,
              top: Screen.height(context) * .03,
            ),
            child: Text(
              title,
              style: TextStyle(fontSize: 40, color: textColor),
            ),
          ),
        ),
        Divider(
          height: Screen.height(context) * .03,
          thickness: Screen.height(context) * .003,
          indent: Screen.width(context) * .05,
          endIndent: Screen.width(context) * .05,
          color: theme.dividerColor,
        ),
      ],
    );
  }
}
