import {
  panelBase,
  boardBase,
  rowBase,
  labelBase,
  valueBase,
  errorBase,
} from './lib/styles';
import { theme } from './lib/theme';

export const command = `zsh -l -c 'ruby "../scripts/inspirational_quote.rb"'`;
// export const command = `zsh -l -c 'which ruby'`;

export const refreshFrequency = 600000; // 10 minutes

export const className = `
  top: 260px;
  right: 28px;
  width: 390px;
  height: 275px;
  ${panelBase}

  .board {
    ${boardBase}
  }

  .row {
    ${rowBase}
  }

  .label {
    ${labelBase}
    min-width: 64px;
  }

  .value {
    ${valueBase}
    font-size: 16px;
  }

  .quote-box {
    padding: 14px 12px;
    background: rgba(0, 0, 0, 0.15);
    border: 1px solid rgba(255, 217, 142, 0.05);
    border-radius: ${theme.radius.inner};
    font-size: 18px;
    line-height: 1.5;
    font-style: italic;
    text-align: center;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .image-box {
    margin-top: 4px;
    border-radius: ${theme.radius.inner};
    overflow: hidden;
    border: 1px solid rgba(255, 217, 142, 0.1);
    background: #000;
  }

  .image-box img {
    width: 100%;
    display: block;
    opacity: 0.9;
  }

  .error {
    ${errorBase}
  }
`;

export const render = ({ output, error }) => {
  if (error) {
    return (
      <div className="error">
        Error: {String(error)}
      </div>
    );
  }

  if (!output || output.trim() === "") {
    return (
      <div className="error">
        No data
      </div>
    );
  }

  try {
    const data = JSON.parse(output);

    return (
      <div className="board">
        <div className="row">
          <div className="label"></div>
          <div className="value">{data.Category}</div>
        </div>

        <div className="quote-box">
          {data.Quote ? data.Quote.trim() : "No quote available"}
        </div>
      </div>
    );
  } catch (e) {
    return (
      <div className="error">
        Could not parse Quote JSON: {output}
      </div>
    );
  }
};
