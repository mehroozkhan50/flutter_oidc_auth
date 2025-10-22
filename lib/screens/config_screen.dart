import 'package:flutter/material.dart';
import '../config/oidc_config.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _redirectUriController = TextEditingController();
  
  OidcProvider _selectedProvider = OidcProvider.custom;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }
  
  void _loadCurrentConfig() {
    final config = OidcConfig.config;
    _issuerController.text = config['issuer']!;
    _clientIdController.text = config['clientId']!;
    _clientSecretController.text = config['clientSecret']!;
    _redirectUriController.text = config['redirectUri']!;
  }
  
  void _selectProvider(OidcProvider provider) {
    setState(() {
      _selectedProvider = provider;
    });
    
    // Update form fields based on selected provider
    switch (provider) {
      case OidcProvider.google:
        _issuerController.text = OidcConfig.googleIssuer;
        _clientIdController.text = OidcConfig.googleClientId;
        _clientSecretController.text = OidcConfig.googleClientSecret;
        _redirectUriController.text = OidcConfig.googleRedirectUri;
        break;
      case OidcProvider.auth0:
        _issuerController.text = OidcConfig.auth0Issuer;
        _clientIdController.text = OidcConfig.auth0ClientId;
        _clientSecretController.text = OidcConfig.auth0ClientSecret;
        _redirectUriController.text = OidcConfig.auth0RedirectUri;
        break;
      case OidcProvider.keycloak:
        _issuerController.text = OidcConfig.keycloakIssuer;
        _clientIdController.text = OidcConfig.keycloakClientId;
        _clientSecretController.text = OidcConfig.keycloakClientSecret;
        _redirectUriController.text = OidcConfig.keycloakRedirectUri;
        break;
      case OidcProvider.azure:
        _issuerController.text = OidcConfig.azureIssuer;
        _clientIdController.text = OidcConfig.azureClientId;
        _clientSecretController.text = OidcConfig.azureClientSecret;
        _redirectUriController.text = OidcConfig.azureRedirectUri;
        break;
      case OidcProvider.custom:
        _loadCurrentConfig();
        break;
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
              // Provider selection
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
                        provider: OidcProvider.google,
                        name: 'Google',
                        description: 'Google OAuth2/OIDC',
                        icon: Icons.g_mobiledata,
                        isSelected: _selectedProvider == OidcProvider.google,
                        onTap: () => _selectProvider(OidcProvider.google),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: OidcProvider.auth0,
                        name: 'Auth0',
                        description: 'Auth0 Identity Platform',
                        icon: Icons.security,
                        isSelected: _selectedProvider == OidcProvider.auth0,
                        onTap: () => _selectProvider(OidcProvider.auth0),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: OidcProvider.keycloak,
                        name: 'Keycloak',
                        description: 'Keycloak Open Source',
                        icon: Icons.lock,
                        isSelected: _selectedProvider == OidcProvider.keycloak,
                        onTap: () => _selectProvider(OidcProvider.keycloak),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: OidcProvider.azure,
                        name: 'Azure AD',
                        description: 'Microsoft Azure Active Directory',
                        icon: Icons.cloud,
                        isSelected: _selectedProvider == OidcProvider.azure,
                        onTap: () => _selectProvider(OidcProvider.azure),
                      ),
                      const Divider(),
                      _ProviderOption(
                        provider: OidcProvider.custom,
                        name: 'Custom',
                        description: 'Custom OIDC Provider',
                        icon: Icons.settings,
                        isSelected: _selectedProvider == OidcProvider.custom,
                        onTap: () => _selectProvider(OidcProvider.custom),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Configuration form
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
                  hintText: 'https://your-oidc-provider.com',
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
                  hintText: 'your_client_id',
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
                decoration: const InputDecoration(
                  labelText: 'Client Secret',
                  hintText: 'your_client_secret',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                ),
                obscureText: true,
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
                      const Text(
                        '1. Register your app with your OIDC provider\n'
                        '2. Configure the redirect URI in your provider\n'
                        '3. Update the configuration values above\n'
                        '4. Save the configuration',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Note: This is a demo configuration. In production, store these values securely.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _saveConfiguration();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Configuration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _saveConfiguration() {
    // In a real app, you would save this to secure storage or a config file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration saved! (Demo only)'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back
    Navigator.of(context).pop();
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
  final OidcProvider provider;
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
