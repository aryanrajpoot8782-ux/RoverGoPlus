import 'package:flutter/material.dart';
import '../../api/captain_api.dart';
import 'login_screen.dart';

class CaptainRegisterScreen extends StatefulWidget {
  const CaptainRegisterScreen({super.key});

  @override
  State<CaptainRegisterScreen> createState() => _CaptainRegisterScreenState();
}

class _CaptainRegisterScreenState extends State<CaptainRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _vehCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _vehCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final veh = _vehCtrl.text.trim();

    setState(() => _loading = true);

    final res = await CaptainApi.register(name, phone, pass, veh);
    if (!mounted) return;

    setState(() => _loading = false);

    final success = res["success"] == true || res["captainId"] != null;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CaptainLoginScreen()),
      );
    } else {
      final err = res["error"] ?? "Registration failed.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Captain Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone"),
                validator: (v) => v!.isEmpty ? "Enter phone" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vehCtrl,
                decoration: const InputDecoration(labelText: "Vehicle No."),
                validator: (v) => v!.isEmpty ? "Enter vehicle number" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : const Text("Create account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
