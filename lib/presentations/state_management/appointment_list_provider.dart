import 'package:flutter/cupertino.dart';
import 'package:portal/data/models/appointement_model.dart';
import 'package:portal/data/services/interfaces/appointment_service.dart';
import 'package:portal/data/services/interfaces/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentListProvider with ChangeNotifier {
  final AppointmentService? appointmentService;
  final UserService? userService;
  final SharedPreferences? sharedPreferences;

  AppointmentListProvider(
      {@required this.appointmentService,
      @required this.userService,
      @required this.sharedPreferences});

  bool loading = false;

  List<AppointmentModel>? _appointmentListByMe;
  List<AppointmentModel>? _nextAppointmentList;
  List<AppointmentModel>? get appointmentListByMe => _appointmentListByMe;
  List<AppointmentModel>? get nextAppointmentList => _nextAppointmentList;

  getAppointmentsById(String? id) async {
    _startOperation();

    Future.delayed(const Duration(milliseconds: 500), () async {
      var tempUserId = sharedPreferences!.getString("userId");
      if (tempUserId == null) {
        _endOperation();
        return;
      }
      _appointmentListByMe = await appointmentService!
          .getAllAppointmentById(userId: id ?? tempUserId);

      _endOperation();
    });
  }

  getNextAppointmentAvailable(String? id) async {
    _startOperation();
    await cleanNextAppointmentList();
    List<AppointmentModel> listCheckAppointment = [];

    var appointmentByUserId =
        await appointmentService!.getAllAppointmentById(userId: id!);
    //appointmentByUserId.where((e) => e.startTime.isAfter(DateTime.now()));
    for (var appointment in appointmentByUserId) {
      if (appointment.startTime.isAfter(DateTime.now())) {
        listCheckAppointment.add(appointment);
      }
    }
    listCheckAppointment.sort((a, b) => a.startTime.compareTo(b.startTime),);
    _nextAppointmentList = listCheckAppointment;
    _endOperation();
  } 

  cleanNextAppointmentList() async {
    _startOperation();
    _nextAppointmentList = [];
    _endOperation();
  }

  Future<bool> checkAvailabilitySlot(
      String userIds, DateTime startDate, DateTime endDate) async {
    // var appointmentByUserId =
    //     await appointmentService!.getAllAppointmentById(userId: userIds);
    // return appointmentByUserId.any((element) =>
    //     (startDate.isAfter(element.startTime) &&
    //         startDate.isBefore(element.endTime)) ||
    //     (endDate.isAfter(element.startTime) &&
    //         endDate.isBefore(element.endTime)));
    return false;
  }

  deleteAppointmentByMe(AppointmentModel appointment) async {
    _startOperation();
    Future.delayed(const Duration(milliseconds: 500), () async {
      await appointmentService!.deleteAppointment(appointment: appointment);
      _appointmentListByMe!.remove(appointment);
      _endOperation();
    });
  }

  getPostsByDoctorId({required String doctorId}) async {
    _startOperation();
    _appointmentListByMe =
        await appointmentService!.getAllAppointmentById(userId: doctorId);

    _endOperation();
  }

  // #region Methods for manage loader
  _startOperation() {
    loading = true;
    notifyListeners();
  }

  _endOperation() {
    loading = false;
    notifyListeners();
  }
// #endregion
}
