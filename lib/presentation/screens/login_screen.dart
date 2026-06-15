import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapstay_host/presentation/providers/auth_provider.dart';
import 'package:mapstay_host/presentation/widgets/inputs/inputs.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_button.dart';
import 'package:mapstay_host/presentation/widgets/mapstay_toast.dart';

/// Pantalla de inicio de sesión (Login) para MapStay Anfitriones.
/// Cumple rigurosamente con SOLID y las especificaciones visuales de Material 3 y Dark First.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onRegisterPressed,
    this.onLoginSuccess,
  });

  /// Callback delegado para navegar a la pantalla de registro externa.
  final VoidCallback? onRegisterPressed;

  /// Callback delegado ejecutado tras un inicio de sesión exitoso.
  final VoidCallback? onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Ejecuta la validación local del formulario y dispara el proceso de Login en el AuthProvider.
  Future<void> _handleLogin(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      // Oculta el teclado virtual de inmediato
      FocusScope.of(context).unfocus();

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await authProvider.login(email, password);

      if (!context.mounted) return;

      if (success) {
        MapStayToast.show(
          context,
          message: '¡Bienvenido de nuevo, ${authProvider.userName ?? "Anfitrión"}!',
          type: MapStayToastType.success,
        );
        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        }
      } else {
        MapStayToast.show(
          context,
          message: authProvider.errorMessage ?? 'Error al iniciar sesión. Verifique sus credenciales.',
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
              // 1. Cabecera Hero (40% de la altura física de la pantalla)
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
                          // Imagen Lifestyle
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
                              // Fallback elegante en degradados oscuros si falla la red
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
                          // Degradado lineal para fundir la imagen con el fondo oscuro del Scaffold
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

              // 2. Contenedor Principal con Margen Negativo
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado del Formulario
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
                        'Anfitrión',
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

                      // Formulario de Inicio de Sesión
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Campo Correo electrónico
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

                            // Campo Contraseña
                            MapStayPasswordTextField(
                              labelText: 'Contraseña *',
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              hintText: 'Ingrese su contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              textInputAction: TextInputAction.done,
                              enabled: !authProvider.isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'La contraseña es requerida';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Acción de Inicio de Sesión
                            MapStayButton(
                              text: 'Iniciar sesión',
                              isLoading: authProvider.isLoading,
                              onPressed: () => _handleLogin(context, authProvider),
                            ),
                            const SizedBox(height: 24),

                            // Enlace de Registro
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿No tienes cuenta? ',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: authProvider.isLoading
                                      ? null
                                      : () {
                                          if (widget.onRegisterPressed != null) {
                                            widget.onRegisterPressed!();
                                          } else {
                                            MapStayToast.show(
                                              context,
                                              message: 'El flujo de registro externo estará disponible próximamente.',
                                              type: MapStayToastType.info,
                                            );
                                          }
                                        },
                                  child: Text(
                                    'Regístrate',
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

/// Dibuja una elipse perfecta en la base de la cabecera, emulando la CSS ellipse(150% 100% at 50% 0%)
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.82);
    
    // Punto de control de curva Bezier cuadrática en la base central
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
