import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'config_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OIDC Auth Demo'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConfigScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Configuration',
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                icon: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.logout),
                tooltip: 'Logout',
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (authProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${authProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => authProvider.initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userInfo = authProvider.userInfo;
          final tokens = authProvider.tokens;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF667eea),
                              backgroundImage: userInfo?.picture != null
                                  ? NetworkImage(userInfo!.picture!)
                                  : null,
                              child: userInfo?.picture == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userInfo?.name ?? 'User',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (userInfo?.email != null)
                                    Text(
                                      userInfo!.email!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Successfully authenticated with OIDC',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // User information section
                if (userInfo != null) ...[
                  const Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Subject ID',
                    value: userInfo.sub,
                    icon: Icons.fingerprint,
                  ),
                  if (userInfo.givenName != null)
                    _InfoCard(
                      title: 'Given Name',
                      value: userInfo.givenName!,
                      icon: Icons.person,
                    ),
                  if (userInfo.familyName != null)
                    _InfoCard(
                      title: 'Family Name',
                      value: userInfo.familyName!,
                      icon: Icons.person_outline,
                    ),
                  if (userInfo.preferredUsername != null)
                    _InfoCard(
                      title: 'Username',
                      value: userInfo.preferredUsername!,
                      icon: Icons.alternate_email,
                    ),
                  if (userInfo.locale != null)
                    _InfoCard(
                      title: 'Locale',
                      value: userInfo.locale!,
                      icon: Icons.language,
                    ),
                  if (userInfo.emailVerified != null)
                    _InfoCard(
                      title: 'Email Verified',
                      value: userInfo.emailVerified! ? 'Yes' : 'No',
                      icon: userInfo.emailVerified! ? Icons.verified : Icons.warning,
                    ),
                ],

                const SizedBox(height: 24),

                // Token information section
                if (tokens != null) ...[
                  const Text(
                    'Token Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: 'Token Type',
                    value: tokens.tokenType,
                    icon: Icons.vpn_key,
                  ),
                  _InfoCard(
                    title: 'Expires In',
                    value: '${tokens.expiresIn} seconds',
                    icon: Icons.access_time,
                  ),
                  _InfoCard(
                    title: 'Issued At',
                    value: tokens.issuedAt.toString(),
                    icon: Icons.schedule,
                  ),
                  _InfoCard(
                    title: 'Has Refresh Token',
                    value: tokens.refreshToken != null ? 'Yes' : 'No',
                    icon: tokens.refreshToken != null ? Icons.refresh : Icons.refresh,
                  ),
                  _InfoCard(
                    title: 'Has ID Token',
                    value: tokens.idToken != null ? 'Yes' : 'No',
                    icon: tokens.idToken != null ? Icons.badge : Icons.badge_outlined,
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final token = await authProvider.getValidAccessToken();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  token != null
                                      ? 'Access token retrieved successfully'
                                      : 'Failed to get access token',
                                ),
                                backgroundColor: token != null ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.vpn_key),
                        label: const Text('Get Access Token'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacementNamed('/login');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF667eea)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
