import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RewardReaderWrapper extends StatefulWidget {
  final int rewardPoints;
  final String taskKey;
    final Widget child;

  const RewardReaderWrapper({
    required this.rewardPoints,
    required this.taskKey,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  State<RewardReaderWrapper> createState() => _RewardReaderWrapperState();
}

class _RewardReaderWrapperState extends State<RewardReaderWrapper> {
  late DateTime startTime;
  late Duration totalTimeSpent;
  bool rewardGiven = false;

  @override
  void initState() {
    super.initState();
     totalTimeSpent = Duration.zero;
    _resumeTimer();
  }

  void _resumeTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? previousTimeMillis = prefs.getInt('${widget.taskKey}_time');
    String? previousStartTimeString = prefs.getString('${widget.taskKey}_start_time');

    startTime = previousStartTimeString != null
        ? DateTime.parse(previousStartTimeString)
        : DateTime.now();

    if (previousTimeMillis != null) {
      totalTimeSpent += Duration(milliseconds: previousTimeMillis);
    }

    _startMonitoring();
  }

  void _startMonitoring() {
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        _checkIfEligible();
      }
    });
  }

  void _checkIfEligible() async {
    Duration currentSession = DateTime.now().difference(startTime);
    Duration total = totalTimeSpent + currentSession;

    if (total.inMinutes >= 5 && !rewardGiven) {
      rewardGiven = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int currentCoins = prefs.getInt('coinBalance') ?? 0;
      prefs.setInt('coinBalance', currentCoins + widget.rewardPoints);
      prefs.setBool('${widget.taskKey}_completed', true);
      prefs.remove('${widget.taskKey}_time');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+${widget.rewardPoints} coins earned!')),
        );
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('${widget.taskKey}_time', total.inMilliseconds);
      if (!rewardGiven) _startMonitoring();
    }
  }

  @override
  void dispose() {
    Duration session = DateTime.now().difference(startTime);
    totalTimeSpent += session;
    _saveProgress();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('${widget.taskKey}_time', totalTimeSpent.inMilliseconds);
    prefs.setString('${widget.taskKey}_start_time', startTime.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
