import { v2 as cloudinary } from 'cloudinary';

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

/** Per-surface size caps, applied at upload time so Cloudinary never stores or serves the original. */
export const UPLOAD_FOLDERS = {
  profile_pictures: { maxWidth: 400, maxHeight: 400, crop: 'fill', gravity: 'face' },
  event_banners: { maxWidth: 800, crop: 'limit' },
  memory_frame: { maxWidth: 1200, crop: 'limit' },
  project_images: { maxWidth: 1200, crop: 'limit' },
};

/** Uploads a buffer to Cloudinary under aikya/{folder}/{uid} with the folder's size cap + auto quality/format. */
export function uploadToCloudinary(buffer, { folder, uid }) {
  const preset = UPLOAD_FOLDERS[folder];
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: `aikya/${folder}/${uid}`,
        resource_type: 'image',
        transformation: [
          { width: preset.maxWidth, height: preset.maxHeight, crop: preset.crop, gravity: preset.gravity },
          { quality: 'auto', fetch_format: 'auto' },
        ],
      },
      (error, result) => (error ? reject(error) : resolve(result)),
    );
    stream.end(buffer);
  });
}

/** Uploads a non-image buffer (e.g. a generated PDF) as a raw Cloudinary asset. */
export function uploadRawToCloudinary(buffer, { folder, publicId }) {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder, public_id: publicId, resource_type: 'raw' },
      (error, result) => (error ? reject(error) : resolve(result)),
    );
    stream.end(buffer);
  });
}

export default cloudinary;
