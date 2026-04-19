import { panelBase, boardBase, errorBase } from './lib/styles';
import { theme } from './lib/theme';
import { run } from 'uebersicht';

const shellEscapeSingle = (value = '') => `'${String(value).replace(/'/g, `'\\''`)}'`;

const detachedShellCommand = (inner = '') =>
  `zsh -lc ${shellEscapeSingle(`${inner} >/dev/null 2>&1 &`)}`;

const openAction = (action = {}) => {
  if (action.type === 'url' && action.target) {
    return detachedShellCommand(`open ${shellEscapeSingle(action.target)}`);
  }

  if (action.type === 'app' && action.target) {
    return detachedShellCommand(`open -a ${shellEscapeSingle(action.target)}`);
  }

  return null;
};

export const command = `zsh -lc 'ruby "../scripts/launcher.rb"'`;
export const refreshFrequency = 3_600_000;

export const className = `
  bottom: 28px;
  right: 28px;
  width: 390px;
  height: 84px;
  ${panelBase}

  .board {
    ${boardBase}
    height: 100%;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .icons {
    display: flex;
    justify-content: space-around;
    align-items: center;
    gap: 12px;
  }

  .icon-button {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    cursor: pointer;
    user-select: none;
    transition: transform 120ms ease, background 120ms ease;
    padding: 8px;
    border-radius: ${theme.radius.inner};
    border: 1px solid transparent;
  }

  .icon-button:hover {
    transform: translateY(-2px);
    background: ${theme.colours.panelHighlight};
    border-color: ${theme.colours.innerBorder};
  }

  .icon-button:active {
    transform: translateY(0);
  }

  .icon-glyph {
    font-size: 24px;
    line-height: 1;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .icon-label {
    font-size: 9px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.12em;
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
    const launchers = Array.isArray(data.launchers) ? data.launchers : [];

    if (launchers.length === 0) {
      return <div className="error">No launchers configured</div>;
    }

    return (
      <div className="board">
        <div className="icons">
          {launchers.map((launcher) => {
            const action = openAction(launcher.action);
            const glyph = launcher.icon || launcher.label?.slice(0, 2)?.toUpperCase() || '??';

            return (
              <div
                key={launcher.id || launcher.label}
                className="icon-button"
                onClick={() => action && run(action)}
              >
                <div className="icon-glyph">{glyph}</div>
                <div className="icon-label">{launcher.label}</div>
              </div>
            );
          })}
        </div>
      </div>
    );
  } catch (e) {
    return <div className="error">Could not parse Launcher JSON</div>;
  }
};
