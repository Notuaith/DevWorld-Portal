import 'package:flutter/material.dart';
import 'package:portal/commons/theme.dart';
import 'package:portal/presentations/pages/all_documents_screen.dart';
import 'package:portal/presentations/pages/calendar_screen.dart';
import 'package:portal/presentations/pages/employee_screen.dart';
import 'package:portal/presentations/pages/home_screen.dart';
import 'package:portal/presentations/widgets/other_widgets/custom_loader.dart';
import 'package:provider/provider.dart';
import 'package:portal/commons/enum.dart';
import 'package:portal/presentations/state_management/auth_provider.dart';
import 'package:portal/presentations/pages/splash_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  List<Widget> bodyWidget = [
    const HomeScreen(),
    const CalendarScreen(),
    const EmployeeScreen(),
    const AllDocumentsScreen()
  ];
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthProvider>(context).currentUser;
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      if (auth.status == Status.unauthenticated) {
        return const SplashScreen();
      } else if (auth.status == Status.authenticated) {
        return Material(
          child: ResponsiveBuilder(builder: (context, size) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                  //backgroundColor: Colors.black,
                  appBar: size.deviceScreenType == DeviceScreenType.mobile
                      ? PreferredSize(
                          //todo for web set app bar a 50
                          preferredSize: const Size.fromHeight(100),
                          child: Container(
                            //todo for web set app bar a 50
                            decoration:
                                BoxDecoration(color: Colors.black, boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  color: Colors.white.withOpacity(0.3),
                                  offset: Offset(0, 1))
                            ]),
                            height: 100,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, top: 50.0, bottom: 10, right: 10),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      "lib/resources/images/LogoDefinitivoBianco.png",
                                      width: 170,
                                    ),
                                    PopupMenuButton<Options>(
                                      iconSize: 25,
                                      padding: const EdgeInsets.all(0),
                                      offset: const Offset(0, 50),
                                      icon: const Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                      ),
                                      onSelected: (value) {
                                        switch (value) {
                                          case Options.home:
                                            setState(() {
                                              selectedIndex = 0;
                                            });
                                            break;
                                          case Options.calendario:
                                            setState(() {
                                              selectedIndex = 1;
                                            });
                                            break;
                                          case Options.documenti:
                                            setState(() {
                                              if (user.isAdmin) {
                                                selectedIndex = 2;
                                              } else {
                                                selectedIndex = 3;
                                              }
                                            });

                                            break;
                                          case Options.logout:
                                            setState(() {
                                              showLogoutDialog();
                                            });
                                            break;
                                          default:
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        _buildPopupMenuItem(
                                            'Home', Options.home),
                                        _buildPopupMenuItem(
                                            "calendario", Options.calendario),
                                        _buildPopupMenuItem(
                                            "documenti", Options.documenti),
                                        _buildPopupMenuItem(
                                            "logout", Options.logout),
                                      ],
                                    )
                                  ]),
                            ),
                          ),
                        )
                      : const PreferredSize(
                          preferredSize: Size.fromHeight(0), child: SizedBox()),
                  body: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(children: [
                      Row(
                        children: [
                          size.deviceScreenType == DeviceScreenType.mobile
                              ? const SizedBox()
                              : Container(
                                  width: 50,
                                  height: MediaQuery.of(context).size.height,
                                  color: Color.fromARGB(255, 49, 49, 49),
                                  child: Column(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedIndex = 0;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.home,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedIndex = 1;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.calendar_month,
                                            size: 25,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (user.isAdmin) {
                                                selectedIndex = 2;
                                              } else {
                                                selectedIndex = 3;
                                              }
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.folder,
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                          )),
                                      Expanded(child: Container()),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: IconButton(
                                            onPressed: () async {
                                              await context
                                                  .read<AuthProvider>()
                                                  .signOut();
                                            },
                                            icon: const Icon(Icons.logout,
                                                color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            child: bodyWidget.elementAt(selectedIndex),
                          )
                        ],
                      )
                    ]),
                  ),
                  //todo commenta ogni volta cge deploy sul
                  bottomNavigationBar: size.deviceScreenType ==
                          DeviceScreenType.mobile
                      ? Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 33, vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 0;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.home,
                                        color: selectedIndex == 0
                                            ? Colors.blue
                                            : Colors.white,
                                        size: 33,
                                      ),
                                      Text(
                                        'Home',
                                        style: DWTextTypography.of(context)
                                            .text12
                                            .copyWith(
                                              color: selectedIndex == 0
                                                  ? Colors.blue
                                                  : Colors.white,
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = 1;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: selectedIndex == 1
                                            ? Colors.blue
                                            : Colors.white,
                                        size: 33,
                                      ),
                                      Text(
                                        'Calendario',
                                        style: DWTextTypography.of(context)
                                            .text12
                                            .copyWith(
                                              color: selectedIndex == 1
                                                  ? Colors.blue
                                                  : Colors.white,
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (user.isAdmin) {
                                        selectedIndex = 2;
                                      } else {
                                        selectedIndex = 3;
                                      }
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.folder,
                                        color: selectedIndex == 2 ||
                                                selectedIndex == 3
                                            ? Colors.blue
                                            : Colors.white,
                                        size: 33,
                                      ),
                                      Text(
                                        'File',
                                        style: DWTextTypography.of(context)
                                            .text12
                                            .copyWith(
                                              color: selectedIndex == 2 ||
                                                      selectedIndex == 3
                                                  ? Colors.blue
                                                  : Colors.white,
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await showLogoutDialog();
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color: selectedIndex == 4
                                            ? Colors.blue
                                            : Colors.white,
                                        size: 33,
                                      ),
                                      Text(
                                        'Logout',
                                        style: DWTextTypography.of(context)
                                            .text12
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      : const SizedBox.shrink()),
            );
          }),
        );
      }
      return Center(
        child: CustomRiveLoader(
          isWhite: true,
        ),
      );
    });
  }

  Future<void> showLogoutDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white,
                    ]),
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: SizedBox(
                    width: 400,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'lib/resources/images/devworld.png',
                          width: 140,
                        )
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(width: 400, child: Divider()),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 50.0),
                  child: SizedBox(
                      width: 200,
                      child: Text(
                        'Sei Sicuro di voler effettuare il logout?',
                        textAlign: TextAlign.center,
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: MaterialButton(
                        onPressed: () async {
                          await context.read<AuthProvider>().signOut();
                        },
                        child: Container(
                            width: 80,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red),
                            child: Center(
                                child: Text(
                              'Logout',
                              style: DWTextTypography.of(context).text16,
                            ))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

PopupMenuItem<Options> _buildPopupMenuItem(String title, Options position) {
  return PopupMenuItem<Options>(
    value: position,
    child: Column(
      children: [
        GestureDetector(child: Text(title)),
      ],
    ),
  );
}
