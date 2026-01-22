# Optimized Personalized Dynamic Feed Design

To implement a personalized dynamic feed (Personalized Wall), follow this architectural plan:

## 1. Data Collection (Behavior Tracking)
To personalize content, you need to understand user preferences.
Tracking events:
- **View**: User clicks/details an itinerary.
- **Like**: User likes an itinerary.
- **Search**: Keywords used in search.
- **Time Spent**: How long they view a detail page (optional).

**Implementation**:
- Create a `user_interactions` table/collection:
  - `user_id`, `itinerary_id`, `interaction_type` ('view', 'like'), `timestamp`.

## 2. Scoring Algorithm (The "Recommendation Engine")
Assign weights to interactions to calculate a "Relevance Score" for candidate itineraries.
Example Weights:
- Like: 5 points
- View: 1 point
- Same Destination as Last Trip: 3 points

**Simple Query Strategy (SQL)**:
```sql
SELECT i.*, 
  (COUNT(l.id) * 5) + (COUNT(v.id) * 1) AS score
FROM itineraries i
LEFT JOIN user_interactions l ON i.id = l.itinerary_id AND l.type = 'like'
LEFT JOIN user_interactions v ON i.id = v.itinerary_id AND v.type = 'view'
WHERE i.id NOT IN (SELECT itinerary_id FROM user_interactions WHERE user_id = ? AND type = 'view') -- Filter seen? Or just prioritize?
GROUP BY i.id
ORDER BY score DESC
LIMIT 20;
```

**Advanced Strategy (Vector Embeddings)**:
1. Use an AI model (like Gemini) to generate an embedding vector for each itinerary based on `description`, `destination`, `tags`.
2. Store these vectors in a vector database (e.g., Pinecone, Milvus, or pgvector).
3. Generate a user profile vector by averaging the vectors of itineraries they liked.
4. Perform a vector similarity search (Cosine Similarity) to find the closest matches.

## 3. Frontend Implementation
- create `src/components/DynamicFeed.vue`.
- Fetch `GET /api/itineraries/feed`.
- Display cards in a masonry or grid layout.
- Add "For You" badge on top recommendations.

## 4. Cold Start Problem
For new users without history:
- Show "Trending" (Most liked in last 7 days).
- Show "Newest".
- Ask for 3 favorite destinations during onboarding.
