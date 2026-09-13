/// Data model for student ML projects.
class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String author;
  final String ownerId;
  final List<String> contributorIds;
  final List<String> imageUrls;
  final List<String> tags;
  final bool lookingForTeammate;
  final double imageHeightMultiplier; // To simulate varying masonry heights

  const ProjectModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.author,
    required this.ownerId,
    this.contributorIds = const [],
    required this.imageUrls,
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
    description: 'A deep learning pipeline leveraging U-Net to automatically segment brain tumors from MRI scans with high precision, assisting radiologists in faster diagnosis.',
    author: 'Neha R.',
    ownerId: 'student1',
    contributorIds: ['student2'],
    imageUrls: ['assets/images/proj_medical.jpg'],
    tags: ['PyTorch', 'U-Net', 'Medical'],
    lookingForTeammate: true,
    imageHeightMultiplier: 1.2,
  ),
  const ProjectModel(
    id: 'p2',
    title: 'Aerial Traffic Monitoring Drone',
    description: 'Using computer vision models deployed on edge devices to monitor and analyze traffic patterns from drone footage in real-time.',
    author: 'Rahul K.',
    ownerId: 'student2',
    imageUrls: ['assets/images/proj_drone.jpg'],
    tags: ['OpenCV', 'YOLOv8', 'Edge AI'],
    lookingForTeammate: false,
    imageHeightMultiplier: 0.8,
  ),
  const ProjectModel(
    id: 'p3',
    title: 'High-Frequency Trading Predictor',
    description: 'An LSTM-based recurrent neural network that predicts short-term stock price movements by analyzing order book imbalances.',
    author: 'Aditi V.',
    ownerId: 'student3',
    imageUrls: ['assets/images/proj_stock.jpg'],
    tags: ['TensorFlow', 'LSTM', 'Finance'],
    lookingForTeammate: true,
    imageHeightMultiplier: 1.4,
  ),
  const ProjectModel(
    id: 'p4',
    title: 'Robotic Arm Grasping via RL',
    description: 'Training a robotic arm simulation using Proximal Policy Optimization (PPO) to grasp objects of varying shapes and sizes.',
    author: 'Vikram S.',
    ownerId: 'student4',
    imageUrls: ['assets/images/proj_robot.jpg'],
    tags: ['RL', 'OpenAI Gym', 'Robotics'],
    lookingForTeammate: false,
    imageHeightMultiplier: 1.0,
  ),
  const ProjectModel(
    id: 'p5',
    title: 'Real-time ASL Translator app',
    description: 'A mobile application that uses MediaPipe and TFLite to translate American Sign Language gestures into text in real-time using the phone camera.',
    author: 'Sneha P.',
    ownerId: 'student5',
    imageUrls: ['assets/images/event_workshop.jpg'],
    tags: ['MediaPipe', 'Flutter', 'TFLite'],
    lookingForTeammate: true,
    imageHeightMultiplier: 0.9,
  ),
  const ProjectModel(
    id: 'p6',
    title: 'Crop Disease Classifier',
    description: 'A ResNet50 model fine-tuned to classify various crop diseases from leaf images, aimed at helping farmers detect issues early.',
    author: 'Karthik N.',
    ownerId: 'student6',
    imageUrls: ['assets/images/event_seminar.jpg'],
    tags: ['Keras', 'ResNet50', 'AgriTech'],
    lookingForTeammate: false,
    imageHeightMultiplier: 1.1,
  ),
];
