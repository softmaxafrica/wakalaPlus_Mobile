import 'package:flutter/material.dart';

class WakalaRegistrationScreen extends StatelessWidget {
  final TextEditingController agentFullNameController = TextEditingController();
  final TextEditingController nidaController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController agentCodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jisajili kama Wakala'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Karibu wakala wetu mpya',
                  style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Jina Kamili', 'eg Daniel Hussein', agentFullNameController),
              _buildTextField('Nida', '19901221151210000122', nidaController),
              Text(
                'Chagua Mtandao',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildCheckBox('Airtel'),
              _buildCheckBox('Halotel'),
              _buildCheckBox('Tigo'),
              _buildCheckBox('Vodacom'),
              _buildCheckBox('Ttcl'),
              Text(
                'Huduma za Mtandao',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildCheckBox('Huduma Za Laini'),
              _buildCheckBox('Huduma Za Kifedha'),
              _buildTextField('Neno La Siri', 'eg Ahmn@#HFY_302#', passwordController, isPassword: true),
              _buildTextField('Namba Ya Simu', 'eg +255 *** *** ***', phoneController),
              _buildTextField('Kodi ya Wakala', 'Enter Agent Code', agentCodeController),
              _buildTextField('Eneo La Kazi', 'eg Makumbusho Dar es salaam', addressController),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle registration logic here
                  },
                  child: Text('Jisajili'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCheckBox(String text) {
    return Row(
      children: [
        Checkbox(
          value: false, // This should be connected to a state management solution
          onChanged: (bool? newValue) {
            // Handle state change here
          },
        ),
        Text(text),
      ],
    );
  }
}
