import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/config_service.dart';

class OidcConfigScreen extends StatefulWidget {
  const OidcConfigScreen({super.key});

  @override
  State<OidcConfigScreen> createState() => _OidcConfigScreenState();
}

class _OidcConfigScreenState extends State<OidcConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _redirectUriController = TextEditingController();
  
  String _selectedProvider = 'google';
  bool _isLoading = false;
  bool _showSecret = false;
  
  final ConfigService _configService = ConfigService();
  
  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }
  
  Future<void> _loadCurrentConfig() async {
    final config = await _configService.getConfig();
    setState(() {
      _issuerController.text = config['issuer'] ?? '';
      _clientIdController.text = config['clientId'] ?? '';
      _clientSecretController.text = config['clientSecret'] ?? '';
      _redirectUriController.text = config['redirectUri'] ?? '';
      _selectedProvider = config['provider'] ?? 'google';
    });
  }
  
  void _selectProvider(String provider) {
    setState(() {
      _selectedProvider = provider;
      final defaults = ConfigService.getProviderDefaults(provider);
      _issuerController.text = defaults['issuer'] ?? '';
      _redirectUriController.text = defaults['redirectUri'] ?? '';
    });
  }
  
  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _configService.saveConfig(
        issuer: _issuerController.text.trim(),
        clientId: _clientIdController.text.trim(),
        clientSecret: _clientSecretController.text.trim(),
        redirectUri: _redirectUriController.text.trim(),
        provider: _selectedProvider,
      );
      
      // Reinitialize auth provider with new config
      if (mounted) {
        await Provider.of<AuthProvider>(context, listen: false).initialize();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save configuration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OIDC Configuration'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider Selection
              const Text(
                'Select OIDC Provider',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _ProviderOption(
                        provider: 'google',
                        name: 'Google',
                        description: 'Google OAuth2/OIDC',
                        icon: Icons.g_mobiledata,
                        isSelected: _selectedProvider == 'google',
                        onTap: () => _selectProvider('google'),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: 'auth0',
                        name: 'Auth0',
                        description: 'Auth0 Identity Platform',
                        icon: Icons.security,
                        isSelected: _selectedProvider == 'auth0',
                        onTap: () => _selectProvider('auth0'),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: 'keycloak',
                        name: 'Keycloak',
                        description: 'Keycloak Open Source',
                        icon: Icons.lock,
                        isSelected: _selectedProvider == 'keycloak',
                        onTap: () => _selectProvider('keycloak'),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: 'azure',
                        name: 'Azure AD',
                        description: 'Microsoft Azure Active Directory',
                        icon: Icons.cloud,
                        isSelected: _selectedProvider == 'azure',
                        onTap: () => _selectProvider('azure'),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: 'custom',
                        name: 'Custom',
                        description: 'Custom OIDC Provider',
                        icon: Icons.settings,
                        isSelected: _selectedProvider == 'custom',
                        onTap: () => _selectProvider('custom'),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Configuration Form
              const Text(
                'Configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  labelText: 'Issuer URL',
                  hintText: 'https://accounts.google.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the issuer URL';
                  }
                  if (Uri.tryParse(value)?.hasAbsolutePath != true) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _clientIdController,
                decoration: const InputDecoration(
                  labelText: 'Client ID',
                  hintText: 'your_client_id.apps.googleusercontent.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the client ID';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _clientSecretController,
                decoration: InputDecoration(
                  labelText: 'Client Secret',
                  hintText: 'your_client_secret',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.security),
                  suffixIcon: IconButton(
                    icon: Icon(_showSecret ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _showSecret = !_showSecret;
                      });
                    },
                  ),
                ),
                obscureText: !_showSecret,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the client secret';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _redirectUriController,
                decoration: const InputDecoration(
                  labelText: 'Redirect URI',
                  hintText: 'com.example.flutteroidcauth://oauth/callback',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.arrow_back),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the redirect URI';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Instructions
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
                            'Setup Instructions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getProviderInstructions(_selectedProvider),
                        style: const TextStyle(fontSize: 14),
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
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveConfiguration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Save Configuration'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getProviderInstructions(String provider) {
    switch (provider) {
      case 'google':
        return '1. Go to Google Cloud Console\n'
               '2. Create a new project or select existing\n'
               '3. Enable Google+ API\n'
               '4. Create OAuth 2.0 credentials\n'
               '5. Add redirect URI: com.example.flutteroidcauth://oauth/callback';
      case 'auth0':
        return '1. Create an Auth0 account\n'
               '2. Create a new application\n'
               '3. Configure allowed callback URLs\n'
               '4. Note your domain, client ID, and client secret';
      case 'keycloak':
        return '1. Install and run Keycloak server\n'
               '2. Create a new realm\n'
               '3. Create a new client\n'
               '4. Configure valid redirect URIs';
      case 'azure':
        return '1. Go to Azure Portal\n'
               '2. Navigate to Azure Active Directory\n'
               '3. Register a new application\n'
               '4. Configure redirect URIs';
      default:
        return '1. Set up your OIDC provider\n'
               '2. Configure the redirect URI\n'
               '3. Get your client credentials\n'
               '4. Enter the configuration details';
    }
  }
  
  @override
  void dispose() {
    _issuerController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _redirectUriController.dispose();
    super.dispose();
  }
}

class _ProviderOption extends StatelessWidget {
  final String provider;
  final String name;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProviderOption({
    required this.provider,
    required this.name,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFF667eea).withValues(alpha: 0.1) : null,
          border: isSelected ? Border.all(color: const Color(0xFF667eea)) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF667eea) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF667eea) : Colors.black,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF667eea),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
