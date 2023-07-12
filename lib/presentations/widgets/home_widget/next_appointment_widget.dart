import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:portal/commons/theme.dart';
import 'package:portal/commons/utils.dart';
import 'package:portal/presentations/state_management/appointment_detail_provider.dart';
import 'package:portal/presentations/state_management/appointment_list_provider.dart';
import 'package:portal/presentations/widgets/other_widgets/custom_loader.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NextAppointmentwidget extends StatefulWidget {
  final String userId;
  const NextAppointmentwidget({super.key, required this.userId});

  @override
  State<NextAppointmentwidget> createState() => _NextAppointmentwidgetState();
}

class _NextAppointmentwidgetState extends State<NextAppointmentwidget> {
  List<String> selectedIdsList = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    await context.read<AppointmentListProvider>().getNextAppointmentAvailable(widget.userId);
    await context.read<AppointmentDetailProvider>().cleanUserList();
    await context.read<AppointmentDetailProvider>().getAppointmentUserListById(
        userIds: [widget.userId]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppointmentListProvider, AppointmentDetailProvider>(
        builder: (context, providerList, providerDetail, _) {
 
      return providerList.nextAppointmentList == null
          ? CustomRiveLoader(isWhite: true)
          : providerList.nextAppointmentList!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Container(
                    height: 135,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.23,
                                height: 117,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.2),
                                    color: providerList
                                        .nextAppointmentList!.first.color,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      formattedMonth(providerList
                                              .nextAppointmentList!
                                              .first
                                              .startTime)
                                          .toUpperCase(),
                                      style: DWTextTypography.of(context)
                                          .text18bold,
                                    ),
                                    Text(
                                      formattedDay(
                                        providerList.nextAppointmentList!.first
                                            .startTime,
                                      ),
                                      style: DWTextTypography.of(context)
                                          .text18bold,
                                    ),
                                    // Text(formattedTime( providerList.nextAppointmentList!.first.startTime), style: DWTextTypography.of(context).text16bold,),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row(
                                //   children: [
                                //     Text(
                                //     formattedDate(DateTime.now()))
                                //   ],
                                // )
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 125,
                                        child: Text(
                                          providerList.nextAppointmentList!
                                              .first.subject,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: DWTextTypography.of(context)
                                              .text16bold
                                              .copyWith(color: Colors.black),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            ' ${formattedTime(providerList.nextAppointmentList!.first.startTime)} - ',
                                            style: DWTextTypography.of(context)
                                                .text16
                                                .copyWith(color: Colors.black),
                                          ),
                                          Text(
                                            formattedTime(providerList
                                                .nextAppointmentList!
                                                .first
                                                .endTime),
                                            style: DWTextTypography.of(context)
                                                .text16
                                                .copyWith(color: Colors.black),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launchURL(providerList
                                            .nextAppointmentList!.first.url ??
                                        '');
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.65,
                                    child: AutoSizeText(
                                      providerList
                                              .nextAppointmentList!.first.url ??
                                          '',
                                      overflow: TextOverflow.ellipsis,
                                      maxFontSize: 16,
                                      minFontSize: 10,
                                      style: TextStyle(color: Colors.blue),
                                      // style: DWTextTypography.of(context)
                                      //     .text16
                                      //     .copyWith(color: Colors.blue),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Partecipanti',
                                    style: DWTextTypography.of(context)
                                        .text16bold
                                        .copyWith(color: Colors.black),
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: providerDetail
                                            .userListById?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        
                                        child: Text(providerDetail.userListById![index].name),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 90,
                  child: Center(
                    child: Text(
                      'Non ci sono appuntamenti programmati',
                      style: DWTextTypography.of(context).text16,
                    ),
                  ),
                );
    });
  }

  void launchURL(String firebaseUrl) async {
    final url = Uri.encodeFull(firebaseUrl);
    await launchUrl(Uri.parse(url));
  }
}
