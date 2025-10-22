import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SetupGuideScreen extends StatelessWidget {
  const SetupGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Guide'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.settings,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'OIDC Setup Required',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Configure your OIDC provider to enable authentication',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Google OAuth2 Setup
            _SetupSection(
              title: 'Google OAuth2 Setup',
              icon: Icons.g_mobiledata,
              steps: [
                'Go to Google Cloud Console',
                'Create a new project or select existing',
                'Enable Google+ API',
                'Create OAuth 2.0 credentials',
                'Add redirect URI: com.example.flutteroidcauth://oauth/callback',
                'Copy Client ID and Client Secret',
              ],
              onTap: () => _launchUrl('https://console.cloud.google.com/'),
            ),
            
            const SizedBox(height: 16),
            
            // Auth0 Setup
            _SetupSection(
              title: 'Auth0 Setup',
              icon: Icons.security,
              steps: [
                'Create an Auth0 account',
                'Create a new application',
                'Configure allowed callback URLs',
                'Note your domain, client ID, and client secret',
              ],
              onTap: () => _launchUrl('https://auth0.com/'),
            ),
            
            const SizedBox(height: 16),
            
            // Keycloak Setup
            _SetupSection(
              title: 'Keycloak Setup',
              icon: Icons.lock,
              steps: [
                'Install and run Keycloak server',
                'Create a new realm',
                'Create a new client',
                'Configure valid redirect URIs',
              ],
              onTap: () => _launchUrl('https://www.keycloak.org/'),
            ),
            
            const SizedBox(height: 24),
            
            // Configuration Instructions
            Card(
              color: Colors.blue.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Configuration Steps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Choose your OIDC provider from the options above\n'
                      '2. Follow the setup instructions\n'
                      '3. Update the configuration in lib/config/oidc_config.dart\n'
                      '4. Replace placeholder values with your actual credentials\n'
                      '5. Restart the app to apply changes',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Current Configuration:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Provider: Google OAuth2\n'
                        'Client ID: YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com\n'
                        'Client Secret: YOUR_GOOGLE_CLIENT_SECRET\n'
                        'Redirect URI: com.example.flutteroidcauth://oauth/callback',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Show configuration file
                      _showConfigDialog(context);
                    },
                    icon: const Icon(Icons.code),
                    label: const Text('View Config'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuration File'),
        content: const SingleChildScrollView(
          child: Text(
            'Edit lib/config/oidc_config.dart\n\n'
            'Replace the placeholder values:\n'
            '• YOUR_GOOGLE_CLIENT_ID with your actual Google Client ID\n'
            '• YOUR_GOOGLE_CLIENT_SECRET with your actual Google Client Secret\n\n'
            'Then restart the app to apply changes.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SetupSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> steps;
  final VoidCallback onTap;

  const _SetupSection({
    required this.title,
    required this.icon,
    required this.steps,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: const Color(0xFF667eea)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              ...steps.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
