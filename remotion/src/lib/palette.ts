/**
 * Pulse brand palette — sourced from the product design system
 * (web/landing.html CSS variables + FlutterFlowTheme).
 */
export const PALETTE = {
  ink: '#07070B',
  ink2: '#0B0B12',
  ink3: '#050508',
  purple: '#9900FF', // Pulse Purple (primary)
  violet: '#7C3AED', // Violet 600
  purpleLight: '#C77DFF', // Lavender highlight
  blue: '#3B82F6', // Aurora secondary
  green: '#00D68F', // The "alive signal" accent
  white: '#FFFFFF',
} as const;

/** hex + alpha (0-1) -> rgba() string */
export const rgba = (hex: string, alpha: number): string => {
  const h = hex.replace('#', '');
  const r = parseInt(h.substring(0, 2), 16);
  const g = parseInt(h.substring(2, 4), 16);
  const b = parseInt(h.substring(4, 6), 16);
  return `rgba(${r},${g},${b},${alpha})`;
};
