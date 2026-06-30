import 'dart:async';

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

  AudioOutputRoute? _currentRoute;
  bool? _lastRouteAvailable;
  bool _isLoading = true;
  StreamSubscription<AudioOutputRoute>? _routeSubscription;

  @override
  void initState() {
    super.initState();
    _routeSubscription = _plugin.onRouteChanged.listen(
      (route) {
        if (!mounted) return;
        setState(() {
          _currentRoute = route;
          _isLoading = false;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        final message = error is PlatformException
            ? error.message ?? 'Failed to watch route.'
            : 'Failed to watch route.';
        _showError(message);
      },
    );
  }

  @override
  void dispose() {
    _routeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoading = true);

    try {
      final route = await _plugin.getRoute();
      if (!mounted) return;
      setState(() {
        _currentRoute = route;
        _lastRouteAvailable = null;
        _isLoading = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(error.message ?? 'Failed to load route.');
    }
  }

  Future<void> _selectRoute(AudioOutputRoute route) async {
    if (_currentRoute == route || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _plugin.setRoute(route);
      if (!mounted) return;

      setState(() {
        _lastRouteAvailable = result.available;
        _isLoading = false;
      });

      if (!result.available) {
        _showError(
          'Requested ${_routeLabel(result.requested)}, but '
          '${_routeLabel(result.applied)} is active.',
        );
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(error.message ?? 'Failed to switch route.');
    }
  }

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
      case AudioOutputRoute.external:
        return 'External / 外接设备';
      case AudioOutputRoute.unknown:
        return 'Unknown / 未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSwitch =
        _currentRoute == AudioOutputRoute.speaker ||
        _currentRoute == AudioOutputRoute.earpiece;

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
                if (_lastRouteAvailable == false) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last switch was not fully applied / 上次切换未完全生效',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                if (canSwitch)
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
                  )
                else if (_currentRoute != null)
                  Text(
                    'Route is read-only in this state / 当前路由不可切换',
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Tip: Route updates automatically via onRouteChanged.\n'
                  '提示：路由会通过 onRouteChanged 自动更新。',
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
