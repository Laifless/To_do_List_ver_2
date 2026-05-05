import 'package:flutter/services.dart';

/// Centralizza i feedback aptici e sonori per dare un'identità coerente.
///
/// Idea: ogni "evento" del sistema ha la sua firma sensoriale, come in un
/// videogioco. Il giocatore impara a riconoscerle.
class SystemFeedback {
  SystemFeedback._();

  /// Tap leggero su elemento UI.
  static void tap() {
    HapticFeedback.selectionClick();
  }

  /// Conferma di un'azione (es. log set, accept quest).
  static void confirm() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Quest completata — feedback più marcato.
  static Future<void> questComplete() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.mediumImpact();
  }

  /// Level up — il momento iconico. Doppio buzz.
  static Future<void> levelUp() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }

  /// Errore o azione distruttiva.
  static void warning() {
    HapticFeedback.vibrate();
  }

  /// Timer recupero scaduto — ritmico.
  static Future<void> timerEnd() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
  }

  /// Apertura di una finestra di sistema (modal, dialog di livello).
  static void systemWindow() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.alert);
  }
}