class Booking {
  final String id;
  final String bookingId;
  final String status;
  final DateTime pickupDateTime;
  final List<String> addresses;
  final String? supplier;
  final String? bookingFormName;
  final double price;
  final double earning;
  final int passengersNumber;
  final String? vehicleName;
  final String firstName;
  final String lastName;
  final String? emailAddress;
  final String? phoneNumber;
  final String? comment;
  final String? paymentName;
  final String? flightNumber;
  final String? whatsapp;
  final double? distance;
  final String? driverName;
  final String? driverContact;
  final String? plateNumber;
  final List<String>? extras;
  final String? gclid;

  Booking({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.pickupDateTime,
    required this.addresses,
    this.supplier,
    this.bookingFormName,
    required this.price,
    required this.earning,
    required this.passengersNumber,
    this.vehicleName,
    required this.firstName,
    required this.lastName,
    this.emailAddress,
    this.phoneNumber,
    this.comment,
    this.paymentName,
    this.flightNumber,
    this.whatsapp,
    this.distance,
    this.driverName,
    this.driverContact,
    this.plateNumber,
    this.extras,
    this.gclid,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      status: json['status'] ?? '',
      pickupDateTime: DateTime.parse(json['pickup_datetime']),
      addresses: List<String>.from(json['addresses'] ?? []),
      supplier: json['supplier'],
      bookingFormName: json['booking_form_name'],
      price: (json['price'] ?? 0).toDouble(),
      earning: (json['earning'] ?? 0).toDouble(),
      passengersNumber: json['passengers_number'] ?? 1,
      vehicleName: json['vehicle_name'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      emailAddress: json['email_address'],
      phoneNumber: json['phone_number'],
      comment: json['comment'],
      paymentName: json['payment_name'],
      flightNumber: json['flight_number'],
      whatsapp: json['whatsapp'],
      distance: json['distance']?.toDouble(),
      driverName: json['driver_name'],
      driverContact: json['driver_contact'],
      plateNumber: json['plate_number'],
      extras: json['extras'] != null 
          ? (json['extras'] is List 
              ? List<String>.from(json['extras'])
              : [json['extras'].toString()])
          : null,
      gclid: json['gclid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'booking_id': bookingId,
      'status': status,
      'pickup_datetime': pickupDateTime.toIso8601String(),
      'addresses': addresses,
      'supplier': supplier,
      'booking_form_name': bookingFormName,
      'price': price,
      'earning': earning,
      'passengers_number': passengersNumber,
      'vehicle_name': vehicleName,
      'first_name': firstName,
      'last_name': lastName,
      'email_address': emailAddress,
      'phone_number': phoneNumber,
      'comment': comment,
      'payment_name': paymentName,
      'flight_number': flightNumber,
      'whatsapp': whatsapp,
      'distance': distance,
      'driver_name': driverName,
      'driver_contact': driverContact,
      'plate_number': plateNumber,
      'extras': extras,
      'gclid': gclid,
    };
  }

  String get fullName => '$firstName $lastName';
  String get route => addresses.join(' → ');
  bool get isGoogleAds => gclid != null && gclid!.isNotEmpty;

  Booking copyWith({
    String? id,
    String? bookingId,
    String? status,
    DateTime? pickupDateTime,
    List<String>? addresses,
    String? supplier,
    String? bookingFormName,
    double? price,
    double? earning,
    int? passengersNumber,
    String? vehicleName,
    String? firstName,
    String? lastName,
    String? emailAddress,
    String? phoneNumber,
    String? comment,
    String? paymentName,
    String? flightNumber,
    String? whatsapp,
    double? distance,
    String? driverName,
    String? driverContact,
    String? plateNumber,
    List<String>? extras,
    String? gclid,
  }) {
    return Booking(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      status: status ?? this.status,
      pickupDateTime: pickupDateTime ?? this.pickupDateTime,
      addresses: addresses ?? this.addresses,
      supplier: supplier ?? this.supplier,
      bookingFormName: bookingFormName ?? this.bookingFormName,
      price: price ?? this.price,
      earning: earning ?? this.earning,
      passengersNumber: passengersNumber ?? this.passengersNumber,
      vehicleName: vehicleName ?? this.vehicleName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      emailAddress: emailAddress ?? this.emailAddress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      comment: comment ?? this.comment,
      paymentName: paymentName ?? this.paymentName,
      flightNumber: flightNumber ?? this.flightNumber,
      whatsapp: whatsapp ?? this.whatsapp,
      distance: distance ?? this.distance,
      driverName: driverName ?? this.driverName,
      driverContact: driverContact ?? this.driverContact,
      plateNumber: plateNumber ?? this.plateNumber,
      extras: extras ?? this.extras,
      gclid: gclid ?? this.gclid,
    );
  }
} 