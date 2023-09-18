import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  _CompanyPageState createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompaniesPage> {
  List<dynamic> companies = [];

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        developer.log('Token không tồn tại');
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.52:8000/api/companies'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedResponse = jsonDecode(response.body);
        List<dynamic> fetchedCompanies = parsedResponse['data'];

        setState(() {
          companies = fetchedCompanies;
        });
      } else {
        developer.log('Error response: ${response.statusCode}');
        developer.log('Error response body: ${response.body}');
      }
    } catch (e) {
      developer.log('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công ty'),
      ),
      body: ListView.builder(
        itemCount: companies.length,
        itemBuilder: (BuildContext context, int index) {
          final company = companies[index];
          return ListTile(
            title: Text(company['name']),
            onTap: () {},
          );
        },
      ),
    );
  }
}