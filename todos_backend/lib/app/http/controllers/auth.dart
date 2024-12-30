// import 'dart:io';
import 'package:vania/vania.dart';
import 'package:todos_backend/app/models/user.dart';
import 'package:todos_backend/app/models/personal_access_token.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthController extends Controller {
  var Jwt;

  // Register
  Future<Response> register(Request request) async {
    request.validate({
      'name': 'required',
      'email': 'required|email',
      'password': 'required|min_length:6|confirmed',
    }, {
      'name.required': 'Nama tidak boleh kosong',
      'email.required': 'Email tidak boleh kosong',
      'email.email': 'Email tidak valid',
      'password.required': 'Password tidak boleh kosong',
      'password.min_length': 'Password harus terdiri dari minimal 6 karakter',
      'password.confirmed': 'Konfirmasi password tidak sesuai',
    });

    // Ambil input dari request
    final name = request.input('name');
    final email = request.input('email');
    var password = request.input('password');

    var user = await User().query().where('email', '=', email).first();
    if (user != null) {
      return Response.json({
        "message": "User sudah ada",
      }, 409);
    }

    password = Hash().make(password);

    await User().query().insert({
      "name": name,
      "email": email,
      "password": password,
      "created_at": DateTime.now().toIso8601String(),
    });

    return Response.json({"message": "Berhasil mendaftarkan user."}, 201);
  }

  // Login
  Future<Response> login(Request request) async {
    request.validate({
      'email': 'required|email',
      'password': 'required',
    }, {
      'email.required': 'Email tidak boleh kosong',
      'email.email': 'Email tidak valid',
      'password.required': 'Password tidak boleh kosong',
    });

    final email = request.input('email');
    var password = request.input('password').toString();

    var user = await User().query().where('email', '=', email).first();
    if (user == null) {
      return Response.json({
        "message": "User belum terdaftar",
      }, 409);
    }

    if (!Hash().verify(password, user['password'])) {
      return Response.json({
        "message": "Kata sandi yang anda masukan salah",
      }, 401);
    }

    final jwt = JWT({
      'user_id': user['user_id'],
      'email': user['email'],
    });

    final token = jwt.sign(SecretKey(
        'F3gg8YtBczsX2d5E0jK3qTpT0WmMx4L9S4rA2QZz3vR1pGmC6z9jA1oO9XJb3HhK'));

    await PersonalAccessToken().query().insert({
      'name': 'default',
      'tokenable_id': user['user_id'],
      'token': token, 
      'last_used_at': null, 
      'created_at': DateTime.now().toIso8601String(),
      'deleted_at': null,
    });

    print('Cek PersonalAccessToken Model: ${PersonalAccessToken()}');

    return Response.json({
      "message": "Berhasil login",
      "token": token,
    });
  }

  // Fetch Data
  Future<Response> me(Request request) async {
    String? authHeader = request.headers['authorization'];

    if (authHeader == null) {
      return Response.json(
          {"message": "Token tidak ditemukan"}, 401);
    }

    if (!authHeader.startsWith('Bearer ')) {
      return Response.json(
          {"message": "Format token tidak valid"}, 400);
    }

    String token = authHeader.substring(7);

    try {
      final jwt = JWT.verify(
          token,
          SecretKey(
              'F3gg8YtBczsX2d5E0jK3qTpT0WmMx4L9S4rA2QZz3vR1pGmC6z9jA1oO9XJb3HhK'));

      var userId = jwt.payload['user_id'];
      var user = await User().query().where('user_id', '=', userId).first();
      if (user == null) {
        return Response.json(
            {"message": "User tidak ditemukan"}, 404); 
      }

      user.remove('password');

      return Response.json({
        "message": "success",
        "data": user 
      });
    } catch (e) {
      return Response.json({"message": "Token tidak valid atau kadaluarsa"},
          401);
    }
  }
}

final AuthController authController = AuthController();
