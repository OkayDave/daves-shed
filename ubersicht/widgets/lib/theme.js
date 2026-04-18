export const theme = {
  colours: {
    text: '#ffd98e',
    muted: 'rgba(255, 217, 142, 0.72)',
    error: '#ffb7a8',

    panel: 'rgba(28, 24, 20, 0.88)',
    panelHighlight: 'rgba(255, 255, 255, 0.03)',
    panelShadow: 'rgba(0, 0, 0, 0.10)',

    border: 'rgba(255, 214, 153, 0.38)',
    innerBorder: 'rgba(255, 217, 142, 0.08)',

    glow: 'rgba(255, 190, 90, 0.10)',
    shadow: 'rgba(0, 0, 0, 0.38)',

    teal: '#5eead4',
    crimson: '#dc2626',
    amber: '#ffd98e',
  },

  font: {
    family: '"Rec Mono Casual", Menlo, Monaco, monospace',
  },

  accent: {
    clear: '#5eead4',
    cloud: '#93c5fd',
    rain: '#60a5fa',
    storm: '#f59e0b',
    snow: '#cbd5e1',
    fog: '#a1a1aa',
    fallback: '#5eead4',
  },

  radius: {
    panel: '18px',
    inner: '10px',
  },

  spacing: {
    panelPadding: '18px 18px 16px',
    rowPadding: '10px 12px',
  },

  effects: {
    blur: 'blur(10px)',
    textGlow: '0 0 12px rgba(255, 190, 90, 0.10)',
    panelShadow: `
      0 16px 36px rgba(0, 0, 0, 0.38),
      inset 0 1px 0 rgba(255, 220, 180, 0.05)
    `,
    innerShadow: `
      inset 0 1px 0 rgba(255, 255, 255, 0.03),
      inset 0 -1px 0 rgba(0, 0, 0, 0.25)
    `,
  },

  type: {
    label: {
      size: '12px',
      spacing: '0.18em',
    },
    value: {
      size: '20px',
      spacing: '0.08em',
    },
    time: {
      size: '38px',
      spacing: '0.10em',
    },
  },
};