import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class CompanyDetailPage extends StatelessWidget {
  final int companyId;

  const CompanyDetailPage({super.key, required this.companyId});

  Future<Map<String, dynamic>> _fetchCompanyDetail(int companyId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        developer.log('Token không tồn tại');
        return {};
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.52:8000/api/companies/$companyId'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        developer.log('Error response: ${response.statusCode}');
        developer.log('Error response body: ${response.body}');
        return {};
      }
    } catch (e) {
      developer.log('Error: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công ty'),
      ),
      body: FutureBuilder(
        future: _fetchCompanyDetail(companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Lỗi: ${snapshot.error}');
          } else {
            final Map<String, dynamic> companyData =
                snapshot.data as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên công ty: ${companyData['name']}'),
                  Text('Tax Code: ${companyData['tax_code']}'),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
