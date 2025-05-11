import 'package:flutter/material.dart';
import 'package:risk2d/common/values/colors.dart';
import 'package:risk2d/auth/widget/custom_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _gender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isLoading = false);
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Crea tu cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 66, 66, 66),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Comienza tu experiencia Risk2D',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextFormField(
                        controller: _nameController,
                        label: 'Nombres',
                        icon: Icons.person,
                        iconColor: AppColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tus nombres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _surnameController,
                        label: 'Apellidos',
                        icon: Icons.person_outline,
                        iconColor: AppColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tus apellidos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _phoneController,
                        label: 'Teléfono',
                        icon: Icons.phone,
                        iconColor: AppColors.primary,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu número de teléfono';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        iconColor: AppColors.primary,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu correo electrónico';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Correo electrónico inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        icon: Icons.lock_outline,
                        iconColor: AppColors.primary,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'Mínimo 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar contraseña',
                        icon: Icons.lock_reset_outlined,
                        iconColor: AppColors.primary,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirma tu contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: InputDecoration(
                          labelText: 'Sexo',
                          icon: Icon(Icons.transgender),
                          iconColor: AppColors.primary,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items:
                            <String>[
                              'Masculino',
                              'Femenino',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _gender = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecciona tu sexo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    'Registrarse',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Inicia sesión',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
    );
  }
}
