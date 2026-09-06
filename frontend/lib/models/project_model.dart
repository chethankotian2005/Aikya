/// Data model for student ML projects.
class ProjectModel {
  final String id;
  final String title;
  final String author;
  final String imageAsset;
  final List<String> tags;
  final bool lookingForTeammate;
  final double imageHeightMultiplier; // To simulate varying masonry heights

  const ProjectModel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageAsset,
    required this.tags,
    this.lookingForTeammate = false,
    this.imageHeightMultiplier = 1.0,
  });
}

// ─── Sample Data ────────────────────────────────────────────────────

final List<ProjectModel> sampleProjects = [
  const ProjectModel(
    id: 'p1',
    title: 'Automated Brain Tumor Segmentation',
    author: 'Neha R.',
    imageAsset: 'assets/images/proj_medical.jpg',
    tags: ['PyTorch', 'U-Net', 'Medical'],
    lookingForTeammate: true,
    imageHeightMultiplier: 1.2,
  ),
  const ProjectModel(
    id: 'p2',
    title: 'Aerial Traffic Monitoring Drone',
    author: 'Rahul K.',
    imageAsset: 'assets/images/proj_drone.jpg',
    tags: ['OpenCV', 'YOLOv8', 'Edge AI'],
    lookingForTeammate: false,
    imageHeightMultiplier: 0.8,
  ),
  const ProjectModel(
    id: 'p3',
    title: 'High-Frequency Trading Predictor',
    author: 'Aditi V.',
    imageAsset: 'assets/images/proj_stock.jpg',
    tags: ['TensorFlow', 'LSTM', 'Finance'],
    lookingForTeammate: true,
    imageHeightMultiplier: 1.4,
  ),
  const ProjectModel(
    id: 'p4',
    title: 'Robotic Arm Grasping via RL',
    author: 'Vikram S.',
    imageAsset: 'assets/images/proj_robot.jpg',
    tags: ['RL', 'OpenAI Gym', 'Robotics'],
    lookingForTeammate: false,
    imageHeightMultiplier: 1.0,
  ),
  const ProjectModel(
    id: 'p5',
    title: 'Real-time ASL Translator app',
    author: 'Sneha P.',
    imageAsset: 'assets/images/event_workshop.jpg', // placeholder
    tags: ['MediaPipe', 'Flutter', 'TFLite'],
    lookingForTeammate: true,
    imageHeightMultiplier: 0.9,
  ),
  const ProjectModel(
    id: 'p6',
    title: 'Crop Disease Classifier',
    author: 'Karthik N.',
    imageAsset: 'assets/images/event_seminar.jpg', // placeholder
    tags: ['Keras', 'ResNet50', 'AgriTech'],
    lookingForTeammate: false,
    imageHeightMultiplier: 1.1,
  ),
];
