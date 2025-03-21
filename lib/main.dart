import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(TapCounterApp());
}

class TapCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TapCounterHomePage(),
    );
  }
}

class TapCounterHomePage extends StatefulWidget {
  @override
  _TapCounterHomePageState createState() => _TapCounterHomePageState();
}

class _TapCounterHomePageState extends State<TapCounterHomePage>
    with SingleTickerProviderStateMixin {
  int _tapCount = 0;
  late AnimationController _controller;
  late Animation<double> _animation;
  Color _backgroundColor = Colors.white;

  List<Achievement> _achievements = [
    Achievement(name: "Smol PP", threshold: 50),
    Achievement(name: "Still Smol PP", threshold: 100),
    Achievement(name: "Ok PP", threshold: 150),
    Achievement(name: "Big PP", threshold: 200),
    Achievement(name: "Masive PP", threshold: 1000),
    Achievement(name: "Masive Big PP", threshold: 1500),
  ];
//gg
  @override
  void initState() {
    super.initState();
    _loadTapCount();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementTapCount() {
    setState(() {
      _tapCount++;
      if (_tapCount % 10 == 0) {
        _changeBackgroundColor();
      }
      _checkAchievements();
      _saveTapCount();
      _controller.forward(from: 0);
    });
  }

  void _checkAchievements() {
    for (var achievement in _achievements) {
      if (_tapCount == achievement.threshold) {
        _showAchievementDialog(achievement.name);
        break;
      }
    }
  }

  void _changeBackgroundColor() {
    setState(() {
      _backgroundColor =
          Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    });
  }

  Future<void> _loadTapCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _tapCount = prefs.getInt('tapCount') ?? 0;
      });
    } catch (e) {
      print('Error loading tap count: $e');
    }
  }

  Future<void> _saveTapCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tapCount', _tapCount);
    } catch (e) {
      print('Error saving tap count: $e');
    }
  }

  void _showAchievementDialog(String achievementName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have $achievementName'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAchievementsScreen() {
    List<Achievement> completedAchievements = _achievements
        .where((achievement) => _tapCount >= achievement.threshold)
        .toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Achievements'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: completedAchievements.map((achievement) {
              return Row(
                children: [
                  Image.asset(
                    'assets/eggplant.png',
                    width: 24,
                    height: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${achievement.name}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_tapCount',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                _incrementTapCount();
              },
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value,
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/eggplant.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Opacity(
              opacity: 0.0, // Set opacity to 0 to make the button invisible
              child: ElevatedButton(
                onPressed: _showAchievementsScreen,
                child: Text('View Achievements'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Achievement {
  final String name;
  final int threshold;

  Achievement({required this.name, required this.threshold});
}
