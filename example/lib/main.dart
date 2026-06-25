import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xue_hua_speaker_earpiece_toggle/xue_hua_speaker_earpiece_toggle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = XueHuaSpeakerEarpieceToggle();

  // Current audio route loaded from the native platform.
  // 从原生平台加载的当前音频路由。
  AudioOutputRoute? _currentRoute;

  // Whether a route switch request is in progress.
  // 路由切换请求是否正在进行中。
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  /// Loads the current route from the plugin and updates the UI.
  /// 从插件加载当前路由并更新界面。
  Future<void> _loadRoute() async {
    setState(() => _isLoading = true);

    try {
      final route = await _plugin.getRoute();
      if (!mounted) return;
      setState(() {
        _currentRoute = route;
        _isLoading = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(error.message ?? 'Failed to load route.');
    }
  }

  /// Switches to the selected route and refreshes the UI.
  /// 切换到所选路由并刷新界面。
  Future<void> _selectRoute(AudioOutputRoute route) async {
    if (_currentRoute == route || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _plugin.setRoute(route);
      if (!mounted) return;
      setState(() {
        _currentRoute = route;
        _isLoading = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(error.message ?? 'Failed to switch route.');
    }
  }

  /// Shows a transient error message at the bottom of the screen.
  /// 在屏幕底部显示临时错误提示。
  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _routeLabel(AudioOutputRoute route) {
    switch (route) {
      case AudioOutputRoute.speaker:
        return 'Speaker / 扬声器';
      case AudioOutputRoute.earpiece:
        return 'Earpiece / 听筒';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Speaker / Earpiece Toggle')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Current Route / 当前路由',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Text(
                    _currentRoute == null
                        ? 'Unknown / 未知'
                        : _routeLabel(_currentRoute!),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                const SizedBox(height: 32),
                if (_currentRoute != null)
                  SegmentedButton<AudioOutputRoute>(
                    segments: const [
                      ButtonSegment(
                        value: AudioOutputRoute.speaker,
                        label: Text('Speaker'),
                        icon: Icon(Icons.volume_up),
                      ),
                      ButtonSegment(
                        value: AudioOutputRoute.earpiece,
                        label: Text('Earpiece'),
                        icon: Icon(Icons.phone_in_talk),
                      ),
                    ],
                    selected: {_currentRoute!},
                    onSelectionChanged: _isLoading
                        ? null
                        : (selection) => _selectRoute(selection.first),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Tip: Test on a physical device during a voice call or while playing audio.\n'
                  '提示：请在真机上进行语音通话或播放音频时测试切换效果。',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _loadRoute,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh / 刷新'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
