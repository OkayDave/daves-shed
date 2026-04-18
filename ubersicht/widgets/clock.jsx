import {
  panelBase,
  boardBase,
  rowBase,
  labelBase,
  valueBase,
  errorBase,
} from './lib/styles';
import { theme } from './lib/theme';

export const command = `zsh -l -c 'ruby "../scripts/clock.rb"'`;

export const refreshFrequency = 1000;

export const className = `
  top: 28px;
  right: 28px;
  width: 390px;
  height: 200px;
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
  }

  .time {
    font-size: ${theme.type.time.size};
    letter-spacing: ${theme.type.time.spacing};
  }

  .seconds {
    font-size: 16px;
    margin-left: 8px;
  }

  .error {
    ${errorBase}
  }
`;

export const render = ({ output }) => {
  if (!output || output.trim() === "") {
    return (
      <div>
        <div className="error">No data</div>
      </div>
    );
  }

  try {
    const data = JSON.parse(output);

    return (
      <div>
        <div className="board">
          <div className="row">
            <div className="label">Day</div>
            <div className="value">{data.date.day.full_name}</div>
          </div>

          <div className="row">
            <div className="label">Date</div>
            <div className="value">
              {data.date.day.number} {data.date.month.full_name}
            </div>
          </div>

          <div className="row">
            <div className="label">Time</div>
            <div className="value time">
              {data.time.hour}:{data.time.minute}:{data.time.second}
            </div>
          </div>
        </div>
      </div>
    );
  } catch (e) {
    return (
      <div>
        <div className="error">Could not parse Clock JSON</div>
      </div>
    );
  }
};
