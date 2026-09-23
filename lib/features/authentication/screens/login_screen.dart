import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../routing/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_snackbar.dart';

/// Professional Login Screen with split-hero desktop layout, validation, and demo role chips
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@library.com');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } else if (mounted) {
      AppSnackbar.showError(context, 'Invalid credentials. Please try again.');
    }
  }

  void _fillDemo(String email, String password, UserRole role) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.loginAsRole(role);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppDimensions.tabletBreakpoint;

    return Scaffold(
      body: Row(
        children: [
          // Left Hero Banner (Visible on Desktop / Large Tablet)
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                color: AppColors.primaryDark,
                padding: const EdgeInsets.all(48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_library, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'LIBRA SYSTEM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    // Value Proposition
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next-Generation\nLibrary Circulation & Analytics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Seamless catalog search, automated borrowing schedules, intelligent fine tracking, and role-based student and librarian portals.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Feature highlights pills
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildFeaturePill(Icons.speed, 'Real-time Availability'),
                            _buildFeaturePill(Icons.shield_outlined, 'Role-Based Access'),
                            _buildFeaturePill(Icons.calculate_outlined, 'Auto-Calculated Fines'),
                            _buildFeaturePill(Icons.devices, 'Cross-Platform Ready'),
                          ],
                        ),
                      ],
                    ),
                    // Footer note
                    Text(
                      '© 2026 Libra System. Built for universities, schools, and research libraries.',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          // Right Form Panel
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile brand header
                        if (!isDesktop) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.local_library, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'LIBRA SYSTEM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          'Welcome back',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to access your library dashboard and catalog.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                        // Quick demo accounts selector
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DEMO QUICK LOGIN:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ActionChip(
                                    avatar: const Icon(Icons.admin_panel_settings, size: 16),
                                    label: const Text('Admin', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _fillDemo('admin@library.com', 'admin123', UserRole.admin),
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.badge, size: 16),
                                    label: const Text('Librarian', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _fillDemo('librarian@library.com', 'lib123', UserRole.librarian),
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.school, size: 16),
                                    label: const Text('Student', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _fillDemo('student@library.com', 'student123', UserRole.member),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'Email Address',
                          hint: 'name@library.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                ),
                                const Text('Remember me', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, RouteNames.forgotPassword);
                              },
                              child: const Text('Forgot password?', style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          text: 'Sign In to Account',
                          width: double.infinity,
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(fontSize: 14)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, RouteNames.register);
                                },
                                child: const Text(
                                  'Register now',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
