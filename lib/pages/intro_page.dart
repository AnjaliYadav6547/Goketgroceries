import 'package:flutter/material.dart';
import 'package:flutter_application/pages/home_page.dart';

class IntroPage extends StatelessWidget{
  const IntroPage ({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric( horizontal:25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Image.asset(
                  'lib/images/nike.png',
                  height: 240,
                                )
              ),
              const SizedBox(height: 48),

              //title
              const Text(
                'NIKE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )
              ),
              //sub title
              const Text(
                'Brand new',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,

                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              //start now button
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                   MaterialPageRoute(
                    builder: (context) => HomePage(), 
                    ),
                  ),
                  
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),

                    ),
                    padding: const EdgeInsets.all(25),
                    child: const Center(
                      child: Text(
                        'Shop Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                       )
                            )       
                            
                             ),
              )

              )
            
            
        


          ],))
      )
        


    );
  }
}