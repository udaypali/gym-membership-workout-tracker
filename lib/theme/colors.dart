import 'package:flutter/material.dart';

// 5-color palette following the guidelines:
// - Primary: purple
// - Accent: pink
// - Neutrals: two dark surfaces + light foreground
const kPrimary = Color(0xFF8B5CF6); // purple
const kAccentPink = Color(0xFFEC4899); // pink
const kBg = Color(0xFF0F172A); // slate-900
const kSurface = Color(0xFF1F2937); // slate-800
const kText = Color(0xFFF9FAFB); // near-white

const kRadiusLg = 16.0;

const kBgGradient = LinearGradient(
  colors: [Color(0xFF1E2230), kBg],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const kPurplePinkGradient = LinearGradient(
  colors: [kPrimary, kAccentPink],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
