import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/views/club/add_club_event.dart';
import 'package:iitropar/views/club/add_group.dart';
import 'package:iitropar/views/club/club_notifications.dart';
import 'package:iitropar/views/club/manage_groups.dart';
import 'package:iitropar/views/club/manage_members.dart';
import '../../frequently_used.dart';
import '../../utilities/colors.dart';
import '../club/manage_events.dart';
import 'home_page.dart';

class ClubHome extends AbstractHome {
  const ClubHome({super.key});


  @override
  State<AbstractHome> createState() => _ClubHomeState();
}

class _ClubHomeState extends AbstractHomeState {
  String clubName = "";

  _ClubHomeState() {
    firebaseDatabase
        .getClubName(FirebaseAuth.instance.currentUser!.email!)
        .then((value) {
      setState(() {
        clubName = value;
      });
    });
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);
    l.add(SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AdminCard(
                  context, addClubEvent(clubName: clubName), "Add Club Event"),
              AdminCard(
                  context, ManageEvents(clubName: clubName), "Manage Club Events"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AdminCard(
                  context, addClubGroup(clubName: clubName), "Create Group"),
              AdminCard(
                  context, ManageGroupsScreen(clubName: clubName), "Manage Groups"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AdminCard(
                  context, ManageMembersScreen(clubName: clubName), "Manage Group Members "),
              AdminCard(
                  context, ClubNotifications(clubName: clubName), "Notifications"),
            ],
          ),

        ],
      ),
    ));

    return l;
  }
}