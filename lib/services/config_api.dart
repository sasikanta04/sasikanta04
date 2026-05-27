class ConfigApi {
  static const String _base = '/api';

  // ── Shared masters ──────────────────────────────────────────────────────────
  static const String getMetalTypes    = '$_base/get-metal-types';
  static const String getShellNumbers  = '$_base/get-shell-numbers';

  // Shell Type + Shell No combined master (parent-child).
  // Kept separate — do NOT call this from the dashboard shared-master batch.
  static const String getShellNoByShellType = '$_base/shellno-by-shelltype';

  // ── SA QCI ──────────────────────────────────────────────────────────────────
  static const String getSaQciAllParams        = '$_base/get-sa-qci-all-params';
  static const String submitSaQciForm          = '$_base/submit-sa-qci-form';
  static const String getSaFinalSavedFormList  = '$_base/sa-final-saved-forms';
}
