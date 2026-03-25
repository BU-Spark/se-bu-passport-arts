import { Event } from '../interfaces/Event';

const PLACEHOLDER_EVENT_PHOTOS = new Set(['', '/bu.svg']);

const isPlaceholderEventPhoto = (eventPhoto: string): boolean =>
  PLACEHOLDER_EVENT_PHOTOS.has(eventPhoto.trim());

const buildPlaceholderDataUri = (): string => {
  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630" preserveAspectRatio="none">
      <rect width="1200" height="630" fill="#9ca3af" />
      <rect width="1200" height="630" fill="#000000" opacity="0.16" />
    </svg>
  `;

  return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svg)}`;
};

export const getEventVisualSrc = (event: Pick<Event, 'eventID' | 'eventTitle' | 'eventPhoto'>): string => {
  if (!isPlaceholderEventPhoto(event.eventPhoto)) {
    return event.eventPhoto;
  }

  return buildPlaceholderDataUri();
};
