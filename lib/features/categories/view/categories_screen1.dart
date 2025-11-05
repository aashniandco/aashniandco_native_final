import 'package:flutter/material.dart';

class CategoriesScreen1 extends StatefulWidget {
  const CategoriesScreen1({super.key});

  @override
  State<CategoriesScreen1> createState() => _CategoriesScreen1State();
}

class _CategoriesScreen1State extends State<CategoriesScreen1> {
    final List<Map<String, String>> items = [
    {
      'title': 'New In',
      'image': 'assets/shopping_bags.jpg',
    },
    {
      'title': 'Card 2',
      'image': 'assets/images/image2.jpg',
    },
    {
      'title': 'Card 3',
      'image': 'assets/images/image3.jpg',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (BuildContext context,int index){
          return Card(
            child: Stack(
              children: [
                //bg colour
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5)  
                  ),
                ),

                //Image
           ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  items[index]['image']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
               Positioned(
                bottom: 10,
                left: 10,
                child: Text(
                  items[index]['title']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
          
              ],
            ),
          );
               

        }),
    );
  }
}