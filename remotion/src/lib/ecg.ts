/**
 * Electrocardiogram synthesis — the signature Pulse motif.
 * One full heartbeat cycle, t in [0, 1):
 *   P wave (atrial depolarization), QRS complex (ventricular
 *   depolarization — the sharp spike), T wave (repolarization).
 */
export const gauss = (x: number, mu: number, sigma: number): number =>
  Math.exp(-((x - mu) * (x - mu)) / (2 * sigma * sigma));

export const ecgValue = (t: number): number =>
  0.12 * gauss(t, 0.16, 0.032) - // P
  0.14 * gauss(t, 0.285, 0.009) + // Q
  1.0 * gauss(t, 0.315, 0.012) - // R  (the spike)
  0.26 * gauss(t, 0.35, 0.011) + // S
  0.18 * gauss(t, 0.55, 0.05); // T

export const frac = (x: number): number => x - Math.floor(x);

/** Sample a full ECG path across the screen. Loop-safe by construction. */
export const buildEcgPath = (opts: {
  width: number;
  yCenter: number;
  amplitude: number;
  beatWidth: number;
  offset: number;
  step?: number;
}): string => {
  const { width, yCenter, amplitude, beatWidth, offset } = opts;
  const step = opts.step ?? 4;
  const margin = beatWidth * 2;
  let d = '';
  for (let x = -margin; x <= width + margin; x += step) {
    const p = (x + offset) / beatWidth;
    const v = ecgValue(frac(p));
    const py = yCenter - v * amplitude;
    d += `${x <= -margin + step / 2 ? 'M' : 'L'}${x.toFixed(1)} ${py.toFixed(2)} `;
  }
  return d;
};
