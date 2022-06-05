import 'package:flutter/material.dart';

import './auth_form.dart';

class CarDetailGuard extends StatefulWidget {
  final void Function(
    String carModel,
    String carNo,
    String carColor,
    String carType,
    AuthMode authMode,
  ) submitFn;
  const CarDetailGuard({
    Key? key,
    required this.submitFn,
  }) : super(key: key);

  @override
  _CarDetailGuardState createState() => _CarDetailGuardState();
}

class _CarDetailGuardState extends State<CarDetailGuard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final AuthMode _authMode = AuthMode.SIGNUP;
  final Map<String, String> _authData = {
    'car_model': '',
    'car_no': '',
    'car_color': '',
    'car_type': '',
  };
  String? selectedCarType;
  List<String> carTypesList = ['uber-x', 'uber-go', 'bike'];

  void _tryToSubmit() {
    final _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_isValid) {
      _formKey.currentState!.save();

      widget.submitFn(_authData['car_model']!, _authData['car_no']!,
          _authData['car_color']!, _authData['car_type']!, _authMode);
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
              'Black Car Details',
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
                key: const ValueKey('car_model'),
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Car Model',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: _authMode == AuthMode.SIGNUP
                    ? (value) {
                        if (value!.isEmpty) {
                          return 'Car Number must not be empty';
                        }
                        return null;
                      }
                    : null,
                onSaved: (value) {
                  _authData['car_model'] = value!.trim();
                },
              ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              style: const TextStyle(
                color: Colors.grey,
              ),
              key: const ValueKey('car_no'),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Car Number',
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Invalid Car Number';
                }
                return null;
              },
              onSaved: (value) {
                _authData['car_no'] = value!.trim();
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
                key: const ValueKey('car_color'),
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Car Color',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: _authMode == AuthMode.SIGNUP
                    ? (value) {
                        if (value!.isEmpty) {
                          return 'Car must have color';
                        }
                        return null;
                      }
                    : null,
                onSaved: (value) {
                  _authData['car_color'] = value!.trim();
                },
              ),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField(
              dropdownColor: Colors.black87,
              hint: const Text(
                'Please choose car Type',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(
                color: Colors.grey,
              ),
              items: carTypesList.map(
                (car) {
                  return DropdownMenuItem(
                    child: Text(
                      car,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    value: car,
                  );
                },
              ).toList(),
              value: selectedCarType,
              onChanged: (newValue) {
                setState(() {
                  _authData['car_type'] = newValue.toString();
                });
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
                _authMode == AuthMode.SIGNUP ? 'Save Now' : 'Login',
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
                  onPressed: () {},
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
