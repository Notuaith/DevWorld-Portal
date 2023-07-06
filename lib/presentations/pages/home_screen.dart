import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
//import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:portal/commons/theme.dart';
import 'package:portal/data/models/memo_model.dart';
import 'package:portal/data/models/user_model.dart';
import 'package:portal/presentations/state_management/auth_provider.dart';
import 'package:portal/presentations/state_management/memo_provider.dart';
import 'package:portal/presentations/widgets/home_widget/showcase_widget.dart';
import 'package:portal/presentations/widgets/other_widgets/custom_loader.dart';
import 'package:portal/presentations/widgets/other_widgets/memo.dart';
import 'package:portal/presentations/widgets/other_widgets/memo_painter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double top = 0;
  double left = 0;
  List<MemoModel> memoModel = [];

  bool isRaccomended = true;
  bool showloader = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<MemoListProvider>().getAllMemo();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthProvider>(context).currentUser;
    return Material(
      child: ResponsiveBuilder(builder: (context, size) {
        return Consumer<MemoListProvider>(
            builder: (context, memoProvider, child) {
          return memoProvider.memoList == null
              ? Container(
                  color: Colors.black,
                  width: size.deviceScreenType == DeviceScreenType.mobile
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width - 60,
                  height: MediaQuery.of(context).size.height,
                  child: CustomRiveLoader(
                    isWhite: true,
                  ),
                  // child: Center(
                  //     child: LoadingAnimationWidget.beat(
                  //   color: const Color.fromARGB(255, 255, 177, 59),
                  //   size: 60,
                  // )),
                )
              : size.deviceScreenType == DeviceScreenType.mobile
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Scaffold(
                        floatingActionButton: Padding(
                          padding: const EdgeInsets.only(bottom: 170.0),
                          child: FloatingActionButton(
                              child: Icon(Icons.add),
                              onPressed: () async {
                                await showCreateMemo(user);
                              }),
                        ),
                        body: Container(
                          color: Colors.black,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, bottom: 10),
                                  child: Text(
                                    'Appuntamenti',
                                    style: DWTextTypography.of(context)
                                        .text18bold
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Showcase(
                                  width: MediaQuery.of(context).size.width,
                                ),
                                Text(
                                  'Memo',
                                  style: DWTextTypography.of(context)
                                      .text18bold
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 220,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: memoProvider.memoList!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onLongPress: () async {
                                            await deleteMemoDialog(
                                                memoProvider.memoList![index]);
                                          },
                                          child: Memo(
                                              memo: memoProvider
                                                  .memoList![index]),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      width: MediaQuery.of(context).size.width - 50,
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Bacheca',
                                      style: DWTextTypography.of(context)
                                          .text22bold,
                                    )
                                  ],
                                ),
                              ),
                              Stack(children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(13)),
                                    color: Color.fromARGB(255, 77, 77, 77),
                                  ),
                                  width: MediaQuery.of(context).size.width - 60,
                                  height: 500,
                                  child: Stack(
                                    children: [
                                      for (var i in memoProvider.memoList!)
                                        Positioned(
                                          top: i.top,
                                          left: i.left,
                                          child: Draggable(
                                              onDragUpdate: (details) {
                                                top = details.delta.dy;
                                                left = details.delta.dx;
                                              },
                                              onDragEnd: (details) async {
                                                print('la width è ${MediaQuery.of(context).size.width - 60}',);
                                                setState(() {
                                                  top = details.offset.dy > 500 ? 100 :details.offset.dy ;
                                                  left = details.offset.dx > MediaQuery.of(context).size.width - 80 ? 100:details.offset.dx ;
                                                  i.top = top;
                                                  i.left = left;
                                                  print('top è${top}');
                                                  print('left è${left}');
                                                });
                                                await context
                                                    .read<MemoListProvider>()
                                                    .storeNewPosition(MemoModel(
                                                        top: top,
                                                        left: left,
                                                        userId: i.userId,
                                                        id: i.id,
                                                        body: i.body));
                                              },
                                              feedback: Memo(
                                                memo: i,
                                              ),
                                              child: GestureDetector(
                                                  onLongPress: () async {
                                                    await deleteMemoDialog(i);
                                                  },
                                                  child: Memo(memo: i))),
                                        )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 60,
                                  height: 500,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: GestureDetector(
                                        onTap: () async {
                                          await showCreateMemo(user);
                                        },
                                        child: const CircleAvatar(
                                          child: Icon(Icons.add),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                              Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Comunicazioni',
                                      style: DWTextTypography.of(context)
                                          .text22bold,
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Showcase(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                  //  Showcase(),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
        });
      }),
    );
  }

  Future<void> deleteMemoDialog(MemoModel memo) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 500,
            height: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'lib/resources/images/devworld.png',
                    width: 200,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: Text('Sei sicuro di voler cancellare questo Memo?'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, top: 25),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            width: 150,
                            height: 45,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                'Cancella Memo',
                                style: DWTextTypography.of(context).text18,
                              ),
                            )),
                      ],
                    ),
                    onTap: () async {
                      await context.read<MemoListProvider>().deleteMemo(memo);
                      await context.read<MemoListProvider>().getAllMemo();
                      if (mounted) {
                        AutoRouter.of(context).pop();
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showCreateMemo(UserModel user) async {
    TextEditingController memoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'lib/resources/images/devworld.png',
                    width: 200,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(
                                200,
                                (200 * 1.0516378413201843)
                                    .toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
                            painter: RPSCustomPainter(),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: SizedBox(
                                width: 170,
                                height: 170,
                                child: TextField(
                                  controller: memoController,
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 7,
                                  decoration: const InputDecoration(
                                      isDense: false, border: InputBorder.none),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 40.0, top: 25),
                  child: SizedBox(
                    width: 500,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await context.read<MemoListProvider>().publishMemo(
                                body: memoController.text, userId: user.uid);
                            await context.read<MemoListProvider>().getAllMemo();
                            if (mounted) {
                              AutoRouter.of(context).pop();
                            }
                          },
                          child: Container(
                            width: 130,
                            height: 35,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(7),
                                ),
                                color: Colors.blue),
                            child: const SizedBox(
                              height: 200,
                              width: 100,
                              child: Center(
                                  child: Text(
                                'Salva',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
