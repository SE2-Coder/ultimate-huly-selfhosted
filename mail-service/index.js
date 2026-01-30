const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Logger middleware
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Auth middleware
const checkAuth = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    // The account service sends "Bearer <token>"
    // We need to match this against our API_KEY env var

    if (!authHeader) {
        console.warn('Missing Authorization header');
        return res.status(401).json({ error: 'Missing Authorization header' });
    }

    const token = authHeader.split(' ')[1]; // Bearer <token>
    const expectedKey = process.env.API_KEY;

    if (!token || token !== expectedKey) {
        console.warn('Invalid token provided');
        return res.status(403).json({ error: 'Invalid authentication token' });
    }

    next();
};

const createTransporter = () => {
    // Check required env vars
    const required = ['SMTP_HOST', 'SMTP_PORT', 'SMTP_USER', 'SMTP_PASSWORD'];
    const missing = required.filter(key => !process.env[key]);

    if (missing.length > 0) {
        throw new Error(`Missing SMTP configuration: ${missing.join(', ')}`);
    }

    const config = {
        host: process.env.SMTP_HOST,
        port: parseInt(process.env.SMTP_PORT, 10),
        secure: process.env.SMTP_TLS_MODE === 'secure', // true for 465, false for other ports
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASSWORD
        },
        tls: {
            // Do not fail on invalid certs
            rejectUnauthorized: false
        },
        debug: true,
        logger: true
    };

    console.log('SMTP Config:', {
        host: config.host,
        port: config.port,
        secure: config.secure,
        user: config.auth.user
    });

    return nodemailer.createTransport(config);
};

app.get('/health', (req, res) => {
    res.json({ status: 'ok', time: new Date().toISOString() });
});

app.post('/send', checkAuth, async (req, res) => {
    try {
        console.log('Received send request payload:', JSON.stringify(req.body, null, 2));

        const { to, subject, html, text, from } = req.body;

        if (!to || !subject) {
            return res.status(400).json({ error: 'Missing required fields: to, subject' });
        }

        const transporter = createTransporter();

        const fromAddress = from || process.env.SMTP_SOURCE || process.env.SMTP_USER;
        console.log('Using from address:', fromAddress);



        const mailOptions = {
            from: from || process.env.SMTP_SOURCE || process.env.SMTP_USER,
            to,
            subject,
            text,
            html
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('Message sent: %s', info.messageId);

        res.json({ status: 'ok', messageId: info.messageId });

    } catch (error) {
        console.error('Error sending email:', error);
        res.status(500).json({
            error: 'Failed to send email',
            details: error.message
        });
    }
});

app.listen(port, () => {
    console.log(`Mail service listening at http://0.0.0.0:${port}`);
    console.log('Environment:', {
        PORT: port,
        SMTP_HOST: process.env.SMTP_HOST,
        SMTP_PORT: process.env.SMTP_PORT,
        SMTP_USER: process.env.SMTP_USER,
        SMTP_PASSWORD: process.env.SMTP_PASSWORD ? '********' : 'NOT SET',
        SMTP_TLS_MODE: process.env.SMTP_TLS_MODE,
        SMTP_SOURCE: process.env.SMTP_SOURCE,
        API_KEY_SET: !!process.env.API_KEY
    });
});
