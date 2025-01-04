import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for input fields
  final _phoneController = TextEditingController();
  final _agentCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  // Global keys for form validation
  final _mtejaFormKey = GlobalKey<FormState>();
  final _wakalaFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _agentCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Phone number validation
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tafadhali jaza namba ya simu';
    } else if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) {
      return 'Namba ya simu lazima iwe na tarakimu 9';
    }
    return null;
  }
  // Agent code validation
  String? _validateAgentCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tafadhali jaza kodi ya wakala';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tafadhali jaza neno la siri';
    } else if (value.length < 4) {
      return 'Neno la siri lazima liwe na herufi 6 au zaidi';
    }
    return null;
  }

  // Customer login function
  Future<void> _loginMteja(String phoneNumber) async {
    final url = Uri.parse('http://softmaxafrica-001-site1.gtempurl.com/api/Customer/Login'); // Replace with your API endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customerId': '0'+phoneNumber,  // Use phoneNumber as the customerId
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Handle success (e.g., navigate to another screen)
      print('Mteja login successful: $data');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),

      );
      GoRouter.of(context).go('/customer_home');  // Navigate to Mteja home

    } else {
      // Handle error
      print('Mteja login failed: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mteja login failed')),
      );
    }
  }

  // Wakala login function
  Future<void> _loginWakala(String agentCode, String password) async {
    final url = Uri.parse('http://softmaxafrica-001-site1.gtempurl.com/api/Agent/Login'); // Replace with your API endpoint
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'agentCode': agentCode, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Handle success (e.g., navigate to another screen)
      print('Wakala login successful: $data');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      GoRouter.of(context).go('/agent_home');  // Navigate to Mteja home

    } else {
      // Handle error
      print('Wakala login failed: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wakala login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Image and Logo Section
                Stack(
                  children: [
                    Image.asset(
                      'assets/delivery.png', // Replace with your header image path
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 50,
                      right: 20,
                      child: Column(
                        children: [

                           Text(
                            'Wakala +',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Custom Tab Bar with Dynamic Blue Indicator
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        left: _tabController.index == 0 ? 0 : screenWidth / 2,
                        child: Container(
                          width: screenWidth / 2 - 16,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      TabBar(
                        controller: _tabController,
                        onTap: (index) {
                          setState(() {});
                        },
                        indicator: BoxDecoration(color: Colors.transparent),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black54,
                        dividerColor: Colors.transparent,
                         tabs: [
                          Tab(icon: Icon(Icons.museum_rounded), text: 'Mteja'),
                          Tab(icon: Icon(Icons.supervised_user_circle), text: 'Wakala'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Tab Content Section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 300,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Mteja Login
                      Form(
                        key: _mtejaFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,

                              decoration: InputDecoration(
                                suffixIconColor: Colors.red,
                                labelText: 'Namba ya simu',
                                helperText: 'Andika Namba yako ya simu ili kuendelea',
                                prefixText: '+255 ',
                                border: OutlineInputBorder(),
                              ),
                              validator: _validatePhone,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_mtejaFormKey.currentState!.validate()) {
                                  // Proceed with phone number login
                                  String phoneNumber = _phoneController.text;
                                  _loginMteja(phoneNumber);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                textStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                              ),
                              child: Text('Ingia'),
                            ),
                          ],
                        ),
                      ),
                      // Tab 2: Wakala Login
                      Form(
                        key: _wakalaFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _agentCodeController,
                              decoration: InputDecoration(
                                labelText: 'Kodi Ya Wakala (Agent Code)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_circle),
                              ),
                              validator: _validateAgentCode,
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Neno La Siri (Password)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              validator: _validatePassword,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_wakalaFormKey.currentState!.validate()) {
                                  // Proceed with agent code login
                                  String agentCode = _agentCodeController.text;
                                  String password = _passwordController.text;
                                  _loginWakala(agentCode, password);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                              child: Text('Ingia'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
