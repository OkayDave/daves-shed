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

const truncate = (value, max = 34) => {
  if (!value) return '';
  return value.length > max ? `${value.slice(0, max - 1)}…` : value;
};

const eventAccent = (event) => {
  if (event?.is_now) return theme.accent?.playing || '#22c55e';
  if (event?.is_upcoming) return theme.accent?.cloud || '#93c5fd';
  return theme.accent?.idle || '#a1a1aa';
};

export const command = `zsh -l -c 'ruby "../scripts/calendar.rb"'`;
export const refreshFrequency = 60_000; // 1 minute

export const className = `
  top: 260px;
  right: 446px;
  width: 390px;
  min-height: 280px;
  ${panelBase}

  .board {
    ${boardBase}
  }

  .headline {
    ${headlineBoxBase}
  }

  .headline-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
  }

  .headline-title {
    font-size: 22px;
    font-weight: 700;
    line-height: 1.15;
    letter-spacing: 0.03em;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .headline-badge {
    flex-shrink: 0;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    color: var(--headline-accent, ${theme.accent.fallback});
  }

  .headline-date {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.14em;
    color: ${theme.colours.muted};
  }

  .headline-next {
    font-size: 14px;
    line-height: 1.35;
    color: ${theme.colours.muted};
  }

  .events {
    display: grid;
    gap: 8px;
  }

  .event-row {
    ${rowBase}
    align-items: flex-start;
    border-left: 3px solid var(--event-accent, rgba(255,255,255,0.12));
    padding-left: 10px;
  }

  .event-time {
    ${labelBase}
    min-width: 82px;
    color: var(--event-accent, ${theme.colours.text});
  }

  .event-main {
    flex: 1;
    min-width: 0;
  }

  .event-title {
    font-size: 17px;
    font-weight: 700;
    line-height: 1.25;
    letter-spacing: 0.03em;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .event-meta {
    margin-top: 4px;
    font-size: 12px;
    line-height: 1.35;
    letter-spacing: 0.04em;
    color: ${theme.colours.muted};
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .empty-state {
    ${headlineBoxBase}
    place-items: center;
    min-height: 120px;
    text-align: center;
  }

  .empty-title {
    font-size: 22px;
    font-weight: 700;
    line-height: 1.2;
    color: ${theme.colours.text};
    text-shadow: ${theme.effects.textGlow};
  }

  .empty-copy {
    font-size: 13px;
    line-height: 1.4;
    letter-spacing: 0.04em;
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

    if (data.error) {
      return (
        <div className="error">
          {data.error}
          {data.detail ? `: ${data.detail}` : ''}
        </div>
      );
    }

    if (!data.summary?.has_events || !data.events?.length) {
      const accent = theme.accent?.idle || '#a1a1aa';
      const emptyStyle = {
        '--headline-accent': accent,
        '--headline-tint': `${accent}14`,
        '--headline-border': `${accent}33`,
      };

      return (
        <div className="board">
          <div className="headline" style={emptyStyle}>
            <div className="headline-top">
              <div className="headline-title">Today</div>
              <div className="headline-badge">Clear</div>
            </div>
            <div className="headline-date">{data.date?.label}</div>
            <div className="headline-next">No events today</div>
          </div>

          <div className="empty-state" style={emptyStyle}>
            <div className="empty-title">Nothing booked</div>
            <div className="empty-copy">You appear to have a rare free day.</div>
          </div>
        </div>
      );
    }

    const headlineAccent = data.summary?.next_is_now
      ? (theme.accent?.playing || '#22c55e')
      : (theme.accent?.cloud || '#93c5fd');

    const headlineStyle = {
      '--headline-accent': headlineAccent,
      '--headline-tint': `${headlineAccent}14`,
      '--headline-border': `${headlineAccent}33`,
    };

    return (
      <div className="board">
        <div className="headline" style={headlineStyle}>
          <div className="headline-top">
            <div className="headline-title">Today</div>
            <div className="headline-badge">{data.summary.count} event{data.summary.count === 1 ? '' : 's'}</div>
          </div>

          <div className="headline-date">{data.date.label}</div>

          <div className="headline-next">
            {data.summary.next_title
              ? data.summary.next_is_now
                ? `Now: ${truncate(data.summary.next_title, 42)}`
                : `Next: ${data.summary.next_start} — ${truncate(data.summary.next_title, 36)}`
              : 'Nothing else scheduled'}
          </div>
        </div>

        <div className="events">
          {data.events.map((event, index) => {
            const accent = eventAccent(event);
            const style = { '--event-accent': accent };

            return (
              <div className="event-row" style={style} key={`${event.start_timestamp}-${index}`}>
                <div className="event-time">
                  {event.all_day ? 'All day' : event.start}
                </div>

                <div className="event-main">
                  <div className="event-title">{event.title}</div>
                  <div className="event-meta">
                    {event.all_day
                      ? event.calendar
                      : `${event.start}–${event.end} · ${event.calendar}`}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    );
  } catch (e) {
    return <div className="error">Could not parse Calendar JSON</div>;
  }
};
