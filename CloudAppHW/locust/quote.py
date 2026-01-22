import logging
from locust import HttpUser, task, between
from datetime import datetime, timedelta
import random
import uuid

logging.basicConfig(level=logging.INFO)

class MyUser(HttpUser):
    wait_time = between(1, 3)

    def get_random_dates(self):
        start_offset = random.randint(1, 180)
        stay_length = random.randint(3, 14)
        start_date = datetime.now() + timedelta(days=start_offset)
        end_date = start_date + timedelta(days=stay_length)
        return start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")

    @task(1)
    def index(self):
        self.client.get("/")

    @task(0)
    def post_quote(self):
        start_date, end_date = self.get_random_dates()
        payload = {
            "paxList": {
                "numAdults": random.randint(1, 4),
                "childAges": [random.randint(2, 12) for _ in range(random.randint(0, 3))]
            },
            "startDate": start_date,
            "endDate": end_date
        }
        self.client.post(
            "/api/bookingProcess/quote",
            json=payload,
            headers={"Content-Type": "application/json"}
        )

    @task(2)
    def post_book(self):
        start_date, end_date = self.get_random_dates()
        payload = {
            "occupancy": {
                "startDate": start_date,
                "endDate": end_date,
                "paxList": {
                    "numAdults": random.randint(1, 4),
                    "childAges": [random.randint(2, 12) for _ in range(random.randint(0, 3))]
                }
            },
            "customer": {
                "firstName": "John",
                "lastName": "Doe",
                "email": f"john{random.randint(1,10000)}@example.com"
            }
        }
        logging.info(f"Book request payload: {payload}")
        response = self.client.post(
            "/api/bookingProcess/book",
            json=payload,
            headers={"Content-Type": "application/json"}
        )
        logging.info(f"Book response status: {response.status_code}")
        logging.info(f"Book response body: {response.text}")

    @task(0)
    def get_booking(self):
        booking_id = random.randint(1, 100)
        logging.info(f"Show booking request for ID: {booking_id}")
        response = self.client.get(f"/api/booking/{booking_id}")
        logging.info(f"Show booking response status: {response.status_code}")
        logging.info(f"Show booking response body: {response.text}")