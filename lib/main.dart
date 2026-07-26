import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyPortfolioApp());
}

class MyPortfolioApp extends StatelessWidget {
  const MyPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio App2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 16, 17, 17)),
      ),
      home: const PortfolioHomePage(),
    );
  }
}

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState(); 
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final projects = [
    {
      'name': 'Portfolio Website',
      'description':
          'A clean personal portfolio app built with Flutter UI widgets.',
    },
    {
      'name': 'Flutter Quiz App',
      'description':
          'A quiz app that shows how to organize simple stateful logic.',
    },
    {
      'name': 'Weather App',
      'description':
          'A weather app concept that demonstrates API-driven UI design.',
    },
  ];

  final socialLinks = [
    {'label': 'GitHub', 'icon': Icons.code, 'url': 'https://github.com'},
    {
      'label': 'LinkedIn',
      'icon': Icons.business_center,
      'url': 'https://www.linkedin.com',
    },
    {
      'label': 'Instagram',
      'icon': Icons.camera_alt,
      'url': 'https://www.instagram.com',
    },
    {'label': 'X / Twitter', 'icon': Icons.chat, 'url': 'https://x.com'},
  ];

  String selectedProject = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Portfolio'), 
      centerTitle: true, backgroundColor: const Color.fromARGB(255, 16, 17, 17), 
      titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, //
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 62,
                      backgroundColor: const Color.fromARGB(255, 17, 17, 17),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/profile.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kishor',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Flutter Developer - UI Enthusiast',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              buildSectionTitle('About Me'),
              const SizedBox(height: 8),
              const Text(
                'I love building clean, beginner-friendly mobile apps with Flutter. '
                'This portfolio app presents my skills, projects, and social links in one place.',
              ),

              const SizedBox(height: 24),
              buildSectionTitle('Projects'),
              const SizedBox(height: 8),
              ...projects.map((project) {
                final projectName = project['name'] as String;
                final description = project['description'] as String;
                final isSelected = selectedProject == projectName;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedProject = isSelected ? '' : projectName; // Toggle selection
                              });
                            },
                            icon: const Icon(Icons.apps_rounded),
                            label: Text(projectName),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 8),
                            Text(description),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),
              buildSectionTitle('Social Media'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: socialLinks.map((link) {
                  return SocialLinkChip(
                    icon: link['icon'] as IconData,
                    label: link['label'] as String,
                    url: link['url'] as String,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class SocialLinkChip extends StatelessWidget {
  const SocialLinkChip({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}
