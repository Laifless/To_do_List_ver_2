import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color black      = Color(0xFF04040F);
  static const Color surface    = Color(0xFF08081A);
  static const Color surfaceAlt = Color(0xFF06060F);

  static const Color blue     = Color(0xFF00EAFF);
  static const Color blueDark = Color(0xFF0055AA);
  static const Color blueDim  = Color(0xFF003366);

  static const Color gold    = Color(0xFFFFD700);
  static const Color goldDim = Color(0xFF665500);

  static const Color purple    = Color(0xFF9D00FF);
  static const Color purpleDim = Color(0xFF3D0066);

  static const Color green    = Color(0xFF00FFC8);
  static const Color greenDim = Color(0xFF00664D);

  static const Color red = Color(0xFFFF3A5C);

  // Rank E → S (invariati)
  static const Color rankE = Color(0xFF8B8B8B);
  static const Color rankD = Color(0xFF7BC57B);
  static const Color rankC = Color(0xFF4FC3F7);
  static const Color rankB = Color(0xFF9D7BFF);
  static const Color rankA = Color(0xFFFFB74D);
  static const Color rankS = Color(0xFFFF3A5C);

  // Rank SS, SS+, SSS — scala verso il bianco puro per dare senso
  // di "oltre il limite" rispetto all'S rosso.
  static const Color rankSS     = Color(0xFFFF80AB); // rosa brillante
  static const Color rankSSPlus = Color(0xFFFFD6E0); // quasi bianco caldo
  static const Color rankSSS    = Color(0xFFFFFFFF); // bianco puro — massimo

  static Color alpha(Color c, double a) => c.withValues(alpha: a);
}