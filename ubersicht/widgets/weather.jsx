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

const weatherAccent = (condition = '') => {
  const value = condition.toLowerCase();

  if (value.includes('thunder')) return theme.accent.storm;
  if (value.includes('storm')) return theme.accent.storm;
  if (value.includes('rain')) return theme.accent.rain;
  if (value.includes('drizzle')) return theme.accent.rain;
  if (value.includes('shower')) return theme.accent.rain;
  if (value.includes('snow')) return theme.accent.snow;
  if (value.includes('fog')) return theme.accent.fog;
  if (value.includes('cloud') || value.includes('overcast')) return theme.accent.cloud;
  if (value.includes('clear')) return theme.accent.clear;

  return theme.accent.fallback;
};

export const command = `zsh -l -c 'ruby "../scripts/weather.rb"'`;
export const refreshFrequency = 1_800_000;

export const className = `
  top: 565px;
  right: 28px;
  width: 390px;
  height: 375px;
  ${panelBase}

  .board {
    ${boardBase}
  }

  .headline {
    ${headlineBoxBase}
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 20px;
    padding: 20px 24px;
  }

  .headline-main {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .condition {
    font-size: 20px;
    font-weight: 700;
    line-height: 1.2;
    letter-spacing: 0.04em;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
    opacity: 0.9;
  }

  .condition-icon {
    font-size: 96px;
    line-height: 1;
    color: var(--headline-accent, ${theme.accent.fallback});
    text-shadow: 0 0 32px color-mix(in srgb, var(--headline-accent, ${theme.accent.fallback}) 35%, transparent);
    flex-shrink: 0;
  }

  .temperature {
    font-size: 44px;
    font-weight: 700;
    line-height: 1;
    letter-spacing: 0.04em;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .location {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
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

  .footer {
    margin-top: 2px;
    text-align: right;
    font-size: 11px;
    color: ${theme.colours.muted};
  }

  .footer a {
    color: ${theme.colours.muted};
    text-decoration: none;
    border-bottom: 1px solid rgba(255, 217, 142, 0.18);
  }

  .footer a:hover {
    color: ${theme.colours.text};
    border-bottom-color: rgba(255, 217, 142, 0.38);
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

    const accent = weatherAccent(data.current.condition);
    const headlineStyle = {
      '--headline-accent': accent,
      '--headline-tint': `${accent}14`,
      '--headline-border': `${accent}33`,
    };

    return (
      <div className="board">
        <div className="headline" style={headlineStyle}>
          <div className="headline-main">
            <div className="condition">{data.current.condition}</div>
            <div className="temperature">{data.current.temperature_c}°C</div>
            <div className="location">{data.location.name}</div>
          </div>
          <div className="condition-icon">{data.current.condition_icon}</div>
        </div>

        <div className="row">
          <div className="label">Feels like</div>
          <div className="value">{data.current.feels_like_c}°C</div>
        </div>

        <div className="row">
          <div className="label">High / Low</div>
          <div className="value">
            {data.today.high_c}°C / {data.today.low_c}°C
          </div>
        </div>

        <div className="row">
          <div className="label">Rain</div>
          <div className="value">{data.today.rain_chance_percent}%</div>
        </div>

        <div className="row">
          <div className="label">Wind</div>
          <div className="value">{data.current.wind_mph} mph</div>
        </div>

        <div className="footer">
          <a href={data.attribution.url}>
            Weather data by {data.attribution.name}
          </a>
        </div>
      </div>
    );
  } catch (e) {
    return <div className="error">Could not parse Weather JSON</div>;
  }
};
