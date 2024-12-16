from email.contentmanager import raw_data_manager
import requests
from datetime import datetime

from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Dict

import firebase_admin
from firebase_admin import credentials, firestore

from bs4 import BeautifulSoup
import pytz
from urllib.parse import urlparse, parse_qs


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
    event_url: Optional[str] = None
    detail_url: Optional[str] = None
    sessions: Dict[str, "EventSession"] = field(default_factory=dict)

    def to_dict(self):
        return {
            "eventID": self.event_id,
            "eventTitle": self.title,
            "eventCategories": [],
            "eventLocation": self.location,
            "eventURL": self.event_url,
            "eventDescription": self.description,
            "eventPhoto": self.photo,
            "eventPoints": 0,
            "eventSessions": {
                session_id: session.to_dict()
                for session_id, session in self.sessions.items()
            },
        }

    def to_dict_no_sessions(self):
        return {
            "eventID": self.event_id,
            "eventTitle": self.title,
            "eventLocation": self.location,
            "eventURL": self.event_url,
            "eventDescription": self.description,
            "eventPhoto": self.photo,
            # "eventPoints": 0,
        }


def scrape_raw_events_ls(soup: BeautifulSoup) -> str:
    raw_events_ls = (
        soup.find("div", class_="wrapper")
        .find("main", class_="content")
        .find("div", class_="content-container")
        .find("article")
        # .find("div", class_=lambda x: x and "bulp-content" in x)
        # .find("div", class_=lambda x: x and "bulp-container" in x)
        .find_all("ul", class_="calendar-list-events")
    )
    return raw_events_ls


def scrape_raw_events(content):
    raw_events = content.find_all("li", class_="calendar-list-event")
    return raw_events


def scrape_event_image(content):
    img_tag = content.find("img")
    img_link = img_tag["srcset"].split(", ")[0].split(" ")[0] if img_tag else None
    return img_link


def scrape_event_detail_link(content: str) -> Tuple[str, str] | Tuple[None, None]:
    try:
        event_details_tag = content.find("a", class_="bulp-event-readmore")
        url = event_details_tag["href"] if event_details_tag else None
        parsed_url = urlparse(url)
        query_params = parse_qs(parsed_url.query)
        eid = query_params.get("eid", [None])[0]
        oid = query_params.get("oid", [None])[0]
        return url, eid, oid
    except:
        return None, None, None


def get_session_id_from_url(url):
    parsed_url = urlparse(url)
    query_params = parse_qs(parsed_url.query)
    return query_params.get("oid", [None])[0]


def scrape_event_title(content):
    event_title_tag = content.find("div", class_="calendar-list-event-link")
    event_title = event_title_tag.text if event_title_tag else None
    return event_title


def scrape_detail_page(soup: BeautifulSoup):
    return (
        soup.find("div", class_="wrapper")
        .find("main", class_="content")
        .find("div", class_="content-container-narrow")
        .find("article")
        .find("div", class_="single-event")
    )


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


def scrape_session_location(raw_detail):
    try:
        # Find the dd tag with the location class
        dd_tag = raw_detail.find("dd", class_="single-event-info-location")

        # Check if the dd tag exists and return its text
        if dd_tag:
            return dd_tag.text.strip()
        return None
    except Exception as e:
        print(f"Error occurred: {e}")
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
                doc_ref.set({"eventSessions": existing_sessions}, merge=True)
            else:
                event_dict.pop("eventSessions", None)  # Exclude if no new sessions

            # Merge attributes without overwriting eventSessions
            doc_ref.set(event.to_dict_no_sessions(), merge=True)

        else:
            print(f"Adding event with pk {event.event_id} in db")
            doc_ref.set(event.to_dict())


def main(table_name, start_date):
    db = initialize_firestore()
    print("Starting scraper")

    url = f"https://www.bu.edu/cfa/news/calendar/?amp%3B&topic=8639&date={start_date}"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, "html.parser")

    cfa_events: list[CFAEvent] = []

    raw_events_ls = scrape_raw_events_ls(soup)
    for _, _raw_events in enumerate(raw_events_ls):
        raws_events = scrape_raw_events(_raw_events)
        for raw_event in raws_events:
            cfa_event = CFAEvent()

            cfa_event.photo = scrape_event_image(raw_event)
            cfa_event.detail_url, cfa_event.event_id, session_id = (
                scrape_event_detail_link(raw_event)
            )
            if cfa_event.event_id:
                if not session_id:
                    session_id = "0"
                cfa_event.sessions[session_id] = EventSession()
                cfa_event.sessions[session_id].session_id = session_id

            cfa_event.title = scrape_event_title(raw_event)

            cfa_events.append(cfa_event)

    for event in cfa_events:
        if not event.detail_url:
            continue
        response = requests.get(event.detail_url)
        soup = BeautifulSoup(response.content, "html.parser")
        raw_detail = scrape_detail_page(soup)

        event.description = scrape_event_description(raw_detail)
        event.event_url = scrape_event_event_link(raw_detail)
        event.location = scrape_session_location(raw_detail)
        session_id = get_session_id_from_url(event.detail_url)
        # print(event.detail_url)
        if not session_id:
            session_id = "0"
        event.sessions[session_id].start_time, event.sessions[session_id].end_time = (
            scrape_session_datetime(raw_detail)
        )
        # print(event.location)

    update_database(db, cfa_events, table_name)

    print("Event Scraping has completed")


main("new_events", "20241216")
