import requests
from datetime import datetime

from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Dict

import firebase_admin
from firebase_admin import credentials, firestore

from bs4 import BeautifulSoup
import pytz
from urllib.parse import urlparse, parse_qs


def get_session_id_from_url(url):
    parsed_url = urlparse(url)
    query_params = parse_qs(parsed_url.query)
    return query_params.get("oid", [None])[0]


@dataclass
class EventSession:
    session_id: str = ""
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None

    def to_dict(self):
        return {
            "sessionId": self.session_id,
            "startTime": self.start_time,
            "endTime": self.end_time,
            "savedUsers": [],
        }


@dataclass
class CFAEvent:
    event_id: str = ""
    title: Optional[str] = None
    description: Optional[str] = None
    categories: List[str] = field(default_factory=list)
    location: Optional[str] = None
    photo: Optional[str] = None
    points: int = 0  # Default points to 0
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    event_url: Optional[str] = None
    detail_url: Optional[str] = None
    sessions: Dict[str, "EventSession"] = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "eventID": self.event_id,
            "eventTitle": self.title,
            "eventCategories": self.categories,
            "eventLocation": self.location,
            "eventURL": self.event_url,
            "eventDescription": self.description,
            "eventPhoto": self.photo,
            "eventPoints": 30,
            "eventSessions": {
                session_id: session.to_dict()
                for session_id, session in self.sessions.items()
            },
        }

    def to_dict_no_sessions(self):
        return {
            "eventID": self.event_id,
            "eventTitle": self.title,
            "eventCategories": self.categories,
            "eventLocation": self.location,
            "eventURL": self.event_url,
            "eventDescription": self.description,
            "eventPhoto": self.photo,
            "eventPoints": 0,
        }


def fetch_and_parse_url(url: str) -> BeautifulSoup:
    """Fetch content from a URL and parse it with BeautifulSoup."""
    response = requests.get(url)
    return BeautifulSoup(response.content, "html.parser")


def scrape_raw_events(soup: BeautifulSoup) -> str:
    raw_events = (
        soup.find("div", class_="wrapper")
        .find("main", class_="content")
        .find("div", class_="content-container")
        .find("section", class_=lambda x: x and "bulp-events" in x)
        .find("div", class_=lambda x: x and "bulp-content" in x)
        .find("div", class_=lambda x: x and "bulp-container" in x)
        .find_all("article")
    )
    return raw_events


def scrape_event_categories(raw_event: str) -> list[str]:
    try:
        # find categories
        raw_topic_span = raw_event.find(
            "span", class_=lambda x: x and "bulp-event-topic" in x
        )
        if raw_topic_span:
            event_topics = raw_topic_span.find_all(
                "span", class_="bulp-event-topic-text"
            )
            categories = [event.text for event in event_topics]
            return categories
        return []
    except:
        return []


def scrape_event_title(raw_event: str) -> str | None:
    try:
        raw_span = raw_event.find("h3", class_="bulp-event-title")
        if not raw_span:
            return None
        parsed_title = " ".join([word.strip() for word in raw_span.text.split(" ")])
        return parsed_title
    except:
        return None


def scrape_session_datetime(raw_detail):
    def parse_datetime(start_date, start_time, end_date, end_time):
        # Define Boston timezone
        try:
            boston_tz = pytz.timezone("America/New_York")
            # Parse the start and end times into naive datetime objects
            start_time_naive = datetime.strptime(
                f"{start_date} {start_time}", "%A, %B %d, %Y %I:%M %p"
            )
            end_time_naive = datetime.strptime(
                f"{end_date} {end_time}", "%A, %B %d, %Y %I:%M %p"
            )

            # Localize them to Boston timezone to make them timezone-aware
            start_time = boston_tz.localize(start_time_naive)
            end_time = boston_tz.localize(end_time_naive)
            return start_time, end_time
        except Exception as e:
            print(e)
            return None, None

    all_day_tag = raw_detail.find("li", class_="single-event-schedule-allday")
    if all_day_tag:
        date_text = all_day_tag.find("span", class_="single-event-date").text
        return parse_datetime(date_text, "12:00 am", date_text, "11:59 pm")
    else:
        start_tag = raw_detail.find("li", class_="single-event-schedule-start")
        end_tag = raw_detail.find("li", class_="single-event-schedule-end")
        if start_tag and end_tag:
            start_time = start_tag.find("span", class_="single-event-time").text
            start_date = start_tag.find("span", class_="single-event-date").text

            end_time = end_tag.find("span", class_="single-event-time").text
            end_date = end_tag.find("span", class_="single-event-date").text
            return parse_datetime(start_date, start_time, end_date, end_time)
    return None, None


def scrape_event_location(raw_event: str) -> str | None:
    span: str = raw_event.find("span", class_="bulp-event-where")
    if not span:
        return None
    else:
        return span.text.strip()


def scrape_event_detail_link(raw_event: str) -> Tuple[str, str] | Tuple[None, None]:
    try:
        span: str = raw_event.find("div", class_="bulp-event-buttons")
        if not span:
            return None, None, None
        a_tag = span.find("a", class_="bulp-event-readmore")
        href = a_tag["href"]

        parsed_url = urlparse(href)
        query_params = parse_qs(parsed_url.query)
        eid = query_params.get("eid", [None])[0]
        oid = query_params.get("oid", [None])[0]
        return f"https://www.bu.edu{href}", eid, oid
    except:
        return None, None, None


def scrape_detail_page(soup: BeautifulSoup):
    return (
        soup.find("div", class_="wrapper")
        .find("main", class_="content")
        .find("div", class_="content-container-narrow")
        .find("article")
        .find("div", class_="single-event")
    )


def scrape_event_image(raw_detail: str) -> str | None:
    try:
        raw_figure = (
            raw_detail.find("div", class_="single-event-summary")
            .find("div", class_="single-event-thumbnail")
            .find("img")
        )
        return f"https://www.bu.edu/{raw_figure['src']}"
    except:
        return None


def scrape_event_description(raw_detail) -> str | None:
    try:
        raw_summary = raw_detail.find("div", class_="single-event-description")
        text_content = raw_summary.get_text(separator=" ", strip=True)
        return text_content
    except:
        return None


def scrape_event_event_link(raw_detail) -> str | None:
    try:
        dd_tag = (
            raw_detail.find("div", class_="single-event-additional-details")
            .find("dl", class_="tabular")
            .find("dd", class_="single-event-info-url")
        )
        if not dd_tag:
            return None

        url = dd_tag.find("a")
        return url["href"]
    except:
        return None


def extract_event_data(raw_event) -> CFAEvent:
    """Extract data from a raw event and return a CFAEvent object."""
    cfa_event = CFAEvent()
    raw_event = raw_event.find("div", class_=lambda x: x and "bulp-item-content" in x)

    cfa_event.categories = scrape_event_categories(raw_event)
    cfa_event.title = scrape_event_title(raw_event)
    cfa_event.location = scrape_event_location(raw_event)

    cfa_event.detail_url, cfa_event.event_id, session_id = scrape_event_detail_link(
        raw_event
    )
    if session_id:
        cfa_event.sessions[session_id] = EventSession(session_id=session_id)
        cfa_event.sessions[session_id].session_id = session_id

    return cfa_event


def scrape_events(soup: BeautifulSoup) -> List[CFAEvent]:
    """Scrape events from the soup and return a list of CFAEvent objects."""
    raw_events = scrape_raw_events(soup)
    cfa_events: List[CFAEvent] = []

    for raw_event in raw_events:
        try:
            cfa_event = extract_event_data(raw_event)
            cfa_events.append(cfa_event)
        except Exception as e:
            print(f"Error extracting event data: {e}")

    return cfa_events


def initialize_firestore() -> firestore.client:
    """Initialize Firestore client."""
    cred = credentials.Certificate("../serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    return firestore.client()


def update_database(db, cfa_events, table_name):
    for _, event in enumerate(cfa_events):

        doc_ref = db.collection(table_name).document(event.event_id)
        doc = doc_ref.get()

        if doc.exists:
            print(f"Updating event with pk {event.event_id} in db")
            existing_data = doc.to_dict()

            # Update only the new sessions in eventSessions
            existing_sessions = existing_data.get("eventSessions", {})
            updated_sessions = event.sessions.copy()

            # Skip existing sessions
            for session_id in existing_sessions:
                updated_sessions.pop(session_id, None)

            # Merge event data without eventSessions
            event_dict = event.to_dict()
            if updated_sessions:
                existing_sessions.update(
                    {
                        session_id: session.to_dict()
                        for session_id, session in updated_sessions.items()
                    }
                )
                event_dict["eventSessions"] = existing_sessions
            else:
                event_dict.pop("eventSessions", None)  # Exclude if no new sessions

            # Merge attributes without overwriting eventSessions
            doc_ref.set(event.to_dict_no_sessions(), merge=True)

        else:
            print(f"Adding event with pk {event.event_id} in db")
            doc_ref.set(event.to_dict())


def update_event_details(event: CFAEvent):
    """Update event details by scraping its detail page."""
    if not event.detail_url:
        return

    response = requests.get(event.detail_url)
    soup = BeautifulSoup(response.content, "html.parser")
    raw_detail = scrape_detail_page(soup)

    event.photo = scrape_event_image(raw_detail)
    event.description = scrape_event_description(raw_detail)
    event.event_url = scrape_event_event_link(raw_detail)

    session_id = get_session_id_from_url(event.detail_url)
    if session_id in event.sessions:
        event.sessions[session_id].start_time, event.sessions[session_id].end_time = (
            scrape_session_datetime(raw_detail)
        )


def main(table_name):
    """Main function to run the scraper."""
    db = initialize_firestore()

    print("Starting scraper")

    # Fetch and parse the event list page
    soup = fetch_and_parse_url("https://www.bu.edu/cfa/news/bu-arts-initiative/")
    cfa_events = scrape_events(soup)

    # Update event details for each scraped event
    for event in cfa_events:
        update_event_details(event)

    # Update the database with the events
    update_database(db, cfa_events, table_name)

    print("Event Scraping has completed")


main("new_events1")
