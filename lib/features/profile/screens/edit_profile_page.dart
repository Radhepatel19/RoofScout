import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roofscout/features/home/screens/select_city_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roofscout/features/auth/services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _selectedGender = "Male";
  final List<String> _genderOptions = ["Male", "Female", "Other", "Prefer not to say"];

  String _selectedLookingFor = "Rent";
  final List<String> _lookingForOptions = ["Rent", "Buy", "Invest", "Commercial"];

  String _selectedOccupation = "Software Engineer";
  final List<String> _occupationOptions = [
    "Software Engineer",
    "Business Owner",
    "Doctor",
    "Teacher",
    "Student",
    "Government Employee",
    "Private Employee",
    "Other"
  ];

  String _profileImageUrl = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d";
  bool _isUploadingImage = false;
  bool _isLoading = false;
  int? _userId;
  Map<String, dynamic>? _existingUserData;

  @override
  void initState() {
    super.initState();
    // Load existing user data
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt("user_id");

      if (_userId != null) {
        final result = await UserService.getUserProfile(_userId!);
        if (result["success"]) {
          final data = result["data"];
          _existingUserData = data;
          setState(() {
            _nameController.text = data["full_name"] ?? "";
            _emailController.text = data["email"] ?? "";
            _phoneController.text = data["phone"] ?? "";
            _locationController.text = data["city"] ?? "";
            _bioController.text = data["about_me"] ?? "";
            String backendGender = data["gender"] ?? "Male";
            _selectedGender = _genderOptions.firstWhere(
              (opt) => opt.toLowerCase() == backendGender.toLowerCase(),
              orElse: () => "Male",
            );

            _selectedOccupation = data["occupation"] ?? "Software Engineer";

            String backendLookingFor = data["looking_for"] ?? "Rent";
            _selectedLookingFor = _lookingForOptions.firstWhere(
              (opt) => opt.toLowerCase() == backendLookingFor.toLowerCase(),
              orElse: () => "Rent",
            );
            if (data["profile_picture"] != null && data["profile_picture"].toString().isNotEmpty) {
              _profileImageUrl = data["profile_picture"];
            }
          });
        } else {
          _showError(result["message"]);
        }
      }
    } catch (e) {
      _showError("Failed to load profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _changeProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image selected. Save profile to upload."),
            backgroundColor: Color(0xFF0066FF),
          ),
        );
      }
    } catch (e) {
      _showError("Failed to pick image: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_userId == null) {
        _showError("User ID not found. Please log in again.");
        return;
      }

      setState(() => _isLoading = true);
      try {
        final userData = {
          "full_name": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneController.text,
          "city": _locationController.text,
          "about_me": _bioController.text,
          "gender": _selectedGender,
          "occupation": _selectedOccupation,
          "looking_for": _selectedLookingFor,
          "profile_picture": _pickedImage?.path ?? _profileImageUrl,
        };

        Map<String, dynamic> result;
        bool isUpdate = !(_existingUserData == null || _existingUserData!["email"] == null || _existingUserData!["email"] == "");

        if (isUpdate) {
          result = await UserService.updateProfile(_userId!, userData);
        } else {
          result = await UserService.registerProfile(userData);
        }

        if (result["success"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["message"] ?? "Profile saved successfully"),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          Navigator.pop(context);
        } else {
          final errorMessage = result["message"] ?? (isUpdate ? "Failed to update profile" : "Failed to register profile");
          _showError(errorMessage);
        }
      } catch (e) {
        _showError("An unexpected error occurred: $e");
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetChanges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Changes?"),
        content: Text("Are you sure you want to discard all changes?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadUserData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Changes discarded"),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            child: const Text(
              "Reset",
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 1,
            titleSpacing: 0,
            pinned: true,
            title: const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black87,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.done_rounded, size: 20),
                    onPressed: _saveProfile,
                    color: Color(0xFF0066FF),
                  ),
                ),
              ),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: _isLoading
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0066FF)),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Picture Section
                          _buildProfilePictureSection(),

                          SizedBox(height: 32),

                          // Personal Information
                          _buildSectionHeader("Personal Information"),
                          const SizedBox(height: 16),
                          _buildNameField(),
                          const SizedBox(height: 16),
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          _buildPhoneField(),
                          const SizedBox(height: 16),
                          _buildLocationField(),

                          const SizedBox(height: 32),
                          // Additional Information
                          _buildSectionHeader("Additional Information"),
                          const SizedBox(height: 16),
                          _buildGenderField(),
                          const SizedBox(height: 16),
                          _buildOccupationField(),
                          const SizedBox(height: 16),
                          _buildLookingForField(),

                          SizedBox(height: 32),

                          // Bio Section
                          _buildSectionHeader("About Me"),
                          SizedBox(height: 16),
                          _buildBioField(),

                          SizedBox(height: 40),

                          // Action Buttons
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          children: [
            // Profile Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: Color(0xFF0066FF),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(57),
                child: _isUploadingImage
                    ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0066FF),
                  ),
                )
                    : _pickedImage != null
                        ? Image.file(
                            File(_pickedImage!.path),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                  _profileImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFF0066FF).withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF0066FF),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Edit Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _changeProfileImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF0066FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        Text(
          "Tap camera icon to change profile picture",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFF0066FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: "Full Name",
          hintText: "Enter your full name",
          prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF0066FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
        ),
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          if (value.length < 2) {
            return 'Name must be at least 2 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: "Email Address",
          hintText: "Enter your email address",
          prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF0066FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
        ),
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _phoneController,
        readOnly: true,           // ❌ cannot edit
        enableInteractiveSelection: false, // ❌ no copy/paste
        keyboardType: TextInputType.none,   // ❌ no keyboard
        decoration: InputDecoration(
          labelText: "Phone Number",
          prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF0066FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.all(20),
        ),
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }


  Widget _buildLocationField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _locationController,
        readOnly: true, // Make read-only as we'll pick from a list
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectCityPage(returnResult: true),
            ),
          );

          if (result != null && result is Map) {
            setState(() {
              _locationController.text = "${result['name']}, ${result['state']}";
            });
          }
        },
        decoration: InputDecoration(
          labelText: "Location",
          hintText: "Select your city and state",
          prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF0066FF)),
          suffixIcon: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
        ),
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your location';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: "Gender",
          prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF0066FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        items: _genderOptions.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue!;
          });
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildOccupationField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedOccupation,
        decoration: InputDecoration(
          labelText: "Occupation",
          prefixIcon: Icon(Icons.work_outline_rounded, color: Color(0xFF0066FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        items: _occupationOptions.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedOccupation = newValue!;
          });
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildLookingForField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLookingFor,
        decoration: InputDecoration(
          labelText: "Looking For",
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF0066FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        items: _lookingForOptions.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1E293B),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedLookingFor = newValue!;
          });
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _bioController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: "About Me / Requirements",
          hintText: "Tell us about yourself or your property requirements",
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
        ),
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some information';
          }
          if (value.length < 10) {
            return 'Please enter at least 10 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Reset Button
        Expanded(
          child: OutlinedButton(
            onPressed: _resetChanges,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFFE2E8F0)),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restart_alt_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                SizedBox(width: 8),
                Text(
                  "Reset Changes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 16),

        // Save Button
        Expanded(
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0066FF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.save_rounded,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}