import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:portal/commons/utils.dart';
import 'package:portal/data/data_sorce/calendar_data_source.dart';
import 'package:portal/data/models/user_model.dart';
import 'package:portal/presentations/state_management/appointment_detail_provider.dart';
import 'package:portal/presentations/state_management/appointment_list_provider.dart';
import 'package:portal/presentations/state_management/auth_provider.dart';
import 'package:portal/presentations/state_management/new_appointment_provider.dart';
import 'package:portal/presentations/state_management/user_provider.dart';
import 'package:portal/presentations/widgets/calendar_widget/color_picker.dart';
import 'package:portal/presentations/widgets/calendar_widget/date_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:rive/rive.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedStartDate = DateTime.now();
  List<String> selectedIdsList = [];
  String selectedUserID = '';
  String selectedUserName = '';
  Offset? _tapPosition;

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  _showSelectUserToViewPopupMenu(
      BuildContext context, List<UserModel> users) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition! & const Size(40, 40), Offset.zero & overlay.size),
      items: List.generate(
        users.length,
        (index) => PopupMenuItem(
          onTap: () {
            setState(() {
              selectedUserID = users[index].uid;
              selectedUserName = '${users[index].name} ${users[index].surname}';
              context
                  .read<AppointmentListProvider>()
                  .getAppointmentsById(selectedUserID);
            });
          },
          value: 1,
          child: Text(
            '${users[index].name} ${users[index].surname}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      elevation: 8.0,
    );
  }

  _showSelectUserListViewPopupMenu(
      BuildContext context, List<UserModel> users) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition! & const Size(40, 40), Offset.zero & overlay.size),
      items: List.generate(
        users.length,
        (index) => PopupMenuItem(
          onTap: () {
            if (selectedIdsList.contains(users[index].uid)) {
              setState(() {
                selectedIdsList.remove(users[index].uid);
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                  await context
                      .read<AppointmentDetailProvider>()
                      .cleanUserList();
                  await context
                      .read<AppointmentDetailProvider>()
                      .getAppointmentUserListById(userIds: selectedIdsList);
                });
                print(selectedIdsList);
              });
            } else {
              setState(() {
                selectedIdsList.add(users[index].uid);
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                  await context
                      .read<AppointmentDetailProvider>()
                      .cleanUserList();
                  await context
                      .read<AppointmentDetailProvider>()
                      .getAppointmentUserListById(userIds: selectedIdsList);
                });
                print(selectedIdsList);
              });
            }
          },
          value: 1,
          child: Text(
            '${users[index].name} ${users[index].surname}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      elevation: 8.0,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<AppointmentListProvider>().getAppointmentsById(null);
      if (mounted) {
        await context.read<UserListProvider>().getAllUsers();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthProvider>(context).currentUser;
    return ResponsiveBuilder(builder: (context, size) {
      return Consumer2<AppointmentListProvider, UserListProvider>(
          builder: (context, list, users, child) {
        return list.appointmentListByMe == null
            ? Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: RiveAnimation.asset('lib/resources/images/loader.riv'),
                ),
              )
            : SizedBox(
                width: size.deviceScreenType == DeviceScreenType.mobile
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width - 60,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Visibility(
                      visible: user.isAdmin,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: const Color.fromARGB(255, 214, 214, 214),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTapDown: _storePosition,
                                onTap: () async =>
                                    await _showSelectUserToViewPopupMenu(
                                        context, users.userList!),
                                child: Container(
                                  width: 200,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black, width: 0.2),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, top: 10),
                                    child: Text(
                                      selectedUserName.isEmpty
                                          ? '${user.name} ${user.surname}'
                                          : selectedUserName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: user.isAdmin
                          ? MediaQuery.of(context).size.height - 51
                          : MediaQuery.of(context).size.height,
                      child: size.deviceScreenType == DeviceScreenType.mobile
                          ? SfCalendar(
                              view: CalendarView.workWeek,
                              onTap: (calendarTapDetails) async {
                                if (calendarTapDetails.appointments != null) {
                                  await context
                                      .read<AppointmentDetailProvider>()
                                      .cleanUserList();
                                  await context
                                      .read<AppointmentDetailProvider>()
                                      .getAppointmentUserListById(
                                          userIds: calendarTapDetails
                                              .appointments![0].userId);
                                  showEditDialogMobile(
                                      calendarTapDetails, users.userList!);
                                } else {
                                  await context
                                      .read<AppointmentDetailProvider>()
                                      .cleanUserList();
                                  showCreateDialogMobile(
                                      calendarTapDetails, users.userList!);
                                }
                              },
                              dataSource: MeetingDataSource(
                                  list.appointmentListByMe ?? []),
                            )
                          : SfCalendar(
                              view: CalendarView.workWeek,
                              onTap: (calendarTapDetails) async {
                                if (calendarTapDetails.appointments != null) {
                                  await context
                                      .read<AppointmentDetailProvider>()
                                      .cleanUserList();
                                  await context
                                      .read<AppointmentDetailProvider>()
                                      .getAppointmentUserListById(
                                          userIds: calendarTapDetails
                                              .appointments![0].userId);
                                  showEditDialog(
                                      calendarTapDetails, users.userList!);
                                } else {
                                  await context
                                      .read<AppointmentDetailProvider>()
                                      .cleanUserList();
                                  showCreateDialog(
                                      calendarTapDetails, users.userList!);
                                }
                              },
                              dataSource: MeetingDataSource(
                                  list.appointmentListByMe ?? []),
                            ),
                    ),
                  ],
                ),
              );
      });
    });
  }

  void showCreateDialogMobile(
      CalendarTapDetails calendarTapDetails, List<UserModel> users) async {
    DateTime defaulStartTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour,
      calendarTapDetails.date!.minute,
    );
    DateTime defaultEndTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour + 1,
      calendarTapDetails.date!.minute,
    );
    TextEditingController meetingNameController = TextEditingController();
    TextEditingController dateStartController = TextEditingController();
    TextEditingController hourDateStartController = TextEditingController();
    TextEditingController dateEndController = TextEditingController();
    TextEditingController hourDateEndController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    int? selectedColor;
    selectedIdsList = [];
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                width: 800,
                height: 600,
                child: Consumer2<NewAppointmentProvider,
                        AppointmentDetailProvider>(
                    builder:
                        (context, appointmentProvider, detailProvider, child) {
                  return SingleChildScrollView(
                    child: Column(children: [
                      SizedBox(
                        width: 800,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Crea appuntamento',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 52, 52, 52)),
                                  ),
                                ],
                              ),
                            ),
                            //crea appuntamento
                            const Text(
                              'Seleziona colore:',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 52, 52, 52)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedColor = 0;
                                          });
                                        },
                                        child: ColorPicker(
                                          isActive: selectedColor == 0,
                                          color: Colors.red,
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedColor = 1;
                                          });
                                        },
                                        child: ColorPicker(
                                          isActive: selectedColor == 1,
                                          color: Colors.blue,
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(
                                            () {
                                              selectedColor = 2;
                                            },
                                          );
                                        },
                                        child: ColorPicker(
                                          isActive: selectedColor == 2,
                                          color: Colors.pink,
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(
                                            () {
                                              selectedColor = 3;
                                            },
                                          );
                                        },
                                        child: ColorPicker(
                                          isActive: selectedColor == 3,
                                          color: Colors.yellow,
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(
                                            () {
                                              selectedColor = 4;
                                            },
                                          );
                                        },
                                        child: ColorPicker(
                                          isActive: selectedColor == 4,
                                          color: Colors.purple,
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedColor = 5;
                                          });
                                        },
                                        child: ColorPicker(
                                          isActive: selectedColor == 5,
                                          color: Colors.green,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nome evento',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 52, 52, 52)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                      width: 300,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4)),
                                          border: Border.all(
                                              color: Colors.black, width: 0.2)),
                                      child: TextField(
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.only(left: 6),
                                            hintText: 'Inserisci nome evento'),
                                        controller: meetingNameController,
                                      )),
                                )
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      'Seleziona Data inizio:',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 52, 52, 52)),
                                    ),
                                  ),
                                  Container(
                                    width: 200,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4)),
                                        border: Border.all(
                                            color: Colors.black, width: 0.2)),
                                    child: TextField(
                                      controller: dateStartController,
                                      onTap: () async {
                                        var isShowTimePicker = false;
                                        DateTime? picked;
                                        picked = await AppDatePickers
                                            .showAndroidDatePicker(
                                                initialDate: DateTime(
                                                  calendarTapDetails.date!.year,
                                                  calendarTapDetails
                                                      .date!.month,
                                                  calendarTapDetails.date!.day,
                                                  calendarTapDetails.date!.hour,
                                                  calendarTapDetails
                                                      .date!.minute,
                                                ),
                                                context: context,
                                                firstDate: DateTime.now());
                                        if (picked != null &&
                                            picked != selectedStartDate) {
                                          selectedStartDate = picked;
                                          setState(() {
                                            dateStartController.text =
                                                formattedDate(
                                                    selectedStartDate);
                                            isShowTimePicker = true;
                                          });
                                          if (isShowTimePicker && mounted) {
                                            TimeOfDay? pickedTime =
                                                await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now());
                                            if (pickedTime != null && mounted) {
                                              DateTime parsedTime =
                                                  DateFormat.jm().parse(
                                                      pickedTime
                                                          .format(context)
                                                          .toString());
                                              String formattedHour =
                                                  formattedTime(parsedTime);
                                              setState(() {
                                                hourDateStartController.text =
                                                    formattedHour;
                                              });
                                            }
                                          }
                                        }
                                      },
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.only(left: 6),
                                          hintText: formattedDate(DateTime(
                                            calendarTapDetails.date!.year,
                                            calendarTapDetails.date!.month,
                                            calendarTapDetails.date!.day,
                                            calendarTapDetails.date!.hour,
                                            calendarTapDetails.date!.minute,
                                          )),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Seleziona ora inizio',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 52, 52, 52)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                width: 70,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    border: Border.all(
                                        color: Colors.black, width: 0.2)),
                                child: TextField(
                                  controller: hourDateStartController,
                                  onTap: () async {
                                    TimeOfDay? pickedTime =
                                        await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now());
                                    if (pickedTime != null && mounted) {
                                      DateTime parsedTime = DateFormat.jm()
                                          .parse(pickedTime
                                              .format(context)
                                              .toString());
                                      String formattedHour =
                                          formattedTime(parsedTime);
                                      setState(() {
                                        hourDateStartController.text =
                                            formattedHour;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.only(left: 6),
                                      hintText: formattedTime(DateTime(
                                        calendarTapDetails.date!.year,
                                        calendarTapDetails.date!.month,
                                        calendarTapDetails.date!.day,
                                        calendarTapDetails.date!.hour,
                                        calendarTapDetails.date!.minute,
                                      )),
                                      border: InputBorder.none),
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'Seleziona data fine',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 52, 52, 52)),
                              ),
                            ),
                            Container(
                              width: 200,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  border: Border.all(
                                      color: Colors.black, width: 0.2)),
                              child: TextField(
                                controller: dateEndController,
                                onTap: () async {
                                  var isShowTimePicker = false;
                                  DateTime? picked;
                                  picked = await AppDatePickers
                                      .showAndroidDatePicker(
                                          initialDate: selectedStartDate,
                                          context: context,
                                          firstDate: DateTime.now());
                                  if (picked != null &&
                                      picked != selectedStartDate) {
                                    selectedStartDate = picked;
                                    setState(() {
                                      dateEndController.text =
                                          formattedDate(selectedStartDate);
                                      isShowTimePicker = true;
                                    });
                                    if (isShowTimePicker && mounted) {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());
                                      if (pickedTime != null) {
                                        DateTime parsedTime = DateFormat.jm()
                                            .parse(pickedTime
                                                .format(context)
                                                .toString());
                                        String formattedHour =
                                            formattedTime(parsedTime);
                                        setState(() {
                                          hourDateEndController.text =
                                              formattedHour;
                                        });
                                      }
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 6),
                                    hintText: formattedDate(defaulStartTime),
                                    border: InputBorder.none),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'Seleziona ora fine',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 52, 52, 52)),
                              ),
                            ),
                            Container(
                              width: 70,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  border: Border.all(
                                      color: Colors.black, width: 0.2)),
                              child: TextField(
                                controller: hourDateEndController,
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now());
                                  if (pickedTime != null) {
                                    DateTime parsedTime = DateFormat.jm().parse(
                                        pickedTime.format(context).toString());
                                    String formattedHour =
                                        formattedTime(parsedTime);
                                    setState(() {
                                      hourDateEndController.text =
                                          formattedHour;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.only(left: 6),
                                    hintText: formattedTime(defaultEndTime),
                                    border: InputBorder.none),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'Url',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 52, 52, 52)),
                              ),
                            ),
                            Container(
                                width: 200,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4)),
                                    border: Border.all(
                                        color: Colors.black, width: 0.2)),
                                child: TextField(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(left: 6),
                                      hintText: 'enter url'),
                                  controller: urlController,
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: SizedBox(
                          height: 200,
                          width: 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Partecipanti',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 52, 52, 52)),
                              ),
                              detailProvider.userListById != null
                                  ? detailProvider.userListById!.isNotEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: SizedBox(
                                            height: 30,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: detailProvider
                                                      .userListById?.length ??
                                                  0,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              198,
                                                              198,
                                                              198),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        '${detailProvider.userListById![index].name} ${detailProvider.userListById![index].surname}',
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink()
                                  : SizedBox.shrink(),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: GestureDetector(
                                  onTapDown: _storePosition,
                                  onTap: () async =>
                                      await _showSelectUserListViewPopupMenu(
                                          context, users),
                                  child: const Text(
                                    'Aggiungi partecipanti',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MaterialButton(
                              onPressed: () async {
                                DateTime correctedStartDate = defaulStartTime;
                                DateTime correctedEndDate = defaultEndTime;
                                DateFormat format =
                                    DateFormat("dd-MM-yyyy hh:mm:ss");
                                bool isUserNotFree = false;

                                if (dateStartController.text.isNotEmpty) {
                                  correctedStartDate = format.parse(
                                      '${dateStartController.text} ${hourDateStartController.text}:00');
                                }
                                if (dateEndController.text.isNotEmpty) {
                                  correctedEndDate = format.parse(
                                      '${dateEndController.text} ${hourDateEndController.text}:00');
                                }
                                if (selectedIdsList.isNotEmpty &&
                                    meetingNameController.text.isNotEmpty) {
                                  // await context
                                  //     .read<AppointmentListProvider>()
                                  //     .deleteAppointmentByMe(
                                  //         calendarTapDetails.appointments![0]);
                                  for (var user in selectedIdsList) {
                                    isUserNotFree = await context
                                        .read<AppointmentListProvider>()
                                        .checkAvailabilitySlot(
                                            user,
                                            correctedStartDate,
                                            correctedEndDate);
                                    if (isUserNotFree) {
                                      //mostrare errore
                                      break;
                                    }
                                  }
                                  if (isUserNotFree) {
                                    return;
                                  }
                                  context
                                      .read<NewAppointmentProvider>()
                                      .publishAppoitnemt(
                                          userIds: selectedIdsList,
                                          id: firestoreId(),
                                          color: chooseColor(selectedColor),
                                          subject: meetingNameController.text,
                                          startDate: correctedStartDate,
                                          endDate: correctedEndDate,
                                          url: urlController.text);
                                  if (mounted) {
                                    AutoRouter.of(context).pop(true);
                                    await context
                                        .read<AppointmentListProvider>()
                                        .getAppointmentsById(null);
                                  }
                                }
                              },
                              color: Colors.blue,
                              child: const Text(
                                'Conferma',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              AutoRouter.of(context).pop();
                            },
                            color: Colors.red,
                            child: const Text(
                              'Annulla',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ]),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  void showEditDialogMobile(
      CalendarTapDetails calendarTapDetails, List<UserModel> users) async {
    DateTime defaulStartTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour,
      calendarTapDetails.date!.minute,
    );
    DateTime defaultEndTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour + 1,
      calendarTapDetails.date!.minute,
    );
    TextEditingController meetingNameController = TextEditingController();
    TextEditingController dateStartController = TextEditingController();
    TextEditingController hourDateStartController = TextEditingController();
    TextEditingController dateEndController = TextEditingController();
    TextEditingController hourDateEndController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    meetingNameController.text = calendarTapDetails.appointments![0].subject;
    // dateStartController.text =
    //     formattedDate(calendarTapDetails.appointments![0].startTime);
    // dateEndController.text =
    //     formattedDate(calendarTapDetails.appointments![0].endTime);
    // hourDateStartController.text =
    //     formattedTime(calendarTapDetails.appointments![0].startTime);
    // hourDateEndController.text =
    //     formattedTime(calendarTapDetails.appointments![0].endTime);
    urlController.text = calendarTapDetails.appointments![0].url;

    int? selectedColor;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                width: 800,
                height: 600,
                child: Consumer2<NewAppointmentProvider,
                        AppointmentDetailProvider>(
                    builder:
                        (context, appointmentProvider, detailProvider, child) {
                  return StatefulBuilder(
                    builder: (context, setState) => SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 800,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Crea appuntamento',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 52, 52, 52)),
                                      ),
                                    ],
                                  ),
                                ),
                                //crea appuntamento
                                const Text(
                                  'Seleziona colore:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 52, 52, 52)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = 0;
                                              });
                                            },
                                            child: ColorPicker(
                                              isActive: selectedColor == 0,
                                              color: Colors.red,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = 1;
                                              });
                                            },
                                            child: ColorPicker(
                                              isActive: selectedColor == 1,
                                              color: Colors.blue,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(
                                                () {
                                                  selectedColor = 2;
                                                },
                                              );
                                            },
                                            child: ColorPicker(
                                              isActive: selectedColor == 2,
                                              color: Colors.pink,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(
                                                () {
                                                  selectedColor = 3;
                                                },
                                              );
                                            },
                                            child: ColorPicker(
                                              isActive: selectedColor == 3,
                                              color: Colors.yellow,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(
                                                () {
                                                  selectedColor = 4;
                                                },
                                              );
                                            },
                                            child: ColorPicker(
                                              isActive: selectedColor == 4,
                                              color: Colors.purple,
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = 5;
                                              });
                                            },
                                            child: ColorPicker(
                                              isActive: selectedColor == 5,
                                              color: Colors.green,
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Nome evento',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 52, 52, 52)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                          width: 300,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(4)),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 0.2)),
                                          child: TextField(
                                            decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.only(left: 6),
                                                hintText:
                                                    'Inserisci nome evento'),
                                            controller: meetingNameController,
                                          )),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          'Seleziona Data inizio:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 52, 52, 52)),
                                        ),
                                      ),
                                      Container(
                                        width: 200,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(4)),
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 0.2)),
                                        child: TextField(
                                          controller: dateStartController,
                                          onTap: () async {
                                            var isShowTimePicker = false;
                                            DateTime? picked;
                                            picked = await AppDatePickers
                                                .showAndroidDatePicker(
                                                    initialDate: DateTime(
                                                      calendarTapDetails
                                                          .date!.year,
                                                      calendarTapDetails
                                                          .date!.month,
                                                      calendarTapDetails
                                                          .date!.day,
                                                      calendarTapDetails
                                                          .date!.hour,
                                                      calendarTapDetails
                                                          .date!.minute,
                                                    ),
                                                    context: context,
                                                    firstDate: DateTime.now());
                                            if (picked != null &&
                                                picked != selectedStartDate) {
                                              selectedStartDate = picked;
                                              setState(() {
                                                dateStartController.text =
                                                    formattedDate(
                                                        selectedStartDate);
                                                isShowTimePicker = true;
                                              });
                                              if (isShowTimePicker && mounted) {
                                                TimeOfDay? pickedTime =
                                                    await showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            TimeOfDay.now());
                                                if (pickedTime != null &&
                                                    mounted) {
                                                  DateTime parsedTime =
                                                      DateFormat.jm().parse(
                                                          pickedTime
                                                              .format(context)
                                                              .toString());
                                                  String formattedHour =
                                                      formattedTime(parsedTime);
                                                  setState(() {
                                                    hourDateStartController
                                                        .text = formattedHour;
                                                  });
                                                }
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 6),
                                              hintText: formattedDate(DateTime(
                                                calendarTapDetails.date!.year,
                                                calendarTapDetails.date!.month,
                                                calendarTapDetails.date!.day,
                                                calendarTapDetails.date!.hour,
                                                calendarTapDetails.date!.minute,
                                              )),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Seleziona ora inizio',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 52, 52, 52)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Container(
                                    width: 70,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4)),
                                        border: Border.all(
                                            color: Colors.black, width: 0.2)),
                                    child: TextField(
                                      controller: hourDateStartController,
                                      onTap: () async {
                                        TimeOfDay? pickedTime =
                                            await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now());
                                        if (pickedTime != null && mounted) {
                                          DateTime parsedTime = DateFormat.jm()
                                              .parse(pickedTime
                                                  .format(context)
                                                  .toString());
                                          String formattedHour =
                                              formattedTime(parsedTime);
                                          setState(() {
                                            hourDateStartController.text =
                                                formattedHour;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.only(left: 6),
                                          hintText: formattedTime(DateTime(
                                            calendarTapDetails.date!.year,
                                            calendarTapDetails.date!.month,
                                            calendarTapDetails.date!.day,
                                            calendarTapDetails.date!.hour,
                                            calendarTapDetails.date!.minute,
                                          )),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    'Seleziona data fine',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 52, 52, 52)),
                                  ),
                                ),
                                Container(
                                  width: 200,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      border: Border.all(
                                          color: Colors.black, width: 0.2)),
                                  child: TextField(
                                    controller: dateEndController,
                                    onTap: () async {
                                      var isShowTimePicker = false;
                                      DateTime? picked;
                                      picked = await AppDatePickers
                                          .showAndroidDatePicker(
                                              initialDate: selectedStartDate,
                                              context: context,
                                              firstDate: DateTime.now());
                                      if (picked != null &&
                                          picked != selectedStartDate) {
                                        selectedStartDate = picked;
                                        setState(() {
                                          dateEndController.text =
                                              formattedDate(selectedStartDate);
                                          isShowTimePicker = true;
                                        });
                                        if (isShowTimePicker && mounted) {
                                          TimeOfDay? pickedTime =
                                              await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now());
                                          if (pickedTime != null) {
                                            DateTime parsedTime =
                                                DateFormat.jm().parse(pickedTime
                                                    .format(context)
                                                    .toString());
                                            String formattedHour =
                                                formattedTime(parsedTime);
                                            setState(() {
                                              hourDateEndController.text =
                                                  formattedHour;
                                            });
                                          }
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.only(left: 6),
                                        hintText:
                                            formattedDate(defaulStartTime),
                                        border: InputBorder.none),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    'Seleziona ora fine',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 52, 52, 52)),
                                  ),
                                ),
                                Container(
                                  width: 70,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(4)),
                                      border: Border.all(
                                          color: Colors.black, width: 0.2)),
                                  child: TextField(
                                    controller: hourDateEndController,
                                    onTap: () async {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now());
                                      if (pickedTime != null) {
                                        DateTime parsedTime = DateFormat.jm()
                                            .parse(pickedTime
                                                .format(context)
                                                .toString());
                                        String formattedHour =
                                            formattedTime(parsedTime);
                                        setState(() {
                                          hourDateEndController.text =
                                              formattedHour;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.only(left: 6),
                                        hintText: formattedTime(defaultEndTime),
                                        border: InputBorder.none),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    'Url',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 52, 52, 52)),
                                  ),
                                ),
                                Container(
                                    width: 200,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4)),
                                        border: Border.all(
                                            color: Colors.black, width: 0.2)),
                                    child: TextField(
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.only(left: 6),
                                          hintText: 'enter url'),
                                      controller: urlController,
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: SizedBox(
                              height: 200,
                              width: 300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Partecipanti',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 52, 52, 52)),
                                  ),
                                  detailProvider.userListById != null
                                      ? detailProvider.userListById!.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
                                              child: SizedBox(
                                                height: 30,
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: detailProvider
                                                          .userListById
                                                          ?.length ??
                                                      0,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.0),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                                  .fromARGB(255,
                                                              198, 198, 198),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Text(
                                                            '${detailProvider.userListById![index].name} ${detailProvider.userListById![index].surname}',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink()
                                      : SizedBox.shrink(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: GestureDetector(
                                      onTapDown: _storePosition,
                                      onTap: () async =>
                                          await _showSelectUserListViewPopupMenu(
                                              context, users),
                                      child: const Text(
                                        'Aggiungi partecipanti',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MaterialButton(
                                  onPressed: () async {
                                    DateTime correctedStartDate =
                                        defaulStartTime;
                                    DateTime correctedEndDate = defaultEndTime;
                                    DateFormat format =
                                        DateFormat("dd-MM-yyyy hh:mm:ss");

                                    if (dateStartController.text.isNotEmpty) {
                                      correctedStartDate = format.parse(
                                          '${dateStartController.text} ${hourDateStartController.text}:00');
                                    }
                                    if (dateEndController.text.isNotEmpty) {
                                      correctedEndDate = format.parse(
                                          '${dateEndController.text} ${hourDateEndController.text}:00');
                                    }
                                    if (selectedIdsList.isNotEmpty &&
                                        meetingNameController.text.isNotEmpty) {
                                      for (var user in selectedIdsList) {
                                        bool isUserNotFree = await context
                                            .read<AppointmentListProvider>()
                                            .checkAvailabilitySlot(
                                                user,
                                                correctedStartDate,
                                                correctedEndDate);
                                        if (isUserNotFree) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => Container(
                                              child: Text(
                                                  'uno degli utenti è impegnato per questo slot temporale'),
                                            ),
                                          );
                                          return;
                                        } else {
                                          context
                                              .read<NewAppointmentProvider>()
                                              .publishAppoitnemt(
                                                  userIds: selectedIdsList,
                                                  id: firestoreId(),
                                                  color: chooseColor(
                                                      selectedColor),
                                                  subject: meetingNameController
                                                      .text,
                                                  startDate: correctedStartDate,
                                                  endDate: correctedEndDate,
                                                  url: urlController.text);
                                        }
                                      }
                                      await context
                                          .read<AppointmentListProvider>()
                                          .deleteAppointmentByMe(
                                              calendarTapDetails
                                                  .appointments![0]);
                                      selectedIdsList = [];
                                      if (mounted) {
                                        AutoRouter.of(context).pop(true);
                                        await context
                                            .read<AppointmentListProvider>()
                                            .getAppointmentsById(null);
                                      }
                                    }
                                  },
                                  //   if (selectedIdsList.isNotEmpty &&
                                  //       meetingNameController.text.isNotEmpty) {
                                  //     if (dateStartController.text.isNotEmpty ||
                                  //         dateEndController.text.isNotEmpty) {
                                  //       DateFormat format =
                                  //           DateFormat("dd-MM-yyyy hh:mm:ss");
                                  //       var parsedStartDate = format.parse(
                                  //           '${dateStartController.text} ${hourDateStartController.text}:00');
                                  //       var parsedEndDate = format.parse(
                                  //           '${dateEndController.text} ${hourDateEndController.text}:00');
                                  //       context
                                  //           .read<NewAppointmentProvider>()
                                  //           .publishAppoitnemt(
                                  //               userIds: selectedIdsList,
                                  //               id: firestoreId(),
                                  //               color: chooseColor(selectedColor),
                                  //               subject:
                                  //                   meetingNameController.text,
                                  //               startDate: parsedStartDate,
                                  //               endDate: parsedEndDate,
                                  //               url: urlController.text);
                                  //     } else {
                                  //       await context
                                  //           .read<NewAppointmentProvider>()
                                  //           .publishAppoitnemt(
                                  //               userIds: selectedIdsList,
                                  //               id: firestoreId(),
                                  //               color: chooseColor(selectedColor),
                                  //               subject:
                                  //                   meetingNameController.text,
                                  //               startDate: defaulStartTime,
                                  //               endDate: defaultEndTime,
                                  //               url: urlController.text);
                                  //     }
                                  //     await context
                                  //         .read<AppointmentListProvider>()
                                  //         .deleteAppointmentByMe(
                                  //             calendarTapDetails
                                  //                 .appointments![0]);
                                  //     if (mounted) {
                                  //       AutoRouter.of(context).pop(true);
                                  //       await context
                                  //           .read<AppointmentListProvider>()
                                  //           .getAppointmentsById(null);
                                  //     }
                                  //   }
                                  // },
                                  color: Colors.blue,
                                  child: const Text(
                                    'Conferma',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  AutoRouter.of(context).pop();
                                },
                                color: Colors.red,
                                child: const Text(
                                  'Annulla',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  await context
                                      .read<AppointmentListProvider>()
                                      .deleteAppointmentByMe(
                                          calendarTapDetails.appointments![0]);
                                  if (mounted) {
                                    AutoRouter.of(context).pop();
                                  }
                                },
                                child: Container(
                                    height: 40,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7))),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }

  void showCreateDialog(
      CalendarTapDetails calendarTapDetails, List<UserModel> users) async {
    DateTime defaulStartTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour,
      calendarTapDetails.date!.minute,
    );
    DateTime defaultEndTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour + 1,
      calendarTapDetails.date!.minute,
    );
    TextEditingController meetingNameController = TextEditingController();
    TextEditingController dateStartController = TextEditingController();
    TextEditingController hourDateStartController = TextEditingController();
    TextEditingController dateEndController = TextEditingController();
    TextEditingController hourDateEndController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    int? selectedColor;
    selectedIdsList = [];
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                width: 800,
                height: 500,
                child: Consumer2<NewAppointmentProvider,
                        AppointmentDetailProvider>(
                    builder:
                        (context, appointmentProvider, detailProvider, child) {
                  return Column(children: [
                    Wrap(
                      children: [
                        SizedBox(
                          width: 800,
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 25.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Crea appuntamento',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 52, 52, 52)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 25, left: 30.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedColor = 0;
                                                });
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 0,
                                                color: Colors.red,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedColor = 1;
                                                });
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 1,
                                                color: Colors.blue,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    selectedColor = 2;
                                                  },
                                                );
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 2,
                                                color: Colors.pink,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    selectedColor = 3;
                                                  },
                                                );
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 3,
                                                color: Colors.yellow,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    selectedColor = 4;
                                                  },
                                                );
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 4,
                                                color: Colors.purple,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedColor = 5;
                                                });
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 5,
                                                color: Colors.green,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Nome evento',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 52, 52, 52)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Container(
                                                  width: 300,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  4)),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.2)),
                                                  child: TextField(
                                                    decoration:
                                                        const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    left: 6),
                                                            hintText:
                                                                'Inserisci nome evento'),
                                                    controller:
                                                        meetingNameController,
                                                  )),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, top: 8),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                'Seleziona Data inizio:',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 52, 52)),
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 0.2)),
                                              child: TextField(
                                                controller: dateStartController,
                                                onTap: () async {
                                                  var isShowTimePicker = false;
                                                  DateTime? picked;
                                                  picked = await AppDatePickers
                                                      .showAndroidDatePicker(
                                                          initialDate: DateTime(
                                                            calendarTapDetails
                                                                .date!.year,
                                                            calendarTapDetails
                                                                .date!.month,
                                                            calendarTapDetails
                                                                .date!.day,
                                                            calendarTapDetails
                                                                .date!.hour,
                                                            calendarTapDetails
                                                                .date!.minute,
                                                          ),
                                                          context: context,
                                                          firstDate:
                                                              DateTime.now());
                                                  if (picked != null &&
                                                      picked !=
                                                          selectedStartDate) {
                                                    selectedStartDate = picked;
                                                    setState(() {
                                                      dateStartController.text =
                                                          formattedDate(
                                                              selectedStartDate);
                                                      isShowTimePicker = true;
                                                    });
                                                    if (isShowTimePicker &&
                                                        mounted) {
                                                      TimeOfDay? pickedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (pickedTime != null &&
                                                          mounted) {
                                                        DateTime parsedTime =
                                                            DateFormat.jm()
                                                                .parse(pickedTime
                                                                    .format(
                                                                        context)
                                                                    .toString());
                                                        String formattedHour =
                                                            formattedTime(
                                                                parsedTime);
                                                        setState(() {
                                                          hourDateStartController
                                                                  .text =
                                                              formattedHour;
                                                        });
                                                      }
                                                    }
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    hintText:
                                                        formattedDate(DateTime(
                                                      calendarTapDetails
                                                          .date!.year,
                                                      calendarTapDetails
                                                          .date!.month,
                                                      calendarTapDetails
                                                          .date!.day,
                                                      calendarTapDetails
                                                          .date!.hour,
                                                      calendarTapDetails
                                                          .date!.minute,
                                                    )),
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30, bottom: 8.0),
                                                child: Text(
                                                  'Seleziona ora inizio',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 52, 52, 52)),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30.0),
                                                child: Container(
                                                  width: 70,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  4)),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.2)),
                                                  child: TextField(
                                                    controller:
                                                        hourDateStartController,
                                                    onTap: () async {
                                                      TimeOfDay? pickedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (pickedTime != null &&
                                                          mounted) {
                                                        DateTime parsedTime =
                                                            DateFormat.jm()
                                                                .parse(pickedTime
                                                                    .format(
                                                                        context)
                                                                    .toString());
                                                        String formattedHour =
                                                            formattedTime(
                                                                parsedTime);
                                                        setState(() {
                                                          hourDateStartController
                                                                  .text =
                                                              formattedHour;
                                                        });
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(left: 6),
                                                        hintText: formattedTime(
                                                            DateTime(
                                                          calendarTapDetails
                                                              .date!.year,
                                                          calendarTapDetails
                                                              .date!.month,
                                                          calendarTapDetails
                                                              .date!.day,
                                                          calendarTapDetails
                                                              .date!.hour,
                                                          calendarTapDetails
                                                              .date!.minute,
                                                        )),
                                                        border:
                                                            InputBorder.none),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 30),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                'Seleziona data fine',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 52, 52)),
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 0.2)),
                                              child: TextField(
                                                controller: dateEndController,
                                                onTap: () async {
                                                  var isShowTimePicker = false;
                                                  DateTime? picked;
                                                  picked = await AppDatePickers
                                                      .showAndroidDatePicker(
                                                          initialDate:
                                                              selectedStartDate,
                                                          context: context,
                                                          firstDate:
                                                              DateTime.now());
                                                  if (picked != null &&
                                                      picked !=
                                                          selectedStartDate) {
                                                    selectedStartDate = picked;
                                                    setState(() {
                                                      dateEndController.text =
                                                          formattedDate(
                                                              selectedStartDate);
                                                      isShowTimePicker = true;
                                                    });
                                                    if (isShowTimePicker &&
                                                        mounted) {
                                                      TimeOfDay? pickedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (pickedTime != null) {
                                                        DateTime parsedTime =
                                                            DateFormat.jm()
                                                                .parse(pickedTime
                                                                    .format(
                                                                        context)
                                                                    .toString());
                                                        String formattedHour =
                                                            formattedTime(
                                                                parsedTime);
                                                        setState(() {
                                                          hourDateEndController
                                                                  .text =
                                                              formattedHour;
                                                        });
                                                      }
                                                    }
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    hintText: formattedDate(
                                                        defaulStartTime),
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 30, bottom: 8.0),
                                                    child: Text(
                                                      'Seleziona ora fine',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 52, 52, 52)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30.0),
                                                    child: Container(
                                                      width: 70,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          4)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 0.2)),
                                                      child: TextField(
                                                        controller:
                                                            hourDateEndController,
                                                        onTap: () async {
                                                          TimeOfDay?
                                                              pickedTime =
                                                              await showTimePicker(
                                                                  context:
                                                                      context,
                                                                  initialTime:
                                                                      TimeOfDay
                                                                          .now());
                                                          if (pickedTime !=
                                                              null) {
                                                            DateTime
                                                                parsedTime =
                                                                DateFormat.jm()
                                                                    .parse(pickedTime
                                                                        .format(
                                                                            context)
                                                                        .toString());
                                                            String
                                                                formattedHour =
                                                                formattedTime(
                                                                    parsedTime);
                                                            setState(() {
                                                              hourDateEndController
                                                                      .text =
                                                                  formattedHour;
                                                            });
                                                          }
                                                        },
                                                        decoration: InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 6),
                                                            hintText: formattedTime(
                                                                defaultEndTime),
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 30.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                'Url',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 52, 52)),
                                              ),
                                            ),
                                            Container(
                                                width: 370,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(4)),
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 0.2)),
                                                child: TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 6),
                                                          hintText:
                                                              'enter url'),
                                                  controller: urlController,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 60.0),
                                child: SizedBox(
                                  height: 200,
                                  width: 280,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Partecipanti',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 52, 52, 52)),
                                      ),
                                      detailProvider.userListById != null
                                          ? detailProvider
                                                  .userListById!.isNotEmpty
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: SizedBox(
                                                    height: 30,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: detailProvider
                                                              .userListById
                                                              ?.length ??
                                                          0,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 8.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  198,
                                                                  198,
                                                                  198),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(
                                                                '${detailProvider.userListById![index].name} ${detailProvider.userListById![index].surname}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink()
                                          : SizedBox.shrink(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: GestureDetector(
                                          onTapDown: _storePosition,
                                          onTap: () async =>
                                              await _showSelectUserListViewPopupMenu(
                                                  context, users),
                                          child: const Text(
                                            'Aggiungi partecipanti',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MaterialButton(
                                onPressed: () async {
                                  List<String> userIdLoaded = [];
                                  for (var users
                                      in detailProvider.userListById!) {
                                    userIdLoaded.add(users.uid);
                                  }
                                  DateTime correctedStartDate = defaulStartTime;
                                  DateTime correctedEndDate = defaultEndTime;
                                  DateFormat format =
                                      DateFormat("dd-MM-yyyy hh:mm:ss");
                                  if (dateStartController.text.isNotEmpty) {
                                    correctedStartDate = format.parse(
                                        '${dateStartController.text} ${hourDateStartController.text}:00');
                                  }
                                  if (dateEndController.text.isNotEmpty) {
                                    correctedEndDate = format.parse(
                                        '${dateEndController.text} ${hourDateEndController.text}:00');
                                  }
                                  selectedIdsList = userIdLoaded;

                                  if (selectedIdsList.isNotEmpty &&
                                      meetingNameController.text.isNotEmpty) {
                                    context
                                        .read<NewAppointmentProvider>()
                                        .publishAppoitnemt(
                                            userIds: userIdLoaded,
                                            id: firestoreId(),
                                            color: chooseColor(selectedColor),
                                            subject: meetingNameController.text,
                                            startDate: correctedStartDate,
                                            endDate: correctedEndDate,
                                            url: urlController.text);
                                    if (mounted) {
                                      AutoRouter.of(context).pop(true).then(
                                          (value) async => await context
                                              .read<AppointmentListProvider>()
                                              .getAppointmentsById(null));
                                    }
                                  } else {
                                    showEmptyFieldsDialog(context);
                                  }
                                },
                                color: Colors.blue,
                                child: const Text(
                                  'Conferma',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                AutoRouter.of(context).pop();
                              },
                              color: Colors.red,
                              child: const Text(
                                'Annulla',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ]);
                }),
              ),
            );
          },
        );
      },
    );
  }

  void showEditDialog(
      CalendarTapDetails calendarTapDetails, List<UserModel> users) async {
    DateTime defaulStartTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour,
      calendarTapDetails.date!.minute,
    );
    DateTime defaultEndTime = DateTime(
      calendarTapDetails.date!.year,
      calendarTapDetails.date!.month,
      calendarTapDetails.date!.day,
      calendarTapDetails.date!.hour + 1,
      calendarTapDetails.date!.minute,
    );
    TextEditingController meetingNameController = TextEditingController();
    TextEditingController dateStartController = TextEditingController();
    TextEditingController hourDateStartController = TextEditingController();
    TextEditingController dateEndController = TextEditingController();
    TextEditingController hourDateEndController = TextEditingController();
    TextEditingController urlController = TextEditingController();
    meetingNameController.text = calendarTapDetails.appointments![0].subject;
    // dateStartController.text =
    //     formattedDate(calendarTapDetails.appointments![0].startTime);
    // dateEndController.text =
    //     formattedDate(calendarTapDetails.appointments![0].endTime);
    // hourDateStartController.text =
    //     formattedTime(calendarTapDetails.appointments![0].startTime);
    // hourDateEndController.text =
    //     formattedTime(calendarTapDetails.appointments![0].endTime);
    urlController.text = calendarTapDetails.appointments![0].url;

    int? selectedColor;
    await await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                width: 800,
                height: 500,
                child: Consumer2<NewAppointmentProvider,
                        AppointmentDetailProvider>(
                    builder:
                        (context, appointmentProvider, detailProvider, child) {
                  return Column(children: [
                    Wrap(
                      children: [
                        SizedBox(
                          width: 800,
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 25.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Crea appuntamento',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 52, 52, 52)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 25, left: 30.0),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedColor = 0;
                                                });
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 0,
                                                color: Colors.red,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedColor = 1;
                                                });
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 1,
                                                color: Colors.blue,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    selectedColor = 2;
                                                  },
                                                );
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 2,
                                                color: Colors.pink,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    selectedColor = 3;
                                                  },
                                                );
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 3,
                                                color: Colors.yellow,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () {
                                                    selectedColor = 4;
                                                  },
                                                );
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 4,
                                                color: Colors.purple,
                                              )),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedColor = 5;
                                                });
                                              },
                                              child: ColorPicker(
                                                isActive: selectedColor == 5,
                                                color: Colors.green,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Nome evento',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(
                                                      255, 52, 52, 52)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Container(
                                                  width: 300,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  4)),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.2)),
                                                  child: TextField(
                                                    decoration:
                                                        const InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            contentPadding:
                                                                EdgeInsets.only(
                                                                    left: 6),
                                                            hintText:
                                                                'Inserisci nome evento'),
                                                    controller:
                                                        meetingNameController,
                                                  )),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, top: 8),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                'Seleziona Data inizio:',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 52, 52)),
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 0.2)),
                                              child: TextField(
                                                controller: dateStartController,
                                                onTap: () async {
                                                  var isShowTimePicker = false;
                                                  DateTime? picked;
                                                  picked = await AppDatePickers
                                                      .showAndroidDatePicker(
                                                          initialDate: DateTime(
                                                            calendarTapDetails
                                                                .date!.year,
                                                            calendarTapDetails
                                                                .date!.month,
                                                            calendarTapDetails
                                                                .date!.day,
                                                            calendarTapDetails
                                                                .date!.hour,
                                                            calendarTapDetails
                                                                .date!.minute,
                                                          ),
                                                          context: context,
                                                          firstDate:
                                                              DateTime.now());
                                                  if (picked != null &&
                                                      picked !=
                                                          selectedStartDate) {
                                                    selectedStartDate = picked;
                                                    setState(() {
                                                      dateStartController.text =
                                                          formattedDate(
                                                              selectedStartDate);
                                                      isShowTimePicker = true;
                                                    });
                                                    if (isShowTimePicker &&
                                                        mounted) {
                                                      TimeOfDay? pickedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (pickedTime != null &&
                                                          mounted) {
                                                        DateTime parsedTime =
                                                            DateFormat.jm()
                                                                .parse(pickedTime
                                                                    .format(
                                                                        context)
                                                                    .toString());
                                                        String formattedHour =
                                                            formattedTime(
                                                                parsedTime);
                                                        setState(() {
                                                          hourDateStartController
                                                                  .text =
                                                              formattedHour;
                                                        });
                                                      }
                                                    }
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    hintText:
                                                        formattedDate(DateTime(
                                                      calendarTapDetails
                                                          .date!.year,
                                                      calendarTapDetails
                                                          .date!.month,
                                                      calendarTapDetails
                                                          .date!.day,
                                                      calendarTapDetails
                                                          .date!.hour,
                                                      calendarTapDetails
                                                          .date!.minute,
                                                    )),
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30, bottom: 8.0),
                                                child: Text(
                                                  'Seleziona ora inizio',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromARGB(
                                                          255, 52, 52, 52)),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30.0),
                                                child: Container(
                                                  width: 70,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  4)),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.2)),
                                                  child: TextField(
                                                    controller:
                                                        hourDateStartController,
                                                    onTap: () async {
                                                      TimeOfDay? pickedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (pickedTime != null &&
                                                          mounted) {
                                                        DateTime parsedTime =
                                                            DateFormat.jm()
                                                                .parse(pickedTime
                                                                    .format(
                                                                        context)
                                                                    .toString());
                                                        String formattedHour =
                                                            formattedTime(
                                                                parsedTime);
                                                        setState(() {
                                                          hourDateStartController
                                                                  .text =
                                                              formattedHour;
                                                        });
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(left: 6),
                                                        hintText: formattedTime(
                                                            DateTime(
                                                          calendarTapDetails
                                                              .date!.year,
                                                          calendarTapDetails
                                                              .date!.month,
                                                          calendarTapDetails
                                                              .date!.day,
                                                          calendarTapDetails
                                                              .date!.hour,
                                                          calendarTapDetails
                                                              .date!.minute,
                                                        )),
                                                        border:
                                                            InputBorder.none),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 30),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                'Seleziona data fine',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 52, 52)),
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 0.2)),
                                              child: TextField(
                                                controller: dateEndController,
                                                onTap: () async {
                                                  var isShowTimePicker = false;
                                                  DateTime? picked;
                                                  picked = await AppDatePickers
                                                      .showAndroidDatePicker(
                                                          initialDate: DateTime(
                                                            calendarTapDetails
                                                                .date!.year,
                                                            calendarTapDetails
                                                                .date!.month,
                                                            calendarTapDetails
                                                                .date!.day,
                                                            calendarTapDetails
                                                                .date!.hour,
                                                            calendarTapDetails
                                                                .date!.minute,
                                                          ),
                                                          context: context,
                                                          firstDate:
                                                              DateTime.now());
                                                  if (picked != null &&
                                                      picked !=
                                                          selectedStartDate) {
                                                    selectedStartDate = picked;
                                                    setState(() {
                                                      dateEndController.text =
                                                          formattedDate(
                                                              selectedStartDate);
                                                      isShowTimePicker = true;
                                                    });
                                                    if (isShowTimePicker &&
                                                        mounted) {
                                                      TimeOfDay? pickedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (pickedTime != null) {
                                                        DateTime parsedTime =
                                                            DateFormat.jm()
                                                                .parse(pickedTime
                                                                    .format(
                                                                        context)
                                                                    .toString());
                                                        String formattedHour =
                                                            formattedTime(
                                                                parsedTime);
                                                        setState(() {
                                                          hourDateEndController
                                                                  .text =
                                                              formattedHour;
                                                        });
                                                      }
                                                    }
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    hintText: formattedDate(
                                                        defaulStartTime),
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 30, bottom: 8.0),
                                                    child: Text(
                                                      'Seleziona ora fine',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 52, 52, 52)),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30.0),
                                                    child: Container(
                                                      width: 70,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          4)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.black,
                                                              width: 0.2)),
                                                      child: TextField(
                                                        controller:
                                                            hourDateEndController,
                                                        onTap: () async {
                                                          TimeOfDay?
                                                              pickedTime =
                                                              await showTimePicker(
                                                                  context:
                                                                      context,
                                                                  initialTime:
                                                                      TimeOfDay
                                                                          .now());
                                                          if (pickedTime !=
                                                              null) {
                                                            DateTime
                                                                parsedTime =
                                                                DateFormat.jm()
                                                                    .parse(pickedTime
                                                                        .format(
                                                                            context)
                                                                        .toString());
                                                            String
                                                                formattedHour =
                                                                formattedTime(
                                                                    parsedTime);
                                                            setState(() {
                                                              hourDateEndController
                                                                      .text =
                                                                  formattedHour;
                                                            });
                                                          }
                                                        },
                                                        decoration: InputDecoration(
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 6),
                                                            hintText: formattedTime(
                                                                defaultEndTime),
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 30.0),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                'Url',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 52, 52, 52)),
                                              ),
                                            ),
                                            Container(
                                                width: 370,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(4)),
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 0.2)),
                                                child: TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.only(
                                                                  left: 6),
                                                          hintText:
                                                              'enter url'),
                                                  controller: urlController,
                                                ))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 60.0),
                                child: SizedBox(
                                  height: 200,
                                  width: 280,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Partecipanti',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 52, 52, 52)),
                                      ),
                                      detailProvider.userListById != null
                                          ? detailProvider
                                                  .userListById!.isNotEmpty
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: SizedBox(
                                                    height: 30,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: detailProvider
                                                              .userListById
                                                              ?.length ??
                                                          0,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 8.0),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  198,
                                                                  198,
                                                                  198),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(
                                                                '${detailProvider.userListById![index].name} ${detailProvider.userListById![index].surname}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink()
                                          : SizedBox.shrink(),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: GestureDetector(
                                          onTapDown: _storePosition,
                                          onLongPress: () async =>
                                              await _showSelectUserListViewPopupMenu(
                                                  context, users),
                                          child: const Text(
                                            'Aggiungi partecipanti',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MaterialButton(
                                onPressed: () async {
                                  await context
                                      .read<AppointmentListProvider>()
                                      .deleteAppointmentByMe(
                                          calendarTapDetails.appointments![0]);
                                  List<String> userIdLoaded = [];
                                  for (var users
                                      in detailProvider.userListById!) {
                                    userIdLoaded.add(users.uid);
                                  }
                                  DateTime correctedStartDate = defaulStartTime;
                                  DateTime correctedEndDate = defaultEndTime;
                                  DateFormat format =
                                      DateFormat("dd-MM-yyyy hh:mm:ss");
                                  bool isUserNotFree = false;

                                  if (dateStartController.text.isNotEmpty) {
                                    correctedStartDate = format.parse(
                                        '${dateStartController.text} ${hourDateStartController.text}:00');
                                  }
                                  if (dateEndController.text.isNotEmpty) {
                                    correctedEndDate = format.parse(
                                        '${dateEndController.text} ${hourDateEndController.text}:00');
                                  }
                                  selectedIdsList = userIdLoaded;

                                  if (selectedIdsList.isNotEmpty &&
                                      meetingNameController.text.isNotEmpty) {
                                    for (var user in selectedIdsList) {
                                      isUserNotFree = await context
                                          .read<AppointmentListProvider>()
                                          .checkAvailabilitySlot(
                                              user,
                                              correctedStartDate,
                                              correctedEndDate);
                                      if (isUserNotFree) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Container(
                                            child: Text(
                                                'uno degli utenti è impegnato per questo slot temporale'),
                                          ),
                                        );
                                        return;
                                      }
                                      //mostrare errore
                                      break;
                                    }
                                    if (isUserNotFree) {
                                      return;
                                    }
                                    context
                                        .read<NewAppointmentProvider>()
                                        .publishAppoitnemt(
                                            userIds: userIdLoaded,
                                            id: firestoreId(),
                                            color: chooseColor(selectedColor),
                                            subject: meetingNameController.text,
                                            startDate: correctedStartDate,
                                            endDate: correctedEndDate,
                                            url: urlController.text);
                                    if (mounted) {
                                      AutoRouter.of(context).pop(true);
                                      await context
                                          .read<AppointmentListProvider>()
                                          .getAppointmentsById(null);
                                    }
                                  }
                                },
                                color: Colors.blue,
                                child: const Text(
                                  'Conferma',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                AutoRouter.of(context).pop();
                              },
                              color: Colors.red,
                              child: const Text(
                                'Annulla',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                await context
                                    .read<AppointmentListProvider>()
                                    .deleteAppointmentByMe(
                                        calendarTapDetails.appointments![0]);
                                if (mounted) {
                                  AutoRouter.of(context).pop();
                                }
                              },
                              child: Container(
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7))),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]);
                }),
              ),
            );
          },
        );
      },
    );
  }
}

void showEmptyFieldsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Attenzione'),
        content: Text('Compila tutti i campi prima di confermare.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
