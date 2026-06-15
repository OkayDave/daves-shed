import { panelBase, boardBase } from './lib/styles';
import { theme } from './lib/theme';

export const command = `zsh -l -c 'ruby "../scripts/eyes.rb"'`;

export const refreshFrequency = false;

export const className = `
  bottom: 28px;
  right: 446px;
  width: 390px;
  height: 84px;
  display: none;
  ${panelBase}

  .board {
    ${boardBase}
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .eyes-container {
    display: flex;
    gap: 24px;
    align-items: center;
  }

  .eye {
    width: 48px;
    height: 48px;
    background: #fff;
    border-radius: 50%;
    position: relative;
    box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.15);
  }

  .pupil {
    width: 20px;
    height: 20px;
    background: #1a1a1a;
    border-radius: 50%;
    position: absolute;
    top: 50%;
    left: 50%;
    transition: transform 60ms ease-out;
  }

  .pupil::after {
    content: '';
    position: absolute;
    width: 6px;
    height: 6px;
    background: #fff;
    border-radius: 50%;
    top: 3px;
    left: 3px;
  }
`;

export const render = ({ output }) => (
  <div className="board">
    <div className="eyes-container">
      <div className="eye">
        <div className="pupil" />
      </div>
      <div className="eye">
        <div className="pupil" />
      </div>
    </div>
  </div>
);

export const afterRender = (dom, { output }) => {
  if (!output) return;

  const [mx, my] = output.trim().split(',').map(Number);
  if (isNaN(mx) || isNaN(my)) return;

  const maxOffset = 12;
  const eyes = dom.querySelectorAll('.eye');

  eyes.forEach((eye) => {
    const pupil = eye.querySelector('.pupil');
    const rect = eye.getBoundingClientRect();
    const eyeCenterX = rect.left + rect.width / 2;
    const eyeCenterY = rect.top + rect.height / 2;

    const dx = mx - eyeCenterX;
    const dy = my - eyeCenterY;
    const angle = Math.atan2(dy, dx);
    const distance = Math.min(Math.sqrt(dx * dx + dy * dy), 400);
    const offset = (distance / 400) * maxOffset;

    const x = Math.cos(angle) * offset;
    const y = Math.sin(angle) * offset;

    pupil.style.transform = `translate(calc(-50% + ${x}px), calc(-50% + ${y}px))`;
  });
};
