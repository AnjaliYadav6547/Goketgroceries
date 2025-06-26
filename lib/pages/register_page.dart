import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
import 'package:flutter_application/components/square_tile.dart';
import 'home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget{
  final Function()? onTap;
  const RegisterPage ({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordContoller = TextEditingController();
  final confirmpasswordContoller = TextEditingController();

  // //error message
  // void showErrorMessage(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Error'),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('OK'),
  //         )
  //       ],
  //     ),
  //   );
  // }


  //sign user in method
  void signUserUp(BuildContext context) async {
    // Validate inputs
    if (emailController.text.isEmpty || 
        passwordContoller.text.isEmpty || 
        confirmpasswordContoller.text.isEmpty) {
      showErrorMessage("Please fill in all fields");
      return;
    }

    if (passwordContoller.text != confirmpasswordContoller.text) {
      showErrorMessage("Passwords don't match!");
      return;
    }

    if (passwordContoller.text.length < 6) {
      showErrorMessage("Password must be at least 6 characters");
      return;
    }

    //show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordContoller.text,
      );

      //pop the loading circle
      Navigator.pop(context);
      
      // Show success message and redirect to login
      showSuccessMessage("Registration successful! Please login");
      
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = "Email is already in use";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled";
          break;
        case 'weak-password':
          errorMessage = "Password is too weak";
          break;
        default:
          errorMessage = "Registration failed: ${e.message}";
      }
      showErrorMessage(errorMessage);
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage("An unexpected error occurred");
    }
  }

  // success message after register
  void showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onTap?.call(); // This will toggle back to login page
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),

              //logo
              const Icon(
                Icons.lock,
                size: 50,
              ),

              const SizedBox(height: 25),

              //Let's create an account for you!
              Text(
                'Let\'s create an account for you!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25 ),

              //email textfield
              MyTextfield(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              //paswword textfield
              MyTextfield(
                controller: passwordContoller,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              //confirm paswword textfield
              MyTextfield(
                controller: confirmpasswordContoller,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 25),

              //sign in button
              MyButton(
                text: "Sign Up",
                onTap: () => signUserUp(context),
              ),

              const SizedBox(height: 25),

              //or continue with
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

              const SizedBox(height: 50),

              //google + apple sign in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  //google button
                  SquareTile(imagePath: 'lib/images/google.png'),

                  SizedBox(width: 10),

                  //apple button
                  SquareTile(imagePath: 'lib/images/apple.png'),

                ],
              ),
              const SizedBox(height: 50),

              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage(onTap: widget.onTap!,)),
                    );
                    },
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )

                ],
              )



          ],),)) 

      );
  
  }
}