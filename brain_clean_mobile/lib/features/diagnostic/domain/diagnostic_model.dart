import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnostic_model.freezed.dart';
part 'diagnostic_model.g.dart';

@freezed
class DiagnosticMetrics with _$DiagnosticMetrics {
  const factory DiagnosticMetrics({
    @Default(5) int sleepQuality,
    @Default(5) int sustainedAttention,
    @Default(5) int fragmentation,
    @Default(5) int dopamineSeeking,
    @Default(5) int taskSwitching,
    @Default(5) int burnout,
  }) = _DiagnosticMetrics;

  factory DiagnosticMetrics.fromJson(Map<String, dynamic> json) =>
      _$DiagnosticMetricsFromJson(json);
}

extension DiagnosticMetricsX on DiagnosticMetrics {
  double get focusScorePercentage {
    // 1. حساب الـ rawScore بناءً على المعادلة السلوكية الصارمة
    double rawScore = ((sleepQuality + sustainedAttention) * 1.5) - 
                      ((fragmentation + dopamineSeeking + taskSwitching + burnout) * 0.8);
    
    // 2. النطاق العلمي المحدد: الحد الأدنى المطلق -29.0 والحد الأقصى 26.8 (الإجمالي 55.8)
    double normalizedPercentage = ((rawScore + 29.0) / 55.8) * 100.0;
    
    // 3. حصر النسبة بدقة (Clamping) بين 0% و 100% لمنع الأخطاء البرمجية
    return normalizedPercentage.clamp(0.0, 100.0);
  }
}