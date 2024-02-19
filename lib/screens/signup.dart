import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/loading_dialog.dart';
import '../services/auth_services.dart';
import '../services/firestore_services.dart';
import 'customer/home.dart';
import 'signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPasswordObscure = true;
  bool isConfirmPasswordObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // label
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 30.0,
                ),
              ),
              // label
              const Text(
                "Sign Up below as Customer",
                style: TextStyle(
                  fontSize: 10.0,
                ),
              ),
              const SizedBox(height: 30.0),
              // email field
              TextFormField(
                validator: (value) {
                  RegExp emailRegExp = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  );

                  if (value == null || value.trim().isEmpty) {
                    return "Enter email address";
                  } else if (!value.contains(emailRegExp)) {
                    return "Enter valid email address";
                  }
                  return null;
                },
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Enter email address",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10.0),
              // password field
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter password";
                  } else if (value.length < 6) {
                    return "Password must be of more than 6 characters";
                  }
                  return null;
                },
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: isPasswordObscure,
                decoration: InputDecoration(
                  hintText: "Enter password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordObscure = !isPasswordObscure;
                        });
                      },
                      icon: Icon(
                        isPasswordObscure ? Icons.visibility_off : Icons.visibility,
                      )),
                ),
              ),
              const SizedBox(height: 10.0),
              // confirm password field
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter confirm password";
                  } else if (passwordController.text != confirmPasswordController.text) {
                    return "Confirm Password and Password must be same";
                  }
                  return null;
                },
                controller: confirmPasswordController,
                obscureText: isConfirmPasswordObscure,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  hintText: "Enter confirm password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isConfirmPasswordObscure = !isConfirmPasswordObscure;
                      });
                    },
                    icon: Icon(
                      isConfirmPasswordObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // btn
              SizedBox(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      LoadingDialog(context);
                      try {
                        await AuthServices.signUp(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        await FirebaseServices.setCurrentUserField({
                          "role": "customer",
                          "email": FirebaseAuth.instance.currentUser!.email,
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomerHome(),
                            ),
                          );
                        }
                      } catch (error) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error.toString(),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Divider(),
              const SizedBox(height: 20.0),
              // inkwell btn
              InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(5.0),
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignIn(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
                  child: Text(
                    "Already have an account? SignIn",
                    style: TextStyle(fontSize: 15.0),
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
