import 'package:flutter/material.dart';
import 'package:hotel_booking_app/screens/admin/home.dart';
import 'package:hotel_booking_app/screens/customer/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../component/loading_dialog.dart';
import '../services/auth_services.dart';
import '../services/firestore_services.dart';
import 'signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPasswordObsured = true;

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
                "Sign In",
                style: TextStyle(
                  fontSize: 30.0,
                ),
              ),
              // label
              const Text(
                "Sign In below as Admin or Customer",
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
                obscureText: isPasswordObsured,
                decoration: InputDecoration(
                  hintText: "Enter password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordObsured = !isPasswordObsured;
                      });
                    },
                    icon: Icon(
                      isPasswordObsured ? Icons.visibility_off : Icons.visibility,
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
                        await AuthServices.signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );

                        Map<String, dynamic>? fields = await FirebaseServices.getCurrentUserFields();

                        if (fields != null && fields["role"] != null) {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("role", fields["role"]);

                          if (context.mounted) {
                            if (fields["role"] == "customer") {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CustomerHome(),
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminHome(),
                                ),
                              );
                            }
                          }
                        } else {
                          await AuthServices.signOut();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Something went wrong, try again.",
                                ),
                              ),
                            );
                          }
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
                    "Login",
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
                      builder: (context) => const SignUp(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
                  child: Text(
                    "Don't have an account? SignUp",
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
