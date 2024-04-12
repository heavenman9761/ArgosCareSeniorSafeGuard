import 'dart:convert';

import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/components/square_tile.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/auth/auth_dio.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController(text: 'dn9318dn@gmail.com');
  final passwordController = TextEditingController(text: '121212');

  bool isLogging = false;

  // sign user in method
  Future<void> signUserIn(BuildContext context) async {

    setState(() {
      isLogging = true;
    });

    try {
      dio = await authDio();
      final response = await dio.post(
          "/auth/signin",
          data: jsonEncode({
            "email": usernameController.text,
            "password": passwordController.text
          })
      );

      final token = response.data['token'];
      print('first token: $token');
      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      await storage.write(key: 'ACCESS_TOKEN', value: token);

      var loginResponse = await dio.get(
          "/auth/me"
      );

      final String userName = loginResponse.data['user']['name'];

      await storage.write(key: 'ID', value: loginResponse.data['user']['id']);
      await storage.write(key: 'EMAIL', value: loginResponse.data['user']['email']);
      await storage.write(key: 'PASSWORD', value: passwordController.text);
      await storage.write(key: 'NAME', value: loginResponse.data['user']['name']);
      await storage.write(key: 'ADDR_ZIP', value: loginResponse.data['user']['addr_zip']);
      await storage.write(key: 'ADDR', value: loginResponse.data['user']['addr']);
      await storage.write(key: 'MOBILE_PHONE', value: loginResponse.data['user']['mobilephone']);
      await storage.write(key: 'TEL', value: loginResponse.data['user']['tel']);
      await storage.write(key: 'SNS_ID', value: loginResponse.data['user']['snsId']);
      await storage.write(key: 'PROVIDER', value: loginResponse.data['user']['provider']);
      await storage.write(key: 'ADMiN', value: loginResponse.data['user']['admin'].toString());

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) {
            return HomePage(title: 'Argos Care', userName: userName);
          },
        )
      );

    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLogging = false;
      });
    }
  }

  void _iostest() async {
    final int result = await Constants.platform.invokeMethod('getBatteryLevel');
    debugPrint('batteryLevel: $result');
  }

  Widget loginWidget(BuildContext context) {
    if (isLogging) {
      return const CircularProgressIndicator();
    } else {
      return MyButton(
          onTap: () async {
            signUserIn(context);
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 30),

              // welcome back, you've been missed!
              Text(
                'Welcome back you\'ve been missed!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // username textfield
              MyTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // sign in button
              loginWidget(context),

              const SizedBox(height: 30),

              // or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // google + apple sign in buttons
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:  [
                  SquareTile(imagePath: 'lib/images/google.png'),
                  SquareTile(imagePath: 'lib/images/facebook.png'),
                  SquareTile(imagePath: 'lib/images/twitter.png'),
                ],
              ),

              const SizedBox(height: 20),

              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Register now',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
