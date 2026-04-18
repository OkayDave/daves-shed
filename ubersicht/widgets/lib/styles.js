import { theme } from './theme';

export const panelBase = `
  box-sizing: border-box;
  padding: ${theme.spacing.panelPadding};
  background: ${theme.colours.panel};
  -webkit-backdrop-filter: ${theme.effects.blur};
  backdrop-filter: ${theme.effects.blur};
  border: 1px solid ${theme.colours.border};
  border-radius: ${theme.radius.panel};
  box-shadow: ${theme.effects.panelShadow};
  color: ${theme.colours.text};
  font-family: ${theme.font.family};
  overflow: hidden;
`;

export const boardBase = `
  display: grid;
  gap: 10px;
`;

export const rowBase = `
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: ${theme.spacing.rowPadding};
  background:
    linear-gradient(
      180deg,
      ${theme.colours.panelHighlight},
      ${theme.colours.panelShadow}
    );
  border: 1px solid ${theme.colours.innerBorder};
  border-radius: ${theme.radius.inner};
  box-shadow: ${theme.effects.innerShadow};
`;

export const labelBase = `
  font-size: ${theme.type.label.size};
  text-transform: uppercase;
  letter-spacing: ${theme.type.label.spacing};
  color: ${theme.colours.text};
`;

export const valueBase = `
  flex: 1;
  text-align: right;
  font-size: ${theme.type.value.size};
  font-weight: 700;
  line-height: 1;
  letter-spacing: ${theme.type.value.spacing};
  color: ${theme.colours.text};
  text-shadow: ${theme.effects.textGlow};
`;

export const errorBase = `
  font-size: 14px;
  color: ${theme.colours.error};
`;