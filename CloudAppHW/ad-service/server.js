const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3002;

// Database Configuration
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'travel_db',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

// Initialize Database Table and Seed Data
async function initDB() {
    try {
        const connection = await pool.getConnection();
        console.log('Connected to MySQL DB');

        // Create table if not exists
        await connection.query(`
      CREATE TABLE IF NOT EXISTS destination_ads (
        id INT AUTO_INCREMENT PRIMARY KEY,
        destination VARCHAR(255) NOT NULL,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        external_url VARCHAR(500),
        discount_code VARCHAR(50),
        image_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

        // Check if data exists
        const [rows] = await connection.query('SELECT COUNT(*) as count FROM destination_ads');
        if (rows[0].count > 0) {
            console.log('Data exists, skipping seed.');
            connection.release();
            return;
        }

        console.log('Seeding initial ad data...');
        const seedData = [
            ['Kyoto', 'Traditional Kimono Rental', 'Experience the beauty of Kyoto in a traditional Kimono.', 'https://www.yumeyakata.com/english/', 'CLOUDKIMONO10', 'https://images.unsplash.com/photo-1493976040375-85c17d2f5082?auto=format&fit=crop&q=80&w=600'],
            ['Kyoto', 'Authentic Matcha Ceremony', 'Learn the art of tea ceremony from a tea master in Gion.', 'https://www.tea-ceremony-kyoto.com/', 'TEATIME20', 'https://images.unsplash.com/photo-1545529468-42764ef8c85f?auto=format&fit=crop&q=80&w=600'],
            ['Tokyo', 'Tokyo Skytree Fast Track', 'Skip the line and enjoy the best view of Tokyo.', 'https://www.tokyo-skytree.jp/en/', 'SKYHIGH5', 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&q=80&w=600'],
            ['Paris', 'Seine River Dinner Cruise', 'Romantic dinner cruise with live music.', 'https://www.bateauxparisiens.com/en/dinner-cruises.html', 'AMOURPARIS', 'https://images.unsplash.com/photo-1431274172761-fca41d930114?auto=format&fit=crop&q=80&w=600'],
            ['London', 'London Eye Private Capsule', 'Exclusive private capsule for your group.', 'https://www.londoneye.com/', 'LONDONEYE15', 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?auto=format&fit=crop&q=80&w=600'],
            ['New York', 'Broadway Show Tickets', 'Get last minute tickets to top Broadway shows.', 'https://www.broadway.com/', 'BROADWAYDEAL', 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?auto=format&fit=crop&q=80&w=600'],
            ['Kenting', 'Kenting Snorkeling Adventure', 'Explore vibrant coral reefs in Kenting.', 'https://www.kenting-snorkeling.com.tw/', 'REEFPLAY10', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=600'],
            ['Kenting', 'Sail Rock Sunrise Tour', 'Watch the sunrise at Kenting’s iconic Sail Rock.', 'https://www.kenting-resort.com.tw/', 'SUNRISE88', 'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&q=80&w=600'],
            ['Taitung', 'Sanxiantai Sunrise Tour', 'Catch the magical sunrise at Sanxiantai Arch Bridge.', 'https://www.eastcoast-nsa.gov.tw/en/attractions/detail/21', 'EASTCOAST15', 'https://images.unsplash.com/photo-1603354350317-6f7aaa5911c5?auto=format&fit=crop&q=80&w=600'],
            ['Taitung', 'Luye Hot Air Balloon Experience', 'Soar above Taitung in a hot air balloon.', 'https://balloontaiwan.taitung.gov.tw/en', 'FLYTAITUNG', 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&q=80&w=600']
        ];

        for (const ad of seedData) {
            await connection.query(
                'INSERT INTO destination_ads (destination, title, description, external_url, discount_code, image_url) VALUES (?, ?, ?, ?, ?, ?)',
                ad
            );
        }
        console.log('Seeding completed.');

        connection.release();
    } catch (err) {
        console.error('Database initialization failed:', err);
    }
}

// API Routes

// Health Check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', service: 'ad-service' });
});

// Get Ads by Destination (or all)
app.get('/api/ads', async (req, res) => {
    try {
        const { destination } = req.query;
        let query = 'SELECT * FROM destination_ads';
        let params = [];

        if (destination) {
            query += ' WHERE destination LIKE ?';
            params.push(`%${destination}%`);
        }

        query += ' ORDER BY created_at DESC';

        const [rows] = await pool.execute(query, params);
        res.json(rows);
    } catch (err) {
        console.error('Error fetching ads:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Get Single Ad
app.get('/api/ads/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [rows] = await pool.execute('SELECT * FROM destination_ads WHERE id = ?', [id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Ad not found' });
        res.json(rows[0]);
    } catch (err) {
        console.error('Error fetching ad:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Create Ad
app.post('/api/ads', async (req, res) => {
    try {
        const { destination, title, description, external_url, discount_code, image_url } = req.body;
        if (!destination || !title) return res.status(400).json({ error: 'Missing required fields' });

        const [result] = await pool.execute(
            'INSERT INTO destination_ads (destination, title, description, external_url, discount_code, image_url) VALUES (?, ?, ?, ?, ?, ?)',
            [destination, title, description || '', external_url || '', discount_code || '', image_url || '']
        );
        res.status(201).json({ id: result.insertId, message: 'Ad created' });
    } catch (err) {
        console.error('Error creating ad:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Update Ad
app.put('/api/ads/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { destination, title, description, external_url, discount_code, image_url } = req.body;

        const [result] = await pool.execute(
            'UPDATE destination_ads SET destination=?, title=?, description=?, external_url=?, discount_code=?, image_url=? WHERE id=?',
            [destination, title, description, external_url, discount_code, image_url, id]
        );
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Ad not found' });
        res.json({ message: 'Ad updated' });
    } catch (err) {
        console.error('Error updating ad:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Delete Ad
app.delete('/api/ads/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [result] = await pool.execute('DELETE FROM destination_ads WHERE id = ?', [id]);
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Ad not found' });
        res.json({ message: 'Ad deleted' });
    } catch (err) {
        console.error('Error deleting ad:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// Start Server
app.listen(PORT, async () => {
    await initDB();
    console.log(`Ad Service running on port ${PORT}`);
});
