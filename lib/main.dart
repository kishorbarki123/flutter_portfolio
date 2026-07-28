import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'services/feedback_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 16, 17, 17),
        ),
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FeedbackService feedbackService = FeedbackService(
    Supabase.instance.client,
  );
  bool isSubmitting = false;
  bool isLoadingFeedback = false;
  String feedbackMessage = '';
  List<Map<String, dynamic>> recentFeedbacks = [];

  @override
  void initState() {
    super.initState();
    loadRecentFeedback();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitFeedback() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || phone.isEmpty || description.isEmpty) {
      setState(() {
        feedbackMessage = 'Please fill in all fields.';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      feedbackMessage = '';
    });

    try {
      await feedbackService.createFeedback(
        name: name,
        phone: phone,
        description: description,
      );

      if (!mounted) return;

      setState(() {
        feedbackMessage = 'Feedback sent successfully!';
        nameController.clear();
        phoneController.clear();
        descriptionController.clear();
      });

      await loadRecentFeedback();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        feedbackMessage = 'Failed to send feedback: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  } // End of submitFeedback

  Future<void> loadRecentFeedback() async {
    if (!feedbackService.isReady) {
      setState(() {
        recentFeedbacks = [];
      });
      return;
    }

    setState(() {
      isLoadingFeedback = true;
    });

    try {
      final feedbacks = await feedbackService.fetchFeedback(limit: 10);
      if (!mounted) return;
      setState(() {
        recentFeedbacks = feedbacks;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        recentFeedbacks = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to load feedback: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingFeedback = false;
        });
      }
    }
  } // End of loadRecentFeedback

  Future<void> deleteFeedbackItem(String id) async {
    try {
      await feedbackService.deleteFeedback(id);
      await loadRecentFeedback();
      if (!mounted) return;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Feedback deleted')));
      }
    } catch (e) {
      if (!mounted) return;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  } // End of deleteFeedbackItem

  Future<void> editFeedbackItem(Map<String, dynamic> feedback) async {
    final id = feedback['id']?.toString();
    if (id == null || id.isEmpty) return;

    final nameController = TextEditingController(
      text: feedback['name']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: feedback['phone']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: feedback['description']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedName = nameController.text.trim();
                final updatedPhone = phoneController.text.trim();
                final updatedDescription = descriptionController.text.trim();

                if (updatedName.isEmpty ||
                    updatedPhone.isEmpty ||
                    updatedDescription.isEmpty) {
                  return;
                }

                try {
                  await feedbackService.updateFeedback(
                    id: id,
                    name: updatedName,
                    phone: updatedPhone,
                    description: updatedDescription,
                  );
                  if (!mounted) return;
                  await loadRecentFeedback();
                  if (!mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (Navigator.of(dialogContext).canPop()) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Feedback updated')),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
  }// End of editFeedbackItem

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 16, 17, 17),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
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
                                selectedProject = isSelected
                                    ? ''
                                    : projectName; // Toggle selection
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
              buildSectionTitle('Leave Feedback'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Your feedback',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: isSubmitting ? null : submitFeedback,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          isSubmitting ? 'Sending...' : 'Send Feedback',
                        ),
                      ),
                      if (feedbackMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          feedbackMessage,
                          style: TextStyle(
                            color: feedbackMessage.contains('successfully')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              buildSectionTitle('Recent Feedback'),
              const SizedBox(height: 8),
              if (isLoadingFeedback)
                const Center(child: CircularProgressIndicator())
              else if (recentFeedbacks.isEmpty)
                const Text('No feedback yet.')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentFeedbacks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final feedback = recentFeedbacks[index];
                    return Card(
                      child: ListTile(
                        title: Text(feedback['name']?.toString() ?? 'No name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(feedback['description']?.toString() ?? ''),
                            const SizedBox(height: 4),
                            Text(feedback['phone']?.toString() ?? ''),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => editFeedbackItem(feedback),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                final id = feedback['id']?.toString();
                                if (id != null && id.isNotEmpty) {
                                  deleteFeedbackItem(id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

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
