import { run } from 'uebersicht';
import {
  panelBase,
  boardBase,
  rowBase,
  labelBase,
  valueBase,
  errorBase,
  headlineBoxBase,
} from './lib/styles';
import { theme } from './lib/theme';

const accentForState = (state = '') => {
  switch (state) {
    case 'running':
      return theme.accent?.playing || '#22c55e';
    case 'paused':
      return theme.accent?.paused || '#f59e0b';
    case 'done':
      return theme.colours?.crimson || '#dc2626';
    default:
      return theme.accent?.idle || '#a1a1aa';
  }
};

const iconForState = (state = '') => {
  switch (state) {
    case 'running':
      return '●';
    case 'paused':
      return '❚❚';
    case 'done':
      return '!';
    default:
      return '○';
  }
};

const labelForState = (state = '') => {
  switch (state) {
    case 'running':
      return 'Focus';
    case 'paused':
      return 'Paused';
    case 'done':
      return 'Done';
    default:
      return 'Idle';
  }
};

const formatTime = (seconds) => {
  const total = Math.max(0, Math.floor(seconds || 0));
  const mins = Math.floor(total / 60);
  const secs = String(total % 60).padStart(2, '0');
  return `${String(mins).padStart(2, '0')}:${secs}`;
};

const buttonAction = (command) =>
  `zsh -lc 'ruby "../scripts/focus_timer.rb" ${command} >/dev/null 2>&1 &'`;

const presetAction = (seconds) =>
  `zsh -lc 'ruby "../scripts/focus_timer.rb" start ${seconds} >/dev/null 2>&1 &'`;

export const command = `zsh -lc 'ruby "../scripts/focus_timer.rb" status'`;
export const refreshFrequency = 500;

export const className = `
  top: 585px;
  right: 446px;
  width: 390px;
  min-height: 320px;
  ${panelBase}

  .board {
    ${boardBase}
  }

  .headline {
    ${headlineBoxBase}
  }

  .headline-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
  }

  .headline-title {
    font-size: 22px;
    font-weight: 700;
    line-height: 1.15;
    letter-spacing: 0.03em;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .headline-badge {
    flex-shrink: 0;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    color: var(--headline-accent, ${theme.accent?.fallback || '#5eead4'});
  }

  .timer {
    font-size: 48px;
    font-weight: 700;
    line-height: 1;
    letter-spacing: 0.06em;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .mode-line {
    font-size: 13px;
    line-height: 1.4;
    letter-spacing: 0.05em;
    color: ${theme.colours.muted};
  }

  .progress {
    height: 10px;
    border-radius: 999px;
    background: rgba(0, 0, 0, 0.22);
    border: 1px solid rgba(255, 217, 142, 0.08);
    overflow: hidden;
  }

  .progress-bar {
    height: 100%;
    width: var(--progress-width, 0%);
    background: linear-gradient(
      90deg,
      var(--headline-accent, ${theme.accent?.fallback || '#5eead4'}),
      rgba(255, 255, 255, 0.65)
    );
    box-shadow: 0 0 14px var(--headline-accent, ${theme.accent?.fallback || '#5eead4'});
    border-radius: 999px;
  }

  .controls {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 8px;
  }

  .presets {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 8px;
  }

  .button {
    ${rowBase}
    justify-content: center;
    cursor: pointer;
    user-select: none;
    text-align: center;
    font-size: 14px;
    font-weight: 700;
    letter-spacing: 0.06em;
    color: ${theme.colours.text};
    transition: transform 120ms ease, border-color 120ms ease, background 120ms ease;
  }

  .button:hover {
    transform: translateY(-1px);
    border-color: rgba(255, 217, 142, 0.18);
  }

  .button:active {
    transform: translateY(0);
  }

  .button-muted {
    color: ${theme.colours.muted};
  }

  .row {
    ${rowBase}
  }

  .label {
    ${labelBase}
    min-width: 88px;
  }

  .value {
    ${valueBase}
    font-size: 18px;
  }

  .error {
    ${errorBase}
    line-height: 1.4;
    white-space: normal;
  }
`;

export const render = ({ output, error }) => {
  if (error) {
    return <div className="error">Error: {String(error)}</div>;
  }

  if (!output || output.trim() === '') {
    return <div className="error">No data</div>;
  }

  try {
    const data = JSON.parse(output);

    if (data.error) {
      return (
        <div className="error">
          {data.error}
          {data.detail ? `: ${data.detail}` : ''}
        </div>
      );
    }

    const accent = accentForState(data.state);
    const headlineStyle = {
      '--headline-accent': accent,
      '--headline-tint': `${accent}14`,
      '--headline-border': `${accent}33`,
      '--progress-width': `${data.progress_percent || 0}%`,
    };

    const stateLabel = labelForState(data.state);
    const stateIcon = iconForState(data.state);

    return (
      <div className="board">
        <div className="headline" style={headlineStyle}>
          <div className="headline-top">
            <div className="headline-title">Focus</div>
            <div className="headline-badge">{stateIcon} {stateLabel}</div>
          </div>

          <div className="timer">{formatTime(data.remaining_seconds)}</div>

          <div className="mode-line">
            {data.state === 'done'
              ? 'Session complete'
              : `${formatTime(data.elapsed_seconds)} elapsed`}
          </div>

          <div className="progress">
            <div className="progress-bar"></div>
          </div>
        </div>

        <div className="controls">
          <div
            className="button"
            onClick={() => run(buttonAction('start'))}
          >
            Start
          </div>

          <div
            className="button"
            onClick={() =>
              run(buttonAction(data.state === 'paused' ? 'resume' : 'pause'))
            }
          >
            {data.state === 'paused' ? 'Resume' : 'Pause'}
          </div>

          <div
            className="button"
            onClick={() => run(buttonAction('reset'))}
          >
            Reset
          </div>
        </div>

        <div className="presets">
          <div className="button button-muted" onClick={() => run(presetAction(25 * 60))}>
            25m
          </div>
          <div className="button button-muted" onClick={() => run(presetAction(50 * 60))}>
            50m
          </div>
          <div className="button button-muted" onClick={() => run(presetAction(10 * 60))}>
            10m
          </div>
        </div>

        <div className="row">
          <div className="label">Duration</div>
          <div className="value">{formatTime(data.duration_seconds)}</div>
        </div>

        <div className="row">
          <div className="label">Sound</div>
          <div
            className="value"
            style={{ cursor: 'pointer' }}
            onClick={() => run(buttonAction('toggle_sound'))}
          >
            {data.sound_enabled ? 'On' : 'Off'}
          </div>
        </div>
      </div>
    );
  } catch (e) {
    return <div className="error">Could not parse Focus Timer JSON</div>;
  }
};
