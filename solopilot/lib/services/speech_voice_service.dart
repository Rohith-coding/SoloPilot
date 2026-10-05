import 'package:speech_to_text/speech_to_text.dart';
import 'voice_service.dart';

/// B7 — Voice dictation using speech_to_text.
///
/// The recognized text feeds into the same extract() pipeline.
/// Includes basic processing of spoken numbers ("five thousand" → 5000)
/// and weekday names ("Friday" → next Friday's date in dd/MM/yyyy).
///
/// Handles failures gracefully — if the mic isn't available, init() returns false.
class SpeechVoiceService implements VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  @override
  Future<bool> init() async {
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Voice error: ${error.errorMsg}'),
      );
      return _isInitialized;
    } catch (e) {
      print('Voice init error: $e');
      return false;
    }
  }

  @override
  Future<void> start(void Function(String text) onText) async {
    if (!_isInitialized) {
      final ready = await init();
      if (!ready) return; // mic not available — fail silently
    }

    try {
      await _speech.listen(
        onResult: (result) {
          // Process spoken text to convert numbers and weekdays
          final processed = _processSpokenText(result.recognizedWords);
          onText(processed);
        },
        localeId: 'en_IN', // Indian English for ₹ context
        listenMode: ListenMode.dictation,
      );
    } catch (e) {
      print('Voice start error: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (e) {
      print('Voice stop error: $e');
    }
  }

  /// Convert spoken numbers and weekday names to values.
  ///
  /// Examples:
  ///   "five thousand"  → "5000"
  ///   "ten lakh"       → "1000000"
  ///   "two hundred"    → "200"
  ///   "Friday"         → "dd/MM/yyyy" of next Friday
  ///   "5000 rupees"    → "₹5000"
  String _processSpokenText(String text) {
    var result = text;

    // Map of spoken number words to digits
    final numberWords = {
      'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4',
      'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9',
      'ten': '10', 'eleven': '11', 'twelve': '12', 'thirteen': '13',
      'fourteen': '14', 'fifteen': '15', 'sixteen': '16', 'seventeen': '17',
      'eighteen': '18', 'nineteen': '19', 'twenty': '20', 'thirty': '30',
      'forty': '40', 'fifty': '50', 'sixty': '60', 'seventy': '70',
      'eighty': '80', 'ninety': '90',
    };

    // Convert "<number word> thousand/lakh/hundred"
    result = _replaceMultiplier(result, 'thousand', 1000, numberWords);
    result = _replaceMultiplier(result, 'lakh', 100000, numberWords);
    result = _replaceMultiplier(result, 'hundred', 100, numberWords);

    // Convert weekday names to next occurrence (dd/MM/yyyy)
    final weekdays = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    for (final entry in weekdays.entries) {
      if (result.toLowerCase().contains(entry.key)) {
        final nextDate = _nextWeekday(entry.value);
        final dateStr =
            '${nextDate.day.toString().padLeft(2, '0')}/'
            '${nextDate.month.toString().padLeft(2, '0')}/'
            '${nextDate.year}';
        result = result.replaceAll(
          RegExp(entry.key, caseSensitive: false),
          dateStr,
        );
      }
    }

    // Add ₹ prefix to numbers followed by "rupees" / "rs" / "inr"
    result = result.replaceAllMapped(
      RegExp(r'(\d{3,})\s*(?:rupees?|rs\.?|inr)', caseSensitive: false),
      (m) => '₹${m.group(1)}',
    );

    return result;
  }

  /// Replace patterns like "five thousand" with "5000".
  String _replaceMultiplier(
    String text,
    String multiplierWord,
    int multiplierValue,
    Map<String, String> numberWords,
  ) {
    return text.replaceAllMapped(
      RegExp(r'\b(\w+)\s+' + multiplierWord + r'\b', caseSensitive: false),
      (m) {
        final word = m.group(1)!.toLowerCase();
        final numStr = numberWords[word] ?? word;
        final value = int.tryParse(numStr);
        return value != null ? '${value * multiplierValue}' : m.group(0)!;
      },
    );
  }

  /// Find the next occurrence of a weekday (e.g. next Friday).
  DateTime _nextWeekday(int weekday) {
    final now = DateTime.now();
    var daysAhead = weekday - now.weekday;
    if (daysAhead <= 0) daysAhead += 7; // roll to next week
    return now.add(Duration(days: daysAhead));
  }
}
