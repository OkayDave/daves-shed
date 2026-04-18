export const command = "ruby ../scripts/clock.rb";

export const refreshFrequency = 1000;

export const className = `
  top: 28px;
  right: 28px;
  width: 390px;
  box-sizing: border-box;
  padding: 18px 18px 16px;
  background: rgba(28, 24, 20, 0.88);
  -webkit-backdrop-filter: blur(10px);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 214, 153, 0.38);
  border-radius: 18px;
  box-shadow:
    0 16px 36px rgba(0, 0, 0, 0.38),
    inset 0 1px 0 rgba(255, 220, 180, 0.05);
  color: #ffd98e;
  font-family: "Rec Mono Casual", Menlo, Monaco, monospace;
  overflow: hidden;

  .board {
    display: grid;
    gap: 10px;
  }

  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 10px 12px;
    background:
      linear-gradient(
        180deg,
        rgba(255, 255, 255, 0.03),
        rgba(0, 0, 0, 0.10)
      );
    border: 1px solid rgba(255, 217, 142, 0.08);
    border-radius: 10px;
    box-shadow:
      inset 0 1px 0 rgba(255, 255, 255, 0.03),
      inset 0 -1px 0 rgba(0, 0, 0, 0.25);
  }

  .label {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.18em;
    color: rgba(255, 217, 142, 1.0);
    min-width: 64px;
  }

  .value {
    flex: 1;
    text-align: right;
    font-size: 20px;
    font-weight: 700;
    line-height: 1;
    letter-spacing: 0.08em;
    color: #ffd98e;
    text-shadow: 0 0 12px rgba(255, 190, 90, 0.10);
  }

  .time {
    font-size: 38px;
    letter-spacing: 0.10em;
  }

  .seconds {
    font-size: 16px;
    margin-left: 8px;
  }

  .error {
    font-size: 14px;
    color: #ffb7a8;
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