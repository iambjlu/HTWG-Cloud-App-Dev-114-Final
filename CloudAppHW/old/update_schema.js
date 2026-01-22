require('dotenv').config();
const mysql = require('mysql2/promise');

async function main() {
    console.log('Connecting to database...');
    console.log(`Host: ${process.env.DB_HOST}`);
    console.log(`User: ${process.env.DB_USER}`);

    let connection;
    try {
        connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME,
            port: process.env.DB_PORT || 3306
        });

        console.log('Connected.');

        // 1. Check/Add membership_tier
        const [columns] = await connection.execute("SHOW COLUMNS FROM travellers LIKE 'membership_tier'");
        if (columns.length === 0) {
            console.log('Adding membership_tier column...');
            await connection.execute("ALTER TABLE travellers ADD COLUMN membership_tier VARCHAR(50) DEFAULT 'Free'");
        } else {
            console.log('membership_tier column exists.');
        }

        // 2. Check/Add is_admin
        const [adminCols] = await connection.execute("SHOW COLUMNS FROM travellers LIKE 'is_admin'");
        if (adminCols.length === 0) {
            console.log('Adding is_admin column...');
            await connection.execute("ALTER TABLE travellers ADD COLUMN is_admin BOOLEAN DEFAULT FALSE");
        } else {
            console.log('is_admin column exists.');
        }

        // 3. Set Admin for specific user
        const targetEmail = '1150118@gmail.com';
        console.log(`Setting admin privileges for ${targetEmail}...`);

        // Check if user exists
        const [userRes] = await connection.execute('SELECT id FROM travellers WHERE email = ?', [targetEmail]);
        if (userRes.length === 0) {
            console.log(`User ${targetEmail} not found in DB. Inserting placeholder so they are Admin on first login...`);
            // If your app logic allows 'ensuring' users later with same email, we can pre-seed it.
            // Based on server.js: INSERT INTO travellers (email, name) ...
            await connection.execute('INSERT INTO travellers (email, name, membership_tier, is_admin) VALUES (?, ?, ?, ?)',
                [targetEmail, 'Admin', 'Premium', true]);
            console.log(`Created new Admin user: ${targetEmail}`);
        } else {
            await connection.execute('UPDATE travellers SET is_admin = TRUE, membership_tier = "Premium" WHERE email = ?', [targetEmail]);
            console.log(`Updated existing user ${targetEmail} to Admin + Premium.`);
        }

        console.log('Database update complete.');

    } catch (err) {
        console.error('Error performing database update:', err);
        process.exit(1);
    } finally {
        if (connection) await connection.end();
    }
}

main();
