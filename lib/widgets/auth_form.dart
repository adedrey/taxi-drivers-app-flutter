import 'package:flutter/material.dart';

enum AuthMode { SIGNUP, LOGIN }

class AuthGuard extends StatefulWidget {
  final bool isLoading;
  final void Function(
    String name,
    String email,
    String phone,
    String password,
    AuthMode authMode,
  ) submitFn;
  const AuthGuard({Key? key, required this.submitFn, this.isLoading = false})
      : super(key: key);
  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.LOGIN;
  final Map<String, String> _authData = {
    'name': '',
    'email': '',
    'phone': '',
    'password': ''
  };

  void _switchMode() {
    if (_authMode == AuthMode.LOGIN) {
      setState(() {
        _authMode = AuthMode.SIGNUP;
      });
    } else {
      setState(() {
        _authMode = AuthMode.LOGIN;
      });
    }
  }

  void _tryToSubmit() {
    final _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_isValid) {
      _formKey.currentState!.save();

      widget.submitFn(_authData['name']!, _authData['email']!,
          _authData['phone']!, _authData['password']!, _authMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'Authenticate Driver',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            if (_authMode == AuthMode.SIGNUP)
              TextFormField(
                style: const TextStyle(
                  color: Colors.grey,
                ),
                key: const ValueKey('name'),
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: _authMode == AuthMode.SIGNUP
                    ? (value) {
                        if (value!.isEmpty) {
                          return 'Name must contain characters';
                        }
                        return null;
                      }
                    : null,
                onSaved: (value) {
                  _authData['name'] = value!.trim();
                },
              ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: const TextStyle(
                color: Colors.grey,
              ),
              key: const ValueKey('email'),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return 'Invalid Email';
                }
                return null;
              },
              onSaved: (value) {
                _authData['email'] = value!.trim();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            if (_authMode == AuthMode.SIGNUP)
              TextFormField(
                style: const TextStyle(
                  color: Colors.grey,
                ),
                key: const ValueKey('phone'),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: _authMode == AuthMode.SIGNUP
                    ? (value) {
                        if (value!.isEmpty || value.length > 11) {
                          return 'Invalid Phone Number';
                        }
                        return null;
                      }
                    : null,
                onSaved: (value) {
                  _authData['phone'] = value!.trim();
                },
              ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: const TextStyle(
                color: Colors.grey,
              ),
              key: const ValueKey('password'),
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty || value.length < 5) {
                  return 'Password is too short';
                }
                return null;
              },
              onSaved: (value) {
                _authData['password'] = value!.trim();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _tryToSubmit,
              style: ElevatedButton.styleFrom(
                primary: Colors.white70,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              child: Text(
                _authMode == AuthMode.SIGNUP ? 'Sign Up' : 'Login',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _authMode == AuthMode.SIGNUP
                      ? 'Do you have an account?'
                      : 'Haven\'t registered?',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: _switchMode,
                  child: Text(
                    _authMode == AuthMode.SIGNUP ? 'Login' : 'Register',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
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
}
