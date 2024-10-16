import datetime
from datetime import datetime

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
import firebase_admin
from firebase_admin import credentials,firestore

cred = credentials.Certificate("/Users/saisriram/Desktop/BUPassport/serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


import time
import hashlib
import random

event_photos = [
    'image1',
    'image2',
    'image3',
    'image4',
    'image5',
    'image6',
    'image7',
    'image8',
    'image9',
    'image10'
]

service = Service(executable_path='/Users/saisriram/Desktop/BUPassport/chromedriver')
driver = webdriver.Chrome(service=service)

driver.get('https://www.bu.edu/arts/calendar/')

WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.CLASS_NAME, 'event-link')))

eventLinks = driver.find_elements(By.CLASS_NAME, 'event-link')

for eventLink in eventLinks:
    # generate a random number between 0 and 9
    random_number = random.randint(0, 9)

    random_image = event_photos[random_number]

    eventPhoto = f"assets/images/arts/{random_image}.jpeg"

    event_title_element = eventLink.find_element(By.CSS_SELECTOR, '.event-link a')
    eventTitle = event_title_element.text.strip()
    print(eventTitle)
    event_url = event_title_element.get_attribute('href')
    print(event_url)
    driver.get(event_url)    


    WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.CLASS_NAME, 'eventDetail')))

    try:
        event_detail = driver.find_element(By.CLASS_NAME, 'eventDetail')
        
        try:
            event_tabular = event_detail.find_element(By.CLASS_NAME, 'tabular')
            try:
                eventStartTime = event_tabular.find_element(By.XPATH, './dt[text()="Starts:"]/following-sibling::dd').text
                print("Starts:", eventStartTime)
            except NoSuchElementException:
                # set to start of month
                eventStartTime = "12:00 AM on " + datetime.now().strftime('%A, %B 1, %Y')
                print(eventStartTime)
                print("Starts: Not provided")

            try:
                eventEndTime = event_detail.find_element(By.XPATH, '//dt[text()="Ends:"]/following-sibling::dd').text
                print("Ends:", eventEndTime)
            except NoSuchElementException:
                # set to end of month
                eventEndTime = "11:59 PM on " + datetime.now().strftime('%A, %B 28, %Y')
                print(eventEndTime)
                print("Ends: Not provided")
            
            try:
                eventURL = event_detail.find_element(By.XPATH, '//dt[text()="URL:"]/following-sibling::dd/a').get_attribute('href')
                print("URL:", eventURL)
            except NoSuchElementException:
                print("URL: Not provided")
            
            location_room_address = ''

            try:
                eventRoom = event_detail.find_element(By.XPATH, '//dt[text()="Room:"]/following-sibling::dd').text
                location_room_address += eventRoom
            except NoSuchElementException:
                pass

            try:
                eventLocation = event_detail.find_element(By.XPATH, '//dt[text()="Location:"]/following-sibling::dd').text
                if location_room_address:
                    location_room_address += ", " + eventLocation
                else:
                    location_room_address += eventLocation
            except NoSuchElementException:
                pass

            try:
                eventAddress = event_detail.find_element(By.XPATH, '//dt[text()="Address:"]/following-sibling::dd').text
                if location_room_address:
                    location_room_address += ", " + eventAddress
                else:
                    location_room_address += eventAddress
            except NoSuchElementException:
                pass

            
            # Print concatenated location, room, and address
            if location_room_address:
                print("Address " + location_room_address.strip())
            else:
                print("Location, Room, and Address: Not provided")
            
            try:
                eventDescription = event_detail.find_element(By.CLASS_NAME, 'description').text.strip()
                print("Description:", eventDescription)
            except NoSuchElementException:
                print("Description: Not provided")

            # Creating event hash based on start time and end time

            data = f"{eventTitle}_{eventStartTime}"

            eventID = hashlib.md5(data.encode()).hexdigest()
            print("Event ID:", eventID)

            # Check if eventID already exists in Firebase
            event_ref = db.collection('events').document(eventID)
            event_doc = event_ref.get()

            # parse eventStartTime and eventEndTime to datetime objects
            eventDateTimeStartTime = datetime.strptime(eventStartTime, '%I:%M %p on %A, %B %d, %Y')
            eventDateTimeEndTime = datetime.strptime(eventEndTime, '%I:%M %p on %A, %B %d, %Y')

            print("Event Start Time:", eventDateTimeStartTime)

            if event_doc.exists:
                print(f"Event with ID {eventID} already exists. Skipping...")
            else:
                event_data = {
                    'eventTitle': eventTitle if eventTitle else None,  # Assign None if title doesn't exist
                    'eventStartTime': eventDateTimeStartTime if eventStartTime else None,  # Assign None if start time doesn't exist
                    'eventEndTime': eventDateTimeEndTime if eventEndTime else None,  # Assign None if end time doesn't exist
                    'eventURL': eventURL if eventURL else None,  # Assign None if URL doesn't exist
                    'eventLocation': location_room_address if location_room_address else None,  # Assign None if location doesn't exist
                    'eventDescription': eventDescription if eventDescription else None,  # Assign None if description doesn't exist
                    'eventID': eventID if eventID else None,  # Assign None if event ID doesn't exist
                    'eventPhoto': eventPhoto if eventPhoto else None,  # Assign None if photo doesn't exist
                    'eventPoints': 30,  # Default points to 0
                    'savedUsers': [],
                }

                db.collection('events').document(eventID).set(event_data)
                
        except NoSuchElementException:
            print("Tabular section not found")

    except NoSuchElementException:
        print("Event detail section not found")

    driver.back()

time.sleep(5)

driver.quit()