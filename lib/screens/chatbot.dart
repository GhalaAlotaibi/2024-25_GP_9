import 'package:flutter/material.dart';
import 'package:tracki/Utils/constants.dart';
import 'package:tracki/widgets/my_icon_button.dart';

class ChatbotUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          const SizedBox(width: 15),
          const Spacer(),
          MyIconButton(
            icon: Icons.arrow_forward_ios,
            pressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),  
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'مرحبا',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
            
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF674188),  
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'مرحبًا! كيف يمكنني مساعدتك؟',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              
              ],
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textAlign:
                        TextAlign.end,  
                    textDirection: TextDirection
                        .rtl, 
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0),  
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF674188)),
                  onPressed: () {
                   
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
