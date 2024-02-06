import 'package:flutter/material.dart';
import 'package:uni_market/components/navbar.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: NavBar(),
      body: SelectionArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/logo_circle.png'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Uni-Market',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Team 40, CS 426 Senior Project in Computer Science, Spring 2023, CSE Department, University of Nevada, Reno',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Uni-Market is a marketplace exclusively for verified university members. Within Uni-Market, users will engage in buying and selling items with confidence that the engagement is with another verified member of their academic institution or one of close proximity. Available cross-platform and across different operating systems thanks to Flutter and Firebase, users may download the application on a device of their convenience or visit our website on a browser of their choice.\n\nThe platform will feature a system where users can message the seller directly on the app to negotiate price or find a place to meet to conduct the sale. To reduce friction, Uni-Market will also recommend a meeting spot between both users to ensure there is no arguing over a meeting location. With an admin site to manually monitor posts caught by the auto-flagging system, users can rest assured that every item they look at will be safe to purchase. Uni-Market will also host payments on the app, holding the payment until both parties confirm the transaction has been completed. Finally, Uni-Market is secure with multi-factor authentication to keep our users safe from potential risks and vulnerabilities. Let’s rethink the way we buy and sell academic resources with Uni-Market!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Meet Our Instructors & Advisors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Add horizontal team profile cards
              SizedBox(
                height: 271,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: const [
                    TeamMemberCard(
                      name: 'David Feil-Seifer',
                      role: 'Instructor, CSE, University of Nevada, Reno',
                      bio: null,
                      image: 'assets/portraits/david.jpg',
                    ),
                    TeamMemberCard(
                      name: 'Devrin Lee',
                      role: 'Instructor, CSE, University of Nevada, Reno',
                      bio: null,
                      image: 'assets/portraits/devrin.jpg',
                    ),
                    TeamMemberCard(
                      name: 'Sara Davis',
                      role: 'Instructor, CSE, University of Nevada, Reno',
                      bio: null,
                      image: 'assets/portraits/sara.jpg',
                    ),
                    TeamMemberCard(
                      name: 'Elke Folmer',
                      role:
                          'External Advisor & CSE Department Chair, University of Nevada, Reno',
                      bio: null,
                      image: 'assets/portraits/elke.jpg',
                    ),
                    // Add more team members as needed
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Meet Our Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 320,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: const [
                    TeamMemberCard(
                      name: 'Nikhil Sharma',
                      role: 'Project Manager & Dev Ops',
                      bio:
                          'Bachelors of Science in Computer Science and Engineering.\nExpected Graduation: May 2024.',
                      image: 'assets/portraits/nikhil.jpeg',
                    ),
                    TeamMemberCard(
                      name: 'Jacob Hunter',
                      role: 'CTO',
                      bio:
                          'Bachelor of Science in Computer Science and Engineering.\nExpected Graduation: December 2024.',
                      image: 'assets/portraits/jacob.webp',
                    ),
                    TeamMemberCard(
                      name: 'Cameron McCoy',
                      role: 'Full Stack Development',
                      bio:
                          'B.S. Computer Science & Engineering / Biology \nExpected Graduation: May 2024',
                      image: 'assets/portraits/cameron.webp',
                    ),
                    TeamMemberCard(
                      name: 'Yeamin Chowdhury',
                      role: 'CTO',
                      bio:
                          'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      image: 'assets/portraits/yeamin.webp',
                    ),
                    // Add more team members as needed
                  ],
                ),
              ),
              SizedBox(
                width: screenWidth * 0.75,
                child: const Column(
                  children: <Widget>[
                    Text(
                      'Project Related Resources',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Books',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Problem Domain Book: The Lean Marketplace: A Practical Guide to Building a Successful Online Marketplace Business\n\nJuho Makkonen, Cristóbal Gracia. The Lean Marketplace: A Practical Guide to Building a Successful Online Marketplace Business. Sharetribe, February 28, 2018. None of the marketplaces listed above were built in a day. Each one had to go through the slow process of learning by doing. This book is designed to help give you a head start with your own marketplace idea and avoid the most common pitfalls.\n\nFlutter and Dart Cookbook: Developing Full-Stack Applications for the Cloud\n\nRichard Rose. Flutter and Dart Cookbook: Developing Full-Stack Applications for the Cloud. O\'Reilly Media; 1st edition, January 24, 2023. Building applications involves lots of moving pieces as well as integrating with external services. Learn the fundamentals of working with the Firebase suite and take your first steps with Cloud. Learn flutter and dart while building full stack applications for any industry all with one codebase.\n',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Articles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'The social infrastructure of online marketplaces: Trade, work and the interplay of decided and emergent orders\n\nAspers P, Darr A. The social infrastructure of online marketplaces: Trade, work and the interplay of decided and emergent orders. Br J Sociol. 2022 Sep;73(4):822-838. doi: 10.1111/1468-4446.12965. Epub 2022 June 30. PMID: 35771185; PMCID: PMC9540661. This article goes over the social relationship between the sellers and buyers within a marketplace. Analyzing multiple online marketplaces and trading platforms, it leads to examples of price settings and the distinction of a large-name trade site versus a locally fostered marketplace.\n\nManagement of Trust in the E-Marketplace: The Role of the Buyer\'s Experience in Building Trust\n\nKim, M.-S., & Ahn, J.-H. (2007). Management of Trust in the E-Marketplace: The Role of the Buyer’s Experience in Building Trust. Journal of Information Technology, 22(2), 119-132. https://doi.org/10.1057/palgrave.jit.2000095. This article talks about the communication side of a buyer and seller relationship and how the seller has to build trust with the buyer. Reinforces the concept of Uni-Market and gives additional ideas on how the platform could be better. The outcome relies on the experience of the transaction.\n\nUsing Google´s Flutter Framework for the Development of a Large-Scale Reference Application\n\nFaust, Sebastian. “Using Google´s Flutter Framework for the Development of a Large-Scale Reference Application.” (2020). This article provides an excellent guideline on how to set up a flutter project for large scale development. Going over the development process, team dynamic, the challenges and the benefits of using Google’s flutter framework. It provides the testimony of industry experts and how they were able to curate their projects with Flutter’s help.\n',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Websites',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'https://docs.flutter.dev/\n\nThis link is pointed to the official Flutter documents. It is single-handedly the most helpful resource for Uni-Market. It goes over tutorials to accomplish various parts of a Flutter project as well as common fixes to common problems. It has examples of various development practices when developing in the programming language Dart.\n\nhttps://altar.io/eight-steps-follow-build-successful-marketplace/\n\nThis website link is to an article that explains how to build a successful marketplace. It goes over attributes of how to choose a viable industry, a unique value proposition, market size, and marketing strategies. Overall, a good article that guides the process for solving the problem that Uni-Market seeks to solve.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String? bio;
  final String image;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.role,
    required this.bio,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              image,
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                bio != null ? const SizedBox(height: 8) : const SizedBox(),
                bio != null
                    ? Text(
                        bio!,
                        style: const TextStyle(fontSize: 14),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
