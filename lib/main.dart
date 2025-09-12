import 'package:filmstock/app_settings.dart';
import 'package:filmstock/help_and_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData buildTheme(Color primary, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color.fromARGB(255, 50, 50, 50)
        : Colors.white,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: brightness == Brightness.dark
          ? const Color.fromARGB(255, 50, 50, 50)
          : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        fontSize: 24,
      ),
      iconTheme: IconThemeData(
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
    ),
    textTheme: TextTheme(
      titleMedium: TextStyle(
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      bodyMedium: TextStyle(
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      bodySmall: TextStyle(
        color: brightness == Brightness.dark ? Colors.white70 : Colors.black87,
      ),
    ),
    dividerColor: primary, // Divider always matches primary color
    iconTheme: IconThemeData(color: primary),
    cardColor: brightness == Brightness.dark
        ? const Color.fromARGB(255, 60, 60, 60)
        : Colors.white,
  );
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<Color> accentColorNotifier = ValueNotifier(Colors.blue);

class Screen {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: accentColorNotifier,
      builder: (context, primary, _) {
        return ValueListenableBuilder(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildTheme(primary, Brightness.light),
              darkTheme: buildTheme(primary, Brightness.dark),
              themeMode: mode,
              home: MyHomePage(title: 'home page'),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;
    //final cardColor = theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Film Stock',
          style: TextStyle(
            color: theme.appBarTheme.titleTextStyle?.color ?? textColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: theme.appBarTheme.iconTheme?.color ?? textColor,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                  left: Screen.width(context) * .06,
                  top: Screen.height(context) * .05,
                ),
                decoration: BoxDecoration(color: scaffoldBg),
                child: Text(
                  'FilmStock',
                  style: TextStyle(fontSize: 40, color: textColor),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Container(
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(color: scaffoldBg),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: Screen.height(context) * .02),
                    Material(
                      color: scaffoldBg,
                      child: ListTile(
                        title: Text(
                          '<user>',
                          style: TextStyle(fontSize: 30, color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Icon(Icons.person, color: primary, size: 30),
                        onTap: () {},
                      ),
                    ),
                    Material(
                      color: scaffoldBg,
                      child: ExpansionTile(
                        title: Text(
                          'Discover',
                          style: TextStyle(fontSize: 25, color: textColor),
                        ),
                        leading: Icon(Icons.search, color: primary),
                        trailing: SizedBox.shrink(),
                        children: [
                          ExpandedListTile(
                            title: 'Movies & Shows',
                            onTap: () {},
                          ),
                          ExpandedListTile(title: 'Songs', onTap: () {}),
                        ],
                      ),
                    ),
                    Material(
                      color: scaffoldBg,
                      child: ExpansionTile(
                        title: Text(
                          'Lists',
                          style: TextStyle(fontSize: 25, color: textColor),
                        ),
                        leading: Icon(Icons.list, color: primary),
                        trailing: SizedBox.shrink(),
                        children: [
                          ExpandedListTile(
                            title: 'Movie & Show Lists',
                            onTap: () {},
                          ),
                          ExpandedListTile(title: 'Playlists', onTap: () {}),
                        ],
                      ),
                    ),
                    Material(
                      color: scaffoldBg,
                      child: ListTile(
                        title: Text(
                          'Friends',
                          style: TextStyle(fontSize: 25, color: textColor),
                        ),
                        leading: Icon(Icons.person_add, color: primary),
                        onTap: () {},
                      ),
                    ),
                    Material(
                      color: scaffoldBg,
                      child: ListTile(
                        title: Text(
                          'News',
                          style: TextStyle(fontSize: 25, color: textColor),
                        ),
                        leading: Icon(Icons.newspaper, color: primary),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                color: scaffoldBg,
                alignment: Alignment.topLeft,
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Divider(
                      height: 1,
                      thickness: Screen.height(context) * .003,
                      indent: Screen.width(context) * .04,
                      endIndent: Screen.width(context) * .25,
                      color: theme.dividerColor, // uses theme divider
                    ),
                    Material(
                      color: scaffoldBg,
                      child: ListTile(
                        title: Text(
                          'App Settings',
                          style: TextStyle(fontSize: 15, color: textColor),
                        ),
                        leading: Icon(Icons.settings, color: primary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyAppSettings(),
                            ),
                          );
                        },
                      ),
                    ),
                    Material(
                      color: scaffoldBg,
                      child: ListTile(
                        title: Text(
                          'Help & Feedback',
                          style: TextStyle(fontSize: 15, color: textColor),
                        ),
                        leading: Icon(Icons.help, color: primary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpAndFeedback(),
                            ),
                          );
                        },
                      ),
                    ),
                    Material(
                      color: scaffoldBg,
                      child: ListTile(
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.error,
                          ),
                        ),
                        leading: Icon(Icons.logout, color: colorScheme.error),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          border: Border.all(color: primary),
          borderRadius: BorderRadius.circular(15),
          color: primary,
        ),
        child: FloatingActionButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: primary, // primary color
          foregroundColor: textColor, // theme text color
          child: Icon(Icons.add, size: 30, color: textColor),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Text(
                'Welcome <user>',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    HomePageHeader(title: 'Discover New Movies', onTap: () {}),
                    Divider(
                      height: 0,
                      thickness: Screen.height(context) * .003,
                      indent: Screen.width(context) * .25,
                      endIndent: Screen.width(context) * .25,
                      color: theme.dividerColor,
                    ),
                    SizedBox(height: Screen.height(context) * .01),
                    HomePageGenreCard(
                      name: 'asher',
                      color: Colors.red,
                      onTap: () {},
                    ),
                    HomePageHeader(title: 'Friend Activity', onTap: () {}),
                    Divider(
                      height: 0,
                      thickness: Screen.height(context) * .003,
                      indent: Screen.width(context) * .25,
                      endIndent: Screen.width(context) * .25,
                      color: theme.dividerColor,
                    ),
                    SizedBox(height: Screen.height(context) * .01),
                    HomePageFriendCard(
                      username: 'user',
                      content: 'interstellar',
                      rating: 9,
                      comment: "great stuff",
                      onTap: () {},
                    ),
                    HomePageHeader(title: 'Your Recent Activity', onTap: () {}),
                    Divider(
                      height: 0,
                      thickness: Screen.height(context) * .003,
                      indent: Screen.width(context) * .25,
                      endIndent: Screen.width(context) * .25,
                      color: theme.dividerColor,
                    ),
                    SizedBox(height: Screen.height(context) * .01),

                    HomePageRecentActivity(
                      content: 'interstellar',
                      rating: 9.5,
                      comment: 'fantastic stuf',
                      onTap: () {},
                    ),
                    SizedBox(height: Screen.height(context) * .1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const HomePageHeader({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Screen.height(context) * .01),
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Positioned(
                  right: Screen.width(context) * .05,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageGenreCard extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback? onTap;

  const HomePageGenreCard({
    super.key,
    required this.name,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          width: Screen.width(context) * .35,
          height: Screen.height(context) * .25,
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePageFriendCard extends StatelessWidget {
  final String username;
  final String content;
  final double rating;
  final String comment;
  final VoidCallback? onTap;

  const HomePageFriendCard({
    super.key,
    required this.username,
    required this.content,
    required this.rating,
    required this.comment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primary),
          ),
          width: Screen.width(context) * .4,
          height: Screen.height(context) * .2,
          padding: EdgeInsets.all(8),

          child: Column(
            children: [
              Center(
                child: Text(
                  username,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 6),
              Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(right: 48),
                      child: Text(
                        content,
                        style: TextStyle(color: textColor, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Text(
                      '$rating/10',
                      style: TextStyle(color: textColor, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 6,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: primary,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  comment,
                  style: TextStyle(color: textColor, fontSize: 14),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePageRecentActivity extends StatelessWidget {
  final String content;
  final double rating;
  final String comment;
  final VoidCallback? onTap;

  const HomePageRecentActivity({
    super.key,
    required this.content,
    required this.rating,
    required this.comment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primary),
          ),
          width: Screen.width(context) * .4,
          height: Screen.height(context) * .15,
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Center(
                child: Text(
                  content,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(right: 48),
                  child: Text(
                    '$rating/10',
                    style: TextStyle(color: textColor, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Divider(
                height: 6,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: primary,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  comment,
                  style: TextStyle(color: textColor, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpandedListTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const ExpandedListTile({super.key, required this.title, required this.onTap});

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
      contentPadding: EdgeInsets.symmetric(
        horizontal: Screen.width(context) * .06,
        vertical: 0,
      ),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
