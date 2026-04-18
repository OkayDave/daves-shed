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

const playbackAccent = (state = '') => {
  const value = state.toLowerCase();

  if (value === 'playing') return theme.accent.playing || '#22c55e';
  if (value === 'paused') return theme.accent.paused || '#f59e0b';
  if (value === 'stopped') return theme.accent.idle || '#a1a1aa';

  return theme.accent.idle || '#a1a1aa';
};

const playbackIcon = (state = '') => {
  const value = state.toLowerCase();

  if (value === 'playing') return '▶';
  if (value === 'paused') return '❚❚';
  return '■';
};

const formatTime = (seconds) => {
  const total = Math.max(0, Math.floor(seconds || 0));
  const mins = Math.floor(total / 60);
  const secs = String(total % 60).padStart(2, '0');
  return `${mins}:${secs}`;
};

const progressPercent = (position, duration) => {
  if (!duration || duration <= 0) return 0;
  return Math.max(0, Math.min(100, (position / duration) * 100));
};

export const command = `zsh -l -c 'ruby "../scripts/spotify_now_playing.rb"'`;
export const refreshFrequency = 1000;

export const className = `
  top: 28px;
  right: 446px;
  width: 390px;
  max-height: 320px;
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

  .track-block {
    flex: 1;
    min-width: 0;
  }

  .track-name {
    font-size: 22px;
    font-weight: 700;
    line-height: 1.15;
    letter-spacing: 0.03em;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .artist-name {
    margin-top: 8px;
    margin-bottom: 2px;
    font-size: 16px;
    line-height: 1.3;
    letter-spacing: 0.05em;
    color: ${theme.colours.muted};
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .playback-icon {
    flex-shrink: 0;
    font-size: 28px;
    line-height: 1;
    color: var(--headline-accent, ${theme.accent?.playing || '#22c55e'});
    text-shadow: 0 0 18px var(--headline-accent, ${theme.accent?.playing || '#22c55e'});
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
      var(--headline-accent, ${theme.accent?.playing || '#22c55e'}),
      rgba(255, 255, 255, 0.65)
    );
    box-shadow: 0 0 14px var(--headline-accent, ${theme.accent?.playing || '#22c55e'});
    border-radius: 999px;
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
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .empty-state {
    ${headlineBoxBase}
    place-items: center;
    min-height: 118px;
    text-align: center;
  }

  .empty-title {
    font-size: 22px;
    font-weight: 700;
    line-height: 1.2;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .empty-copy {
    font-size: 13px;
    line-height: 1.4;
    letter-spacing: 0.04em;
    color: ${theme.colours.muted};
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

    if (!data.app?.running) {
      const accent = theme.accent?.idle || '#a1a1aa';
      const emptyStyle = {
        '--headline-accent': accent,
        '--headline-tint': `${accent}14`,
        '--headline-border': `${accent}33`,
      };

      return (
        <div className="board">
          <div className="empty-state" style={emptyStyle}>
            <div className="empty-title">Spotify closed</div>
            <div className="empty-copy">Open Spotify to show now playing</div>
          </div>
        </div>
      );
    }

    if (data.playback?.state === 'stopped') {
      const accent = theme.accent?.idle || '#a1a1aa';
      const emptyStyle = {
        '--headline-accent': accent,
        '--headline-tint': `${accent}14`,
        '--headline-border': `${accent}33`,
      };

      return (
        <div className="board">
          <div className="empty-state" style={emptyStyle}>
            <div className="empty-title">Nothing playing</div>
            <div className="empty-copy">Spotify is open, but playback is stopped</div>
          </div>
        </div>
      );
    }

    const state = data.playback?.state || 'stopped';
    const accent = playbackAccent(state);
    const duration = data.track?.duration_seconds || 0;
    const position = data.track?.position_seconds || 0;
    const progress = `${progressPercent(position, duration)}%`;

    const headlineStyle = {
      '--headline-accent': accent,
      '--headline-tint': `${accent}14`,
      '--headline-border': `${accent}33`,
      '--progress-width': progress,
    };

    return (
      <div className="board">
        <div className="headline" style={headlineStyle}>
          <div className="headline-top">
            <div className="track-block">
              <div className="track-name">{data.track.name.slice(0, 19)}</div>
              <div className="artist-name">{data.track.artist} <br /> <strong>{data.track.album}</strong></div>
            </div>

            <div className="playback-icon">{playbackIcon(state)}</div>
          </div>

          <div className="progress">
            <div className="progress-bar"></div>
          </div>

        </div>
      </div>
    );
  } catch (e) {
    return <div className="error">Could not parse Spotify JSON</div>;
  }
};
