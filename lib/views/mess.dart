import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import '../database/loader.dart';

class MessMenuPage extends StatefulWidget {
  const MessMenuPage({Key? key}) : super(key: key);

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage>
    with SingleTickerProviderStateMixin {
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String modifyDate = "7-5-2024";
  var Modified = null;
  final Map<String, List<MenuItem>> _menu = Menu.menu;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLastModified();
  }

  int _selectedDayIndex = 0;

  Future<void> getLastModified() async {
    var doc = await FirebaseFirestore.instance.collection('MessMenu').doc("Monday").get();
    Modified = doc.data();
    setState(() {
      modifyDate = Modified["modified"];
    });
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
  }

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Mon'),
    Tab(text: 'Tue'),
    Tab(text: 'Wed'),
    Tab(text: 'Thu'),
    Tab(text: 'Fri'),
    Tab(text: 'Sat'),
    Tab(text: 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      initialIndex: initialDay(),
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: Colors.blue,
          title: buildTitleBar("MESS MENU", context),
          bottom: const TabBar(
            labelColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            unselectedLabelColor: Colors.white,
            padding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
              insets: EdgeInsets.symmetric(horizontal: 48),
            ),
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: [
            ..._daysOfWeek.map((day) => _buildMenuList(day,modifyDate)),
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.sync_rounded),
          color: Colors.white,
          iconSize: 28,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        signoutButtonWidget(context),
      ],
    );
  }


Widget _buildLastUpdatedWidget(String lastUpdatedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10), 
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10), // Add border-radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         const  Icon(Icons.update, color: Colors.blue),
        //  const  SizedBox(width: 10),
         const SizedBox(height: 20),
          Text(
            'Last Updated: $lastUpdatedDate',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(String day, String lastUpdatedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLastUpdatedWidget(lastUpdatedDate),
        Expanded(
          child: ListView.builder(
            itemCount: _menu[day]!.length,
            itemBuilder: (context, index) {
              final meal = _menu[day]![index];

              return Column(
                children: [
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Text(
                        meal.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(Icons.food_bank_rounded),
                      subtitle: Text(
                        checkTime(meal.name),
                      ),
                      initiallyExpanded: meal.name == mealOpen() ? true : false,
                      children: [
                        ...parseString(meal.description).map((myMeal) {
                          return ListTile(
                            title: Text(
                              myMeal,
                              style: TextStyle(color: Color(primaryLight)),
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String mealOpen() {
    TimeOfDay now = TimeOfDay.now();

    if ((now.hour > 0 && (now.hour <= 9)) || (now.hour >= 21)) {
      return "Breakfast";
    } else if ((now.hour < 14) && (now.hour > 9)) {
      return "Lunch";
    } else {
      return "Dinner";
    }
  }

  String checkTime(String name) {
    if (name == 'Breakfast') {
      return "7:30 AM to 9:15 AM";
    } else if (name == 'Lunch') {
      return "12:30 PM to 2:15 PM";
    } else {
      return "7:30 PM to 9:15 PM";
    }
  }

  List<String> parseString(String desc) {
    return desc.split(", ");
  }

  int initialDay() {
    DateTime now = DateTime.now();

    if (now.hour <= 22) {
      return now.weekday - 1;
    } else {
      if (now.weekday == 7) {
        return 0;
      } else {
        return now.weekday;
      }
    }
  }
}
