import 'package:flutter/material.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:intl/intl.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:firebase_storage/firebase_storage.dart';

double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

class StudentHome extends AbstractHome {
  const StudentHome({super.key});

  @override
  State<AbstractHome> createState() => _StudentHomeState();
}

String getDay() {
  return DateFormat('EEEE').format(DateTime.now());
}

Future<String> getImageUrl(String item) async {
  try {
    Reference storageReference = FirebaseStorage.instance.ref().child('$item.png');
    String downloadUrl = await storageReference.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    return ''; // Return empty string to indicate file not found
  }
}

Widget buildItems(String item) {
  item = item.replaceAll("/", "_");
  return FutureBuilder(
    future: getImageUrl(item),
    builder: (context, AsyncSnapshot<String> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(primaryLight),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/food_logo.png')
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item,
                  style: TextStyle(fontSize: 14, color: Color(primaryLight)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        String imageUrl = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(primaryLight),
                  child:CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                    child:Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return  Image.asset(
                        'assets/food_logo.png',
                        fit: BoxFit.cover,);
                         },),
                ),
                ),
                const SizedBox(height: 5),
                Text(
                  item,
                  style: TextStyle(fontSize: 14, color: Color(primaryLight)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}


Widget divider() {
  return const Divider(
    color: Colors.black,
    height: 30,
    thickness: 1,
    indent: 30,
    endIndent: 30,
  );
}
Widget todayMenu() {
  String currentMeal = "Dinner";
  int idx = 0;
  double maxBfTime = toDouble(const TimeOfDay(hour: 9, minute: 30));
  double maxLunchTime = toDouble(const TimeOfDay(hour: 14, minute: 30));
  double curTime = toDouble(TimeOfDay.now());
  if (curTime < maxBfTime) {
    idx = 0;
    currentMeal = "Breakfast";
  } else if (curTime < maxLunchTime) {
    idx = 1;
    currentMeal = "Lunch";
  } else {
    idx = 2;
    currentMeal = "Dinner";
  }
  List<String> items = Menu.menu[getDay()]![idx].description.split(',');

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Hungry? See what\'s there for $currentMeal',
              style: TextStyle(
                color: Color(primaryLight),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: items.map(buildItems).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StudentHomeState extends AbstractHomeState {
  List<Event> tomorrowevents = [];
  List<Event> todayevents = [];
  bool showRightArrow = true;
  bool showLeftArrow = false;
  @override
  void initState() {
    super.initState();
    loadEventstoday();
    loadEventstomorrow();
  }
  Future<void> loadEventstoday() async {
    try {
      List<Event> loadedTodayEvents =
          await EventDB().fetchEvents(DateTime.now());
      setState(() {
        todayevents = loadedTodayEvents;
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<void> loadEventstomorrow() async {
    try {
      List<Event> loadedTomorrowEvents =
          await EventDB().fetchEvents(DateTime.now().add(const Duration(days: 1)));
      setState(() {
        tomorrowevents = loadedTomorrowEvents;
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Widget todayEvents() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Today's Events",
            style: TextStyle(
              color: Color(primaryLight),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        gettodayEvents(),
      ],
    );
  }

  Widget tomorrowEvents() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Tomorrow's Events",
            style: TextStyle(
              color: Color(primaryLight),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        gettomorrowEvents(),
      ],
    );
  }

  Widget eventWidget(Event myEvents) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        leading: Icon(
          Icons.book,
          color: Color(primaryLight),
        ),
        title: Text(
          myEvents.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Description: ",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        myEvents.desc,
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Time: ",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${myEvents.stime.format(context)} - ${myEvents.etime.format(context)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Venue: ",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      myEvents.venue,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Host: ",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      myEvents.host,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget gettodayEvents() {
    if (todayevents.isEmpty) {
      return const Center(
        child: Text('No events scheduled for today'),
      );
    } else {
      todayevents.sort((a, b) {
        int startComparison = a.stime.hour.compareTo(b.stime.hour);
        if (startComparison != 0) {
          return startComparison;
        } else {
          return a.stime.minute.compareTo(b.stime.minute);
        }
      });
      return Column(
        children: todayevents.map((event) {
          return eventWidget(event);
        }).toList(),
      );
    }
  }



  Widget gettomorrowEvents() {
    if (tomorrowevents.isEmpty) {
      return const Center(
        child: Text('No events scheduled for tomorrow'),
      );
    } else {
      tomorrowevents.sort((a, b) {
        int startComparison = a.stime.hour.compareTo(b.stime.hour);
        if (startComparison != 0) {
          return startComparison;
        } else {
          return a.stime.minute.compareTo(b.stime.minute);
        }
      });
      return Column(
        children: tomorrowevents.map((event) {
          return eventWidget(event);
        }).toList(),
      );
    }
  }






  Widget intermediateText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "What's happening today?",
        style: TextStyle(
          color: Color(primaryLight),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = [];

    // Add widgets to the list
    //l.add(todayMenu());
    l.add(ArrowListView());
    l.add(intermediateText());
    l.add(todayEvents());
    l.add(const SizedBox(height: 20));
    l.add(tomorrowEvents());
    l.add(const SizedBox(height: 20));

    return l;
  }
}

class ArrowListView extends StatefulWidget {
  const ArrowListView({Key? key}) : super(key: key);

  @override
  _ArrowListViewState createState() => _ArrowListViewState();
}

class _ArrowListViewState extends State<ArrowListView> {
  String currentMeal = "Dinner";
  int idx = 0;
  final double maxBfTime = toDouble(const TimeOfDay(hour: 9, minute: 30));
  final double maxLunchTime = toDouble(const TimeOfDay(hour: 14, minute: 30));
  double curTime = toDouble(TimeOfDay.now());
  bool showRightArrow = true;
  bool showLeftArrow = false;
  List<String> items = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initItems();
  }

  void initItems() {
    if (curTime < maxBfTime) {
      idx = 0;
      currentMeal = "Breakfast";
    } else if (curTime < maxLunchTime) {
      idx = 1;
      currentMeal = "Lunch";
    } else {
      idx = 2;
      currentMeal = "Dinner";
    }
    items = Menu.menu[getDay()]![idx].description.split(',');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0), 
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                initiallyExpanded: false,
                title: Text(
                  'Hungry? See what\'s there for $currentMeal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(primaryLight),
                  ),
                ),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30, 
                        child: Visibility(
                          visible: showLeftArrow,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.offset -116,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 110,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: handleScrollNotification,
                            child: ListView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              children: items.map(buildItems).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30, 
                        child: Visibility(
                          visible: showRightArrow,
                          child: IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: () {
                              _scrollController.animateTo(
                                _scrollController.offset + 116,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (notification.metrics.extentAfter == 0) {
        setState(() {
          showRightArrow = false;
        });
      } else {
        setState(() {
          showRightArrow = true;
        });
      }

      if (notification.metrics.extentBefore == 0) {
        setState(() {
          showLeftArrow = false;
        });
      } else {
        setState(() {
          showLeftArrow = true;
        });
      }
    }
    return true;
  }
}
