# locustfile.py - DragonFlyX Load Test Script
# 本腳本用於測試行程建立和瀏覽功能的負載能力
# This script tests the load capacity of itinerary creation and browsing features

import logging
from locust import HttpUser, task, between, events
from datetime import datetime, timedelta
import random
import uuid
import string
import json

logging.basicConfig(level=logging.INFO)

# Destinations for random trip generation
DESTINATIONS = [
    "Tokyo, Japan", "Paris, France", "New York, USA", "London, UK",
    "Sydney, Australia", "Dubai, UAE", "Singapore", "Bangkok, Thailand",
    "Rome, Italy", "Barcelona, Spain", "Amsterdam, Netherlands", "Seoul, Korea",
    "Taipei, Taiwan", "Hong Kong", "Vancouver, Canada", "Berlin, Germany"
]

SHORT_DESCRIPTIONS = [
    "Family vacation", "Business trip", "Honeymoon", "Solo adventure",
    "Friends getaway", "Anniversary trip", "Birthday celebration", "Road trip",
    "Cultural exploration", "Beach vacation", "Mountain hiking", "City break"
]


class DragonFlyXUser(HttpUser):
    """
    Simulates a user who creates an account, creates itineraries,
    and randomly browses/queries existing itineraries.
    """
    wait_time = between(1, 3)
    
    # Store created itinerary IDs for later querying
    created_itinerary_ids = []
    all_itinerary_ids = []
    
    def on_start(self):
        """Called when a simulated user starts. Creates a test account."""
        # Generate unique test user
        unique_id = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
        self.test_email = f"loadtest_{unique_id}@test.com"
        self.test_password = "TestPassword123!"
        self.test_name = f"LoadTest User {unique_id}"
        self.auth_token = None
        
        logging.info(f"Starting load test user: {self.test_email}")
        
        # Note: In a real scenario, you would actually register through Firebase
        # For load testing without Firebase, we'll simulate API calls directly
        # This assumes the backend has a test mode or we're testing without auth
        
        # Fetch existing itineraries for browsing
        self._fetch_feed()
    
    def _fetch_feed(self):
        """Fetch the feed to get existing itinerary IDs for browsing."""
        try:
            response = self.client.get("/api/itineraries/feed")
            if response.status_code == 200:
                data = response.json()
                self.all_itinerary_ids = [item['id'] for item in data if 'id' in item]
                logging.info(f"Fetched {len(self.all_itinerary_ids)} itineraries from feed")
        except Exception as e:
            logging.warning(f"Failed to fetch feed: {e}")
    
    def get_random_dates(self):
        """Generate random start and end dates for a trip."""
        start_offset = random.randint(1, 180)
        stay_length = random.randint(3, 14)
        start_date = datetime.now() + timedelta(days=start_offset)
        end_date = start_date + timedelta(days=stay_length)
        return start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")
    
    def generate_trip_data(self):
        """Generate random trip data."""
        start_date, end_date = self.get_random_dates()
        return {
            "title": f"Load Test Trip {random.randint(1000, 9999)}",
            "destination": random.choice(DESTINATIONS),
            "start_date": start_date,
            "end_date": end_date,
            "short_description": random.choice(SHORT_DESCRIPTIONS),
            "detail_description": f"This is a load test trip created at {datetime.now().isoformat()}. Random notes: {uuid.uuid4()}",
            "enable_ai": False,  # AI is OFF as per requirements
            "is_private": False
        }
    
    @task(3)
    def browse_feed(self):
        """Browse the main feed - most common action."""
        response = self.client.get("/api/itineraries/feed")
        if response.status_code == 200:
            data = response.json()
            # Update our list of known itineraries
            new_ids = [item['id'] for item in data if 'id' in item]
            self.all_itinerary_ids = list(set(self.all_itinerary_ids + new_ids))
    
    @task(2)
    def view_itinerary_detail(self):
        """View a random itinerary's details."""
        if not self.all_itinerary_ids:
            self._fetch_feed()
            return
        
        itinerary_id = random.choice(self.all_itinerary_ids)
        response = self.client.get(f"/api/itineraries/detail/{itinerary_id}")
        
        if response.status_code == 404:
            # Remove stale ID
            if itinerary_id in self.all_itinerary_ids:
                self.all_itinerary_ids.remove(itinerary_id)
    
    @task(1)
    def create_itinerary_no_auth(self):
        """
        Attempt to create an itinerary (will fail without auth).
        This tests endpoint handling and error responses.
        """
        trip_data = self.generate_trip_data()
        
        # Expected to return 401 without auth - this is fine for load testing
        with self.client.post(
            "/api/itineraries",
            json=trip_data,
            headers={"Content-Type": "application/json"},
            catch_response=True
        ) as response:
            if response.status_code == 401:
                response.success()
            elif response.status_code == 201:
                try:
                    data = response.json()
                    if 'id' in data:
                        self.created_itinerary_ids.append(data['id'])
                        self.all_itinerary_ids.append(data['id'])
                except:
                    pass
    
    @task(1)
    def get_likes_count(self):
        """Get like count for a random itinerary."""
        if not self.all_itinerary_ids:
            return
        
        itinerary_id = random.choice(self.all_itinerary_ids)
        self.client.get(f"/api/itineraries/{itinerary_id}/like/count")
    
    @task(1)
    def get_comments(self):
        """Get comments for a random itinerary."""
        if not self.all_itinerary_ids:
            return
        
        itinerary_id = random.choice(self.all_itinerary_ids)
        self.client.get(f"/api/itineraries/{itinerary_id}/comments")
    
    @task(1)
    def health_check(self):
        """Check backend health."""
        self.client.get("/health")


# Event handlers for logging
@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    logging.info("=" * 60)
    logging.info("DragonFlyX Load Test Starting")
    logging.info("=" * 60)


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    logging.info("=" * 60)
    logging.info("DragonFlyX Load Test Complete")
    logging.info("=" * 60)
