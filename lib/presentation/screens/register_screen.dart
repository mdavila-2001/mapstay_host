import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mapstay_host/presentation/providers/auth_provider.dart';
import 'package:mapstay_host/presentation/widgets/inputs/inputs.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_button.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.onLoginPressed,
    this.onRegisterSuccess,
  });

  final VoidCallback? onLoginPressed;

  final VoidCallback? onRegisterSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text;

      final success = await authProvider.register(
        nombreCompleto: name,
        email: email,
        telefono: phone,
        password: password,
      );

      if (!context.mounted) return;

      if (success) {
        MapStayToast.show(
          context,
          message: '¡Registro exitoso! Bienvenido, $name.',
          type: MapStayToastType.success,
        );
        if (widget.onRegisterSuccess != null) {
          widget.onRegisterSuccess!();
        }
      } else {
        MapStayToast.show(
          context,
          message: authProvider.errorMessage ?? 'Error al registrar la cuenta. Intente nuevamente.',
          type: MapStayToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: HeaderClipper(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.40,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuDHg0TfRvoSUSnVG_4u6-LL_DifNduDL9x4RKAMVqBsgNDbbIkOhxP9eq_HSuumArXcNydu3VCQVcJpVUOToyyKP3oPDMxtg9NyocFC146Use8y36Yp3SyIgmmOJ4c6B-GZWXZO3nW-N3qCf1NlTAo7PqHvbXeRTwV40T_ik8dZOhV5K9NOCAgoAFT52VlzSkHiYhlIzi2k8bAEP30EH1FuqnfWSJenGMFz0uyZTHVlqm3y_XbVzUQhIIj7tsD818RIPb37YX_iceFb',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: theme.colorScheme.surfaceContainer,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: theme.colorScheme.surfaceContainerHigh,
                                child: Icon(
                                  Icons.home_work_rounded,
                                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                                  size: 64,
                                ),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                                  theme.scaffoldBackgroundColor,
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Text(
                        '¡Te damos la bienvenida!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ) ?? const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Anfitrión - Registro',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ) ?? const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),


                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            MapStayTextField(
                              labelText: 'Nombre completo *',
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              hintText: 'Ingrese su nombre y apellido',
                              prefixIcon: const Icon(Icons.person_outline),
                              textInputAction: TextInputAction.next,
                              enabled: !authProvider.isLoading,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El nombre completo es requerido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),


                            MapStayTextField(
                              labelText: 'Correo electrónico *',
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              hintText: 'ejemplo@correo.com',
                              isEmail: true,
                              prefixIcon: const Icon(Icons.email_outlined),
                              textInputAction: TextInputAction.next,
                              enabled: !authProvider.isLoading,
                            ),
                            const SizedBox(height: 20),


                            MapStayTextField(
                              labelText: 'Teléfono *',
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              hintText: 'Ej. 76543210',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              enabled: !authProvider.isLoading,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'El teléfono es requerido';
                                }
                                if (value.trim().length < 7) {
                                  return 'El teléfono debe tener al menos 7 dígitos';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),


                            MapStayPasswordTextField(
                              labelText: 'Contraseña *',
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              hintText: 'Mínimo 6 caracteres',
                              prefixIcon: const Icon(Icons.lock_outline),
                              textInputAction: TextInputAction.done,
                              enabled: !authProvider.isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La contraseña es requerida';
                                }
                                if (value.length < 6) {
                                  return 'La contraseña debe tener al menos 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),


                            MapStayButton(
                              text: 'Registrarse',
                              isLoading: authProvider.isLoading,
                              onPressed: () => _handleRegister(context, authProvider),
                            ),
                            const SizedBox(height: 24),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Ya tienes cuenta? ',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: authProvider.isLoading
                                      ? null
                                      : () {
                                          if (widget.onLoginPressed != null) {
                                            widget.onLoginPressed!();
                                          } else {
                                            MapStayToast.show(
                                              context,
                                              message: 'El flujo de inicio de sesión no está disponible.',
                                              type: MapStayToastType.info,
                                            );
                                          }
                                        },
                                  child: Text(
                                    'Inicia sesión',
                                    style: TextStyle(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.82);
    

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.82,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
