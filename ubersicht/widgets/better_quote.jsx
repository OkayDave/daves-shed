import {
  panelBase,
  boardBase,
  rowBase,
  labelBase,
  valueBase,
  errorBase,
} from './lib/styles';
import { theme } from './lib/theme';

export const command = `zsh -l -c 'ruby "../scripts/better_quote.rb" | jq'`;

export const refreshFrequency = 300000; // 5 minutes

const toneColours = {
  aggressive: "#ff4d4d",
  calm: "#4dd0e1",
  philosophical: "#c5c6c7",
  intense: "#ff6b6b",
  melancholic: "#9aa0a6",
  punchy: "#ffd166",
};

const fallbackToneColour = "rgba(255, 217, 142, 0.85)";

const truncateQuote = (quote, maxLength = 280) => {
  if (!quote) return "No quote available";
  const trimmed = quote.trim();
  if (trimmed.length <= maxLength) return trimmed;
  return `${trimmed.slice(0, maxLength).trimEnd()}…`;
};

const buildMeta = (data) => {
  const bits = [];
  if (data && data.source && data.source.trim() !== "") bits.push(data.source.trim());
  if (data && data.year) bits.push(String(data.year));
  return bits.join(" · ");
};

const parseOutput = (output) => {
  if (!output || output.trim() === "") return null;
  return JSON.parse(output);
};

export const initialState = {
  data: null,
  error: null,
  isRefreshing: false,
};

export const updateState = (event, previousState) => {
  if (event.type === "MANUAL_REFRESH_START") {
    return {
      ...previousState,
      isRefreshing: true,
    };
  }

  if (event.error) {
    return {
      ...previousState,
      error: event.error,
      isRefreshing: false,
    };
  }

  try {
    const data = parseOutput(event.output);
    return {
      ...previousState,
      data,
      error: null,
      isRefreshing: false,
    };
  } catch (e) {
    return {
      ...previousState,
      error: `Could not parse Quote JSON: ${event.output}`,
      isRefreshing: false,
    };
  }
};

export const className = `
  top: 260px;
  right: 28px;
  width: 390px;
  height: 275px;
  ${panelBase}

  .board {
    ${boardBase}
    height: 100%;
    display: flex;
    flex-direction: column;
  }

  .row {
    ${rowBase}
    margin-bottom: 8px;
    flex-shrink: 0;
  }

  .label {
    ${labelBase}
    min-width: 64px;
  }

  .value {
    ${valueBase}
    font-size: 16px;
    transition: color 420ms ease, text-shadow 420ms ease, opacity 220ms ease;
  }

  .quote-box {
    position: relative;
    flex: 1;
    min-height: 0;
    padding: 16px 14px 14px;
    background: rgba(0, 0, 0, 0.15);
    border: 1px solid rgba(255, 217, 142, 0.05);
    border-left: 3px solid rgba(255, 217, 142, 0.2);
    border-radius: ${theme.radius.inner};
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
    display: flex;
    flex-direction: column;
    overflow: hidden;
    user-select: none;
    cursor: pointer;
    transition:
      opacity 280ms ease,
      transform 280ms ease,
      box-shadow 420ms ease,
      border-left-color 420ms ease,
      background 420ms ease;
  }

  .quote-box:hover {
    transform: translateY(-1px);
  }

  .quote-box.is-refreshing {
    opacity: 0.18;
    transform: translateY(6px) scale(0.985);
  }

  .quote-content {
    flex: 1;
    min-height: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
  }

  .quote-text {
    margin: 0;
    width: 100%;
    text-align: center;
    font-style: italic;
    font-size: 18px;
    line-height: 1.55;
    display: -webkit-box;
    -webkit-line-clamp: 6;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    transition:
      opacity 320ms ease,
      transform 320ms ease,
      color 420ms ease,
      text-shadow 420ms ease;
  }

  .quote-box.is-refreshing .quote-text {
    opacity: 0;
    transform: translateY(8px);
  }

  .quote-footer {
    margin-top: 12px;
    display: flex;
    justify-content: flex-end;
    align-items: baseline;
    gap: 8px;
    flex-wrap: wrap;
    text-align: right;
    flex-shrink: 0;
    transition: opacity 320ms ease, transform 320ms ease;
  }

  .quote-box.is-refreshing .quote-footer {
    opacity: 0;
    transform: translateY(6px);
  }

  .quote-author {
    font-weight: bold;
    transition: color 420ms ease, text-shadow 420ms ease;
  }

  .quote-meta {
    font-size: 13px;
    opacity: 0.78;
    font-weight: 400;
    transition: color 420ms ease, opacity 420ms ease;
  }

  .refresh-hint {
    position: absolute;
    top: 10px;
    right: 12px;
    font-size: 11px;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    opacity: 0;
    transition: opacity 180ms ease, color 420ms ease;
    pointer-events: none;
  }

  .quote-box:hover .refresh-hint {
    opacity: 0.45;
  }

  .error {
    ${errorBase}
  }
`;

export const render = (state, dispatch) => {
  if (state.error) {
    return (
      <div className="error">
        Error: {String(state.error)}
      </div>
    );
  }

  if (!state.data) {
    return (
      <div className="error">
        No data
      </div>
    );
  }

  const data = state.data;
  const tone = ((data.tone || "").trim().toLowerCase());
  const toneColour = toneColours[tone] || fallbackToneColour;
  const meta = buildMeta(data);
  const quote = truncateQuote(data.quote, 280);
  const accentGlow = `${toneColour}22`;
  const accentGlowStrong = `${toneColour}44`;

  const handleRefresh = () => {
    dispatch({ type: "MANUAL_REFRESH_START" });

    setTimeout(() => {
      run(command);
    }, 180);
  };

  return (
    <div className="board">
      <div className="row">
        <div className="label">Tone</div>
        <div
          className="value"
          style={{
            color: toneColour,
            textShadow: `0 0 10px ${accentGlowStrong}`,
          }}
        >
          {data.tone || "unknown"}
        </div>
      </div>

      <div
        className={`quote-box ${state.isRefreshing ? "is-refreshing" : ""}`}
        onClick={handleRefresh}
        style={{
          borderLeftColor: toneColour,
          background: `linear-gradient(180deg, rgba(0,0,0,0.16), rgba(0,0,0,0.22)), linear-gradient(90deg, ${accentGlow} 0%, rgba(0,0,0,0) 22%)`,
          boxShadow: `inset 0 0 0 1px rgba(255,255,255,0.01), 0 0 18px ${accentGlow}, 0 0 34px ${accentGlow}`,
        }}
      >
        <div className="refresh-hint" style={{ color: toneColour }}>
          refresh
        </div>

        <div className="quote-content">
          <blockquote
            className="quote-text"
            style={{
              color: theme.colours.text,
              textShadow: `${theme.effects.textGlow}, 0 0 14px ${accentGlow}`,
            }}
          >
            “{quote}”
          </blockquote>
        </div>

        <div className="quote-footer">
          <span
            className="quote-author"
            style={{
              color: toneColour,
              textShadow: `0 0 10px ${accentGlowStrong}`,
            }}
          >
            {data.author ? data.author.trim() : "Unknown"}
          </span>

          {meta && (
            <span className="quote-meta">
              {meta}
            </span>
          )}
        </div>
      </div>
    </div>
  );
};
