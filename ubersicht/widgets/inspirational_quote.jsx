export const command = "zsh -l -c 'ruby ../scripts/inspirational_quote.rb'"
// export const command = "zsh -l -c 'which ruby'"
export const refreshFrequency = 600000; // 10 minutes

export const className = `
  top: 260px;
  right: 28px;
  width: 390px;
  height: 275px;
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
    font-size: 16px;
    font-weight: 700;
    line-height: 1;
    letter-spacing: 0.08em;
    color: #ffd98e;
    text-shadow: 0 0 12px rgba(255, 190, 90, 0.10);
  }

  .quote-box {
    padding: 14px 12px;
    background: rgba(0, 0, 0, 0.15);
    border: 1px solid rgba(255, 217, 142, 0.05);
    border-radius: 10px;
    font-size: 18px;
    line-height: 1.5;
    font-style: italic;
    text-align: center;
    color: #ffd98e;
    text-shadow: 0 0 12px rgba(255, 190, 90, 0.10);
  }

  .image-box {
    margin-top: 4px;
    border-radius: 10px;
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
    font-size: 14px;
    color: #ffb7a8;
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
