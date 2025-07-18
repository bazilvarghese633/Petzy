class Address {
  final String id;
  final String name; // User's name
  final String houseName; // House or building name
  final String town;
  final String district;
  final String state;
  final String country;
  final String pincode;
  final String phone;
  final String instructions; // Optional delivery instructions
  final bool isSelected; // Marks default address

  Address({
    required this.id,
    required this.name,
    required this.houseName,
    required this.town,
    required this.district,
    required this.state,
    required this.country,
    required this.pincode,
    required this.phone,
    this.instructions = '',
    this.isSelected = false,
  });

  factory Address.fromMap(Map<String, dynamic> map, String id) {
    return Address(
      id: id,
      name: map['name'] ?? '',
      houseName: map['houseName'] ?? '',
      town: map['town'] ?? '',
      district: map['district'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      pincode: map['pincode'] ?? '',
      phone: map['phone'] ?? '',
      instructions: map['instructions'] ?? '',
      isSelected: map['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'houseName': houseName,
    'town': town,
    'district': district,
    'state': state,
    'country': country,
    'pincode': pincode,
    'phone': phone,
    'instructions': instructions,
    'isSelected': isSelected,
  };

  Address copyWith({
    String? name,
    String? houseName,
    String? town,
    String? district,
    String? state,
    String? country,
    String? pincode,
    String? phone,
    String? instructions,
    bool? isSelected,
  }) {
    return Address(
      id: id,
      name: name ?? this.name,
      houseName: houseName ?? this.houseName,
      town: town ?? this.town,
      district: district ?? this.district,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      instructions: instructions ?? this.instructions,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
