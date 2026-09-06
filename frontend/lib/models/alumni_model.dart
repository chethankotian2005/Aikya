/// Data model for the Alumni Directory.
class AlumniModel {
  final String id;
  final String name;
  final String role;
  final String company;
  final String batchYear;
  final String specialization;
  final bool openForMentorship;
  final String linkedinUrl;
  final String bio;

  const AlumniModel({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.batchYear,
    required this.specialization,
    this.openForMentorship = false,
    required this.linkedinUrl,
    required this.bio,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }
}

// ─── Sample Data ────────────────────────────────────────────────────

final List<AlumniModel> sampleAlumni = [
  const AlumniModel(
    id: 'a1',
    name: 'Siddharth Rao',
    role: 'Machine Learning Engineer',
    company: 'Google',
    batchYear: '2022',
    specialization: 'Computer Vision',
    openForMentorship: true,
    linkedinUrl: 'linkedin.com/in/siddharthrao',
    bio: 'Currently working on large-scale vision models at Google Research. Happy to review resumes or chat about breaking into FAANG as an AI/ML fresher.',
  ),
  const AlumniModel(
    id: 'a2',
    name: 'Ananya Sharma',
    role: 'Data Scientist',
    company: 'Amazon',
    batchYear: '2023',
    specialization: 'NLP & LLMs',
    openForMentorship: true,
    linkedinUrl: 'linkedin.com/in/ananyasharma',
    bio: 'Building recommendation systems and working heavily with generative AI. Open to mentoring students working on their final year projects in NLP.',
  ),
  const AlumniModel(
    id: 'a3',
    name: 'Rahul Desai',
    role: 'AI Researcher',
    company: 'TCS Innovation Labs',
    batchYear: '2021',
    specialization: 'Reinforcement Learning',
    openForMentorship: false,
    linkedinUrl: 'linkedin.com/in/rahuldesai',
    bio: 'Focusing on applied reinforcement learning for industrial automation. Currently heads a team of 4 researchers.',
  ),
  const AlumniModel(
    id: 'a4',
    name: 'Meghna Patil',
    role: 'Software Engineer - AI',
    company: 'Microsoft',
    batchYear: '2022',
    specialization: 'MLOps',
    openForMentorship: true,
    linkedinUrl: 'linkedin.com/in/meghnapatil',
    bio: 'Working on Azure Machine Learning infrastructure. I can help you understand how to scale and deploy ML models into production environments.',
  ),
  const AlumniModel(
    id: 'a5',
    name: 'Karthik Nair',
    role: 'Founder',
    company: 'NeuralX (Startup)',
    batchYear: '2020',
    specialization: 'Edge AI',
    openForMentorship: true,
    linkedinUrl: 'linkedin.com/in/karthiknair',
    bio: 'Bootstrapped an Edge AI startup focusing on smart agriculture. Always looking for talented interns from my alma mater!',
  ),
  const AlumniModel(
    id: 'a6',
    name: 'Priya Verma',
    role: 'Data Analyst',
    company: 'Mu Sigma',
    batchYear: '2024',
    specialization: 'Data Analytics',
    openForMentorship: false,
    linkedinUrl: 'linkedin.com/in/priyaverma',
    bio: 'Recent graduate. Working with Fortune 500 clients on supply chain analytics.',
  ),
];
