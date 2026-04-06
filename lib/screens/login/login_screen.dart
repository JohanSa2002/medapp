import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      if (_isLogin) {
        await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authService.register(
          _emailController.text.trim(),
          _passwordController.text,
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBF2FF), Color(0xFFF4F7FF), Color(0xFFE8FAF5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(64),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.medical_services_rounded, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? 'Bienvenido de nuevo' : 'Crear cuenta',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLogin
                      ? 'Ingresa a tu cuenta para continuar'
                      : 'Completa tus datos para empezar',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Formulario
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campos nombre/apellido solo en registro
                        if (!_isLogin) ...[
                          const _Label('Nombre'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              hintText: 'Ej: María',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => !_isLogin && (v == null || v.trim().isEmpty)
                                ? 'Ingresa tu nombre'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          const _Label('Apellido'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _apellidoController,
                            decoration: const InputDecoration(
                              hintText: 'Ej: González',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => !_isLogin && (v == null || v.trim().isEmpty)
                                ? 'Ingresa tu apellido'
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        const _Label('Correo electrónico'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'correo@ejemplo.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: Validators.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                        ),
                        const SizedBox(height: 16),
                        const _Label('Contraseña'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: _isLogin ? 'Tu contraseña' : 'Mínimo 6 caracteres',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 24),

                        // Botón principal
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuth,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isLogin ? 'Iniciar sesión' : 'Crear cuenta'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle login/registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? '¿No tienes cuenta?' : '¿Ya tienes cuenta?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(_isLogin ? 'Regístrate' : 'Inicia sesión'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
