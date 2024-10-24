import re
import requests
from datetime import datetime
import hashlib

from dataclasses import dataclass, field
from typing import List, Optional, Tuple

import firebase_admin
from firebase_admin import credentials, firestore

from bs4 import BeautifulSoup
import pytz
from urllib.parse import urlparse, parse_qs


@dataclass
class CFAEvent:
    event_id: str = ""
    event_id_hex: str = ""
    title: Optional[str] = ""
    description: Optional[str] = ""
    categories: List[str] = field(default_factory=list)
    location: Optional[str] = ""
    photo: Optional[str] = ""
    points: int = 0  # Default points to 0
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    event_url: Optional[str] = ""
    detail_url: Optional[str] = ""

    def to_dict_with_empty_users(self) -> dict:
        return {
            "eventID": self.event_id,
            "eventTitle": self.title,
            "eventCategories": self.categories,
            "eventLocation": self.location,
            "eventStartTime": self.start_time,
            "eventEndTime": self.end_time,
            "eventURL": self.event_url,
            "eventDescription": self.description,
            "eventPhoto": self.photo,
            "eventPoints": 30,
            "savedUsers": [],
        }
        
    def to_dict(self) -> dict:
        return {
            "eventID": self.event_id,
            "eventTitle": self.title,
            "eventCategories": self.categories,
            "eventLocation": self.location,
            "eventStartTime": self.start_time,
            "eventEndTime": self.end_time,
            "eventURL": self.event_url,
            "eventDescription": self.description,
            "eventPhoto": self.photo,
            "eventPoints": 30,
        }

    def write_event_id_hex(self):
        hash_object = hashlib.sha256()

        # Encode the event_id and update the hash object
        str_combined = f"{self.event_id}{self.start_time}"
        hash_object.update(str_combined.encode('utf-8'))

        # Get the hexadecimal representation of the hash
        self.event_id_hex = hash_object.hexdigest()

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
            event_topics = raw_topic_span.find_all("span", class_="bulp-event-topic-text")
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


def scrape_event_datetime(
    raw_event: str,
) -> Tuple[datetime, datetime] | Tuple[None, None]:
    raw_when_span = raw_event.find("span", class_="bulp-event-when")

    def parse_date(html: str) -> str | None:
        try:
            raw_date = html.find("span", class_="bulp-event-meta-date")
            event_days_of_week = raw_date.find(class_="bulp-event-day")
            event_month = raw_date.find(class_="bulp-event-month")
            event_day = raw_date.find(class_="bulp-event-date")
            event_date = (
                f"{event_days_of_week.text} {event_month.text} {event_day.text}"
            )
            return event_date
        except Exception as e:
            print("parse_date:", e)
            return None

    def parse_time(html: str) -> Tuple[str, str] | Tuple[None, None]:
        try:
            raw_time: str = (
                html.find("span", class_="bulp-event-meta-time")
                .find("span", class_="bulp-event-time")
                .text.strip()
            )
            if raw_time.lower() == "all day":
                return "12:00am", "11:59pm"
            start_time, end_time = (time.strip() for time in raw_time.split("-"))
            return start_time, end_time
        except Exception as e:
            print("parse_time:", e)
            return None, None

    def parse_daytime_range(
        start_daytime: str, end_daytime: str
    ) -> Tuple[datetime, datetime] | Tuple[None, None]:
        boston_tz = pytz.timezone("America/New_York")
        cur_time = datetime.now(boston_tz)
        cur_month = cur_time.month
        cur_year = cur_time.year

        def parse_daytime(date_str: str) -> datetime | None:
            try:
                # Remove ordinal suffixes (e.g., '12th' -> '12')
                cleaned_date_str = re.sub(r"(\d+)(st|nd|rd|th)", r"\1", date_str)
                parsed_date = datetime.strptime(cleaned_date_str, "%A %b %d %I:%M%p")
                return boston_tz.localize(parsed_date)
            except Exception as e:
                print("parse_daytime:", e)
                return None

        try:
            start = parse_daytime(start_daytime)
            end = parse_daytime(end_daytime)
            if start is None or end is None:
                print("empty daytime")
                return start, end

            # Adjust the year based on the current month
            if start.month >= cur_month:
                start = start.replace(year=cur_year)
            else:
                start = start.replace(year=cur_year + 1)

            if end.month >= cur_month:
                end = end.replace(year=cur_year)
            else:
                end = end.replace(year=cur_year + 1)

            return start, end
        except Exception as e:
            print("parse_daytime_range:", e)
            return None, None

    # find date
    event_date = parse_date(raw_when_span)
    start_time, end_time = parse_time(raw_when_span)

    start_daytime = f"{event_date} {start_time}"
    end_daytime = f"{event_date} {end_time}"
    return parse_daytime_range(start_daytime, end_daytime)


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
            return None, None
        a_tag = span.find("a", class_="bulp-event-readmore")
        href = a_tag["href"]

        parsed_url = urlparse(href)
        query_params = parse_qs(parsed_url.query)
        eid = query_params.get("eid", [None])[0]
        return f"https://www.bu.edu{href}", eid
    except:
        return None, None


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


def main(table_name: str):
    cred = credentials.Certificate("../serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    
    print("Starting scraper")

    url = "https://www.bu.edu/cfa/news/bu-arts-initiative/"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, "html.parser")

    raw_events = scrape_raw_events(soup)
    cfa_events: list[CFAEvent] = []
    # Iterate through each slick-slide and extract content
    for raw_event in raw_events:
        try:
            cfa_event = CFAEvent()
            raw_event = raw_event.find(
                "div", class_=lambda x: x and "bulp-item-content" in x
            )
            cfa_event.categories = scrape_event_categories(raw_event)
            cfa_event.title = scrape_event_title(raw_event)

            cfa_event.start_time, cfa_event.end_time = scrape_event_datetime(raw_event)
            cfa_event.location = scrape_event_location(raw_event)
            cfa_event.detail_url, cfa_event.event_id = scrape_event_detail_link(
                raw_event
            )
            cfa_event.write_event_id_hex()

            cfa_events.append(cfa_event)
        except Exception as e:
            print(f"Error extracting slide data: {e}")

    for _, event in enumerate(cfa_events):
        if not event.detail_url:
            continue
        response = requests.get(event.detail_url)
        soup = BeautifulSoup(response.content, "html.parser")
        raw_detail = scrape_detail_page(soup)

        event.photo = scrape_event_image(raw_detail)
        event.description = scrape_event_description(raw_detail)
        event.event_url = scrape_event_event_link(raw_detail)

    # update firebase db
    for i, event in enumerate(cfa_events):
        
        doc_ref = db.collection(table_name).document(event.event_id_hex)
    
        if doc_ref.get().exists:
            print(f"Updating event with pk {event.event_id_hex} in db")
            doc_ref.set(event.to_dict(), merge=True)
        else:
            print(f"Adding event with pk {event.event_id_hex} in db")
            doc_ref.set(event.to_dict_with_empty_users())
    print("Event Scraping has completed")

main("test_events")
