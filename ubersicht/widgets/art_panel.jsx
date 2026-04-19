import { run } from 'uebersicht';
import { panelBase, errorBase } from './lib/styles';
import { theme } from './lib/theme';

const statusCommand = `zsh -lc 'ruby "../scripts/art_panel.rb" status'`;
const nextImageCommand = `zsh -lc 'ruby "../scripts/art_panel.rb" next'`;

export const command = statusCommand;
export const refreshFrequency = 100000;

export const className = `
  top: 28px;
  left: 28px;
  width: 780px;
  height: calc(100vh - 56px);
  ${panelBase}
  padding: 10px;
  display: flex;
  align-items: stretch;
  justify-content: stretch;
  cursor: pointer;

  .image-frame {
    position: relative;
    width: 100%;
    height: 100%;
    overflow: hidden;
    border-radius: ${theme.radius.panel};
    background: rgba(0, 0, 0, 0.18);
    border: 1px solid ${theme.colours.innerBorder};
    box-shadow: ${theme.effects.innerShadow};
  }

  .image {
    width: 100%;
    height: 100%;
    display: block;
    object-fit: cover;
    object-position: center center;
    user-select: none;
    -webkit-user-drag: none;
    opacity: 0.97;
    transition: opacity 260ms ease;
  }

  .image.is-fading {
    opacity: 0.08;
  }

  .image-overlay {
    position: absolute;
    inset: 0;
    pointer-events: none;
    background:
      linear-gradient(
        180deg,
        rgba(255, 255, 255, 0.02),
        rgba(0, 0, 0, 0.10)
      );
  }

  .footer {
    position: absolute;
    right: 12px;
    bottom: 12px;
    padding: 6px 10px;
    border-radius: ${theme.radius.inner};
    background: rgba(0, 0, 0, 0.28);
    border: 1px solid rgba(255, 217, 142, 0.10);
    font-size: 11px;
    line-height: 1;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: ${theme.colours.muted};
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
  }

  .error {
    ${errorBase}
    width: 100%;
    display: grid;
    place-items: center;
    text-align: center;
    line-height: 1.5;
    white-space: normal;
  }
`;

const parseJson = (value) => {
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
};

const preloadImage = (src) =>
  new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = () => resolve();
    img.onerror = reject;
    img.src = src;
  });

const sleep = (ms) => new Promise((resolve) => window.setTimeout(resolve, ms));

const handleImageClick = async (event) => {
  const frame = event.currentTarget;
  const image = frame.querySelector('.image');
  const footer = frame.querySelector('.footer');

  if (!image || !footer) return;
  if (frame.dataset.loading === 'true') return;

  const originalFooter = footer.textContent;
  frame.dataset.loading = 'true';

  try {
    footer.textContent = '…';

    const output = await run(nextImageCommand);
    const data = parseJson(output);

    if (!data || data.error || !data.image_src) {
      footer.textContent = 'Error';
      return;
    }

    await preloadImage(data.image_src);

    image.classList.add('is-fading');
    await sleep(180);

    image.src = data.image_src;
    footer.textContent = `↻ · ${data.count} image${data.count === 1 ? '' : 's'}`;

    await sleep(30);
    image.classList.remove('is-fading');
  } catch (err) {
    console.error(err);
    footer.textContent = 'Error';
  } finally {
    frame.dataset.loading = 'false';

    window.setTimeout(() => {
      if (footer.textContent === 'Error' || footer.textContent === '…') {
        footer.textContent = originalFooter;
      }
    }, 1200);
  }
};

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

    return (
      <div className="image-frame" onClick={handleImageClick}>
        <img className="image" src={data.image_src} alt="" />
        <div className="image-overlay"></div>
        <div className="footer">
          ↻ · {data.count} image{data.count === 1 ? '' : 's'}
        </div>
      </div>
    );
  } catch (e) {
    return <div className="error">Could not parse Art Panel JSON</div>;
  }
};
