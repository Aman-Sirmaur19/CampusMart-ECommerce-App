import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper/api.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: WhatsappAppbar(MediaQuery.of(context).size.width),
            pinned: true,
          ),
          const SliverToBoxAdapter(
            child: Column(
              children: [NameAndEmail(), ProfileIconButtons()],
            ),
          ),
          const WhatsappProfileBody()
        ],
      ),
    );
  }
}

class WhatsappAppbar extends SliverPersistentHeaderDelegate {
  double screenWidth;
  Tween<double>? profilePicHorizontalTranslateTween;
  Tween<double>? profilePicVerticalTranslateTween;

  WhatsappAppbar(this.screenWidth) {
    profilePicHorizontalTranslateTween =
        Tween<double>(begin: screenWidth / 2 - 70, end: 40.0);
    profilePicVerticalTranslateTween =
        Tween<double>(begin: screenWidth / 2 - 110, end: 30.0);
  }

  static final appBarColorTween =
      ColorTween(begin: Colors.white, end: Colors.blue.shade100);

  static final appbarIconColorTween =
      ColorTween(begin: Colors.blue, end: Colors.black);

  static final phoneNumberTranslateTween = Tween<double>(begin: 20.0, end: 0.0);

  static final phoneNumberFontSizeTween = Tween<double>(begin: 20.0, end: 16.0);

  static final profileImageRadiusTween = Tween<double>(begin: 3.5, end: 1.0);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final relativeScroll = min(shrinkOffset, 60) / 60;
    final relativeScroll120px = min(shrinkOffset, 120) / 120;

    return Container(
      color: appBarColorTween.transform(relativeScroll),
      child: Stack(
        children: [
          Stack(
            children: [
              Positioned(
                left: 0,
                top: 25,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                  icon: const Icon(CupertinoIcons.back),
                  color: appbarIconColorTween.transform(relativeScroll),
                ),
              ),
              Positioned(
                  top: 38,
                  left: 90,
                  child: displayPhoneNumber(relativeScroll120px)),
              Positioned(
                  top: profilePicVerticalTranslateTween!
                      .transform(relativeScroll120px),
                  left: profilePicHorizontalTranslateTween!
                      .transform(relativeScroll120px),
                  child: displayProfilePicture(relativeScroll120px)),
              Positioned(
                right: 0,
                top: 25,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 25),
                  color: appbarIconColorTween.transform(relativeScroll),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget displayProfilePicture(double relativeFullScrollOffset) {
    return Transform(
      transform: Matrix4.identity()
        ..scale(
          profileImageRadiusTween.transform(relativeFullScrollOffset),
        ),
      child: const CircleAvatar(
        backgroundImage: NetworkImage(
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEgzwHNJhsADqquO7m7NFcXLbZdFZ2gM73x8I82vhyhg&s"),
      ),
    );
  }

  Widget displayPhoneNumber(double relativeFullScrollOffset) {
    if (relativeFullScrollOffset >= 0.8) {
      return Transform(
        transform: Matrix4.identity()
          ..translate(
            0.0,
            phoneNumberTranslateTween
                .transform((relativeFullScrollOffset - 0.8) * 5),
          ),
        child: Text(
          APIs.me.name,
          style: TextStyle(
            fontSize: phoneNumberFontSizeTween
                .transform((relativeFullScrollOffset - 0.8) * 5),
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  double get maxExtent => 200;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(WhatsappAppbar oldDelegate) {
    return true;
  }
}

class WhatsappProfileBody extends StatelessWidget {
  const WhatsappProfileBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      const SizedBox(height: 20),
      ListTile(
        title: Text(APIs.me.phoneNumber),
        leading: const Icon(Icons.phone),
      ),
      ListTile(
        title: Text(APIs.me.college),
        leading: const Icon(Icons.school),
      ),
      ListTile(
        title: Text(APIs.me.year),
        leading: const Icon(Icons.calendar_today),
      ),
      // to fill up the rest of the space to enable scrolling
      const SizedBox(
        height: 500,
      ),
    ]));
  }
}

class ProfileIconButtons extends StatelessWidget {
  const ProfileIconButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Icon(
              Icons.call,
              size: 30,
              color: Color.fromARGB(255, 8, 141, 125),
            ),
            SizedBox(height: 5),
            Text(
              "Call",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 8, 141, 125),
              ),
            )
          ],
        ),
        SizedBox(width: 20),
        Column(
          children: [
            Icon(
              Icons.video_call,
              size: 30,
              color: Color.fromARGB(255, 8, 141, 125),
            ),
            SizedBox(height: 5),
            Text(
              "Video",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 8, 141, 125),
              ),
            )
          ],
        ),
        SizedBox(width: 20),
        Column(
          children: [
            Icon(
              Icons.save,
              size: 30,
              color: Color.fromARGB(255, 8, 141, 125),
            ),
            SizedBox(height: 5),
            Text(
              "Save",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 8, 141, 125),
              ),
            )
          ],
        ),
        SizedBox(width: 20),
        Column(
          children: [
            Icon(
              Icons.search,
              size: 30,
              color: Color.fromARGB(255, 8, 141, 125),
            ),
            SizedBox(height: 5),
            Text(
              "Search",
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 8, 141, 125),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class NameAndEmail extends StatelessWidget {
  const NameAndEmail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 35),
        Text(
          APIs.me.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "~${APIs.me.email}",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
