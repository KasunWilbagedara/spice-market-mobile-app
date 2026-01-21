import { onRequest, onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import cors from 'cors';
import { Request, Response } from 'express';

// Initialize Firebase Admin SDK
admin.initializeApp();

const bucket = admin.storage().bucket();

// CORS middleware - allow requests from localhost and production
// CORS middleware - allow requests from localhost and production
const corsHandler = cors({
  origin: [
    'http://localhost:1843',
    'http://localhost:7561',
    'http://127.0.0.1:1843',
    'http://127.0.0.1:7561',
    'https://spice-market-49a7b.web.app',
    'https://spice-market-49a7b.firebaseapp.com'
  ],
  methods: ['POST', 'OPTIONS', 'GET'],
  credentials: true,
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 3600
});

/**
 * Cloud Function to handle spice image uploads
 * Accepts multipart/form-data with image file and spiceId
 * Returns download URL for the uploaded image
 */
export const uploadSpiceImage = onRequest(
  { cors: true },
  async (req: Request, res: Response) => {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
      res.set('Access-Control-Allow-Origin', '*');
      res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
      res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      // Verify user is authenticated
      const auth = req.headers.authorization;
      if (!auth) {
        res.status(401).json({ error: 'Unauthorized: Missing authorization header' });
        return;
      }

      // Verify Firebase token
      let decodedToken;
      try {
        const token = auth.replace('Bearer ', '');
        decodedToken = await admin.auth().verifyIdToken(token);
      } catch (error) {
        logger.error('Token verification failed:', error);
        res.status(401).json({ error: 'Unauthorized: Invalid token' });
        return;
      }

      const userId = decodedToken.uid;
      logger.info(`Upload request from user: ${userId}`);

      // Get spice ID and image data from request
      const { spiceId, imageName, imageData } = req.body;

      if (!spiceId || !imageName || !imageData) {
        res.status(400).json({
          error: 'Missing required fields: spiceId, imageName, imageData'
        });
        return;
      }

      // Decode base64 image data
      let imageBuffer;
      try {
        imageBuffer = Buffer.from(imageData, 'base64');
      } catch (error) {
        res.status(400).json({ error: 'Invalid image data format' });
        return;
      }

      // Create unique filename
      const timestamp = Date.now();
      const fileName = `spices/${spiceId}/${timestamp}_${imageName}`;

      logger.info(`Uploading image: ${fileName} (${imageBuffer.length} bytes)`);

      // Upload to Firebase Storage
      const file = bucket.file(fileName);
      
      await file.save(imageBuffer, {
        metadata: {
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=86400',
          metadata: {
            'uploaded-by': userId,
            'uploaded-at': new Date().toISOString(),
            'original-name': imageName
          }
        }
      });

      logger.info(`Image uploaded successfully: ${fileName}`);

      // Get download URL
      const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(fileName)}?alt=media`;

      logger.info(`Download URL: ${downloadUrl}`);

      // Send success response
      res.status(200).json({
        success: true,
        downloadUrl,
        fileName,
        size: imageBuffer.length,
        message: 'Image uploaded successfully'
      });

    } catch (error) {
      logger.error('Upload failed:', error);
      res.status(500).json({
        error: 'Upload failed',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
);

/**
 * Cloud Function to get download URL for a specific file
 * This can be used to verify if a file exists
 */
export const getImageUrl = onCall(
  { cors: true },
  async (request) => {
    const { fileName } = request.data;

    if (!fileName) {
      throw new HttpsError(
        'invalid-argument',
        'Missing fileName parameter'
      );
    }

    try {
      const file = bucket.file(fileName);
      const exists = (await file.exists())[0];

      if (!exists) {
        throw new HttpsError(
          'not-found',
          'File not found'
        );
      }

      const downloadUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(fileName)}?alt=media`;

      return {
        success: true,
        downloadUrl,
        fileName
      };
    } catch (error) {
      logger.error('Get URL failed:', error);
      throw new HttpsError(
        'internal',
        'Failed to get image URL',
        error instanceof Error ? error.message : 'Unknown error'
      );
    }
  }
);
