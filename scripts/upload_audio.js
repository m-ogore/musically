const { initializeApp, cert } = require('firebase-admin/app');
const { getStorage } = require('firebase-admin/storage');
const fs = require('fs');
const path = require('path');

// Make sure to replace this with your actual downloaded JSON key file path!
const serviceAccount = require('./service-account-key.json');

initializeApp({
  credential: cert(serviceAccount),
  // Replace with your Firebase project bucket name
  storageBucket: 'music-app-5bf18.firebasestorage.app'
});

const bucket = getStorage().bucket();

async function uploadDirectory(directoryPath, prefix = '') {
  const items = fs.readdirSync(directoryPath);
  
  for (const item of items) {
    const fullPath = path.join(directoryPath, item);
    const stat = fs.statSync(fullPath);
    
    // The path in Firebase Storage (e.g., audio/10/soprano.mp3)
    const destinationPath = prefix ? `${prefix}/${item}` : item;
    
    if (stat.isDirectory()) {
      console.log(`Scanning directory: ${fullPath}...`);
      await uploadDirectory(fullPath, destinationPath);
    } else {
      console.log(`Uploading ${fullPath} to ${destinationPath}...`);
      try {
        await bucket.upload(fullPath, {
          destination: destinationPath,
          metadata: {
            cacheControl: 'public, max-age=31536000'
          }
        });
        console.log(`✓ Uploaded ${item}`);
      } catch (err) {
        console.error(`X Failed to upload ${item}:`, err.message);
      }
    }
  }
}

// Start the upload from the assets/audio directory
const audioDir = path.resolve(__dirname, '../assets/audio');
console.log(`Starting upload from ${audioDir}...`);

uploadDirectory(audioDir, 'audio')
  .then(() => console.log('All uploads complete!'))
  .catch((err) => console.error('Upload failed:', err));
