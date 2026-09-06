/// Data model for the Photo Memory Wall.
class PhotoModel {
  final String id;
  final String imageAsset;
  final String uploaderName;
  final String caption;
  final int likes;
  final bool isPendingApproval;
  final bool isCurrentUser;
  final double heightMultiplier; // For masonry grid varying heights

  const PhotoModel({
    required this.id,
    required this.imageAsset,
    required this.uploaderName,
    required this.caption,
    this.likes = 0,
    this.isPendingApproval = false,
    this.isCurrentUser = false,
    this.heightMultiplier = 1.0,
  });
}

// ─── Sample Data ────────────────────────────────────────────────────

final List<PhotoModel> samplePhotos = [
  const PhotoModel(
    id: 'm1',
    imageAsset: 'assets/images/mem_hackathon.jpg',
    uploaderName: 'AI Dept Admin',
    caption: 'Neural Hack 2026 kicks off! 24 hours of non-stop coding. 🚀',
    likes: 124,
    heightMultiplier: 0.75,
  ),
  const PhotoModel(
    id: 'm2',
    imageAsset: 'assets/images/mem_speaker.jpg',
    uploaderName: 'Prof. Aditya K.',
    caption: 'Great turnout for the Future of GenAI seminar today.',
    likes: 89,
    heightMultiplier: 0.56,
  ),
  const PhotoModel(
    id: 'm3',
    imageAsset: 'assets/images/event_workshop.jpg',
    uploaderName: 'Sarah Jenkins',
    caption: 'Hands-on LoRA tuning was incredible! My model finally converged.',
    likes: 42,
    heightMultiplier: 1.2,
  ),
  const PhotoModel(
    id: 'm4',
    imageAsset: 'assets/images/proj_robot.jpg',
    uploaderName: 'Chethan Kotian',
    caption: 'Sneak peek at my RL grasping simulation for the final year project.',
    likes: 0,
    isPendingApproval: true,
    isCurrentUser: true,
    heightMultiplier: 1.0,
  ),
  const PhotoModel(
    id: 'm5',
    imageAsset: 'assets/images/event_hackathon.jpg',
    uploaderName: 'AI Dept Admin',
    caption: 'Winners of the Neural Hack! Huge congratulations to team TensorBros.',
    likes: 210,
    heightMultiplier: 1.4,
  ),
  const PhotoModel(
    id: 'm6',
    imageAsset: 'assets/images/proj_drone.jpg',
    uploaderName: 'Rahul K.',
    caption: 'Testing the drone CV tracking on campus. Looking good! 🚁',
    likes: 67,
    heightMultiplier: 0.56,
  ),
];
