import 'audio_output_route.dart';

/// Outcome of a [setRoute] request on the native platform.
/// 原生平台上 [setRoute] 请求的执行结果。
class RouteResult {
  /// Creates a [RouteResult].
  /// 创建 [RouteResult]。
  const RouteResult({
    required this.requested,
    required this.applied,
    required this.available,
  });

  /// Route the caller requested.
  /// 调用方请求的路由。
  final AudioOutputRoute requested;

  /// Route actually in effect after the platform applied the change.
  /// 平台应用变更后实际生效的路由。
  final AudioOutputRoute applied;

  /// Whether [requested] was fully applied (`applied == requested`).
  /// [requested] 是否已完全生效（`applied == requested`）。
  final bool available;

  @override
  bool operator ==(Object other) {
    return other is RouteResult &&
        other.requested == requested &&
        other.applied == applied &&
        other.available == available;
  }

  @override
  int get hashCode => Object.hash(requested, applied, available);

  @override
  String toString() =>
      'RouteResult(requested: $requested, applied: $applied, available: $available)';
}
