const DEFAULT_BU_EVENTS_API_URL = '/api/bu-events?cid=20';

export const googleMapKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY ?? '';
export const buEventsApiUrl = import.meta.env.VITE_BU_EVENTS_API_URL ?? DEFAULT_BU_EVENTS_API_URL;