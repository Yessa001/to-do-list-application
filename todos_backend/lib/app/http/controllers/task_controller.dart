import 'dart:io';
import 'package:vania/vania.dart';
import 'package:todos_backend/app/models/task.dart';

class TaskController extends Controller {
  // Menampilkan semua task
  Future<Response> index() async {
    final tasks = await Task().query().get();
    return Response.json({'data': tasks});
  }

  // Menambahkan task baru
  Future<Response> store(Request request) async {
    try {
      request.validate({
        'user_id': 'required|integer',
        'category_id': 'required|integer',
        'title': 'required|string|max_length:100',
        'description': 'string|max_length:255',
        'due_date': 'required|date',
        'status': 'string|max_length:20',
      });

      final taskData = request.input();
      taskData['created_at'] = DateTime.now().toIso8601String();

      // Memasukkan task ke database
      final task = await Task().query().insert(taskData);

      return Response.json({
        'message': 'Task berhasil ditambahkan.',
        'data': task,
      }, 201);
    } catch (e) {
      return Response.json(
          {'message': 'Terjadi kesalahan di sisi server.'}, 500);
    }
  }

  // Mendapatkan detail task berdasarkan ID
  Future<Response> show(int id) async {
    final task = await Task().query().where('task_id', '=', id).first();

    if (task == null) {
      return Response.json({'message': 'Task tidak ditemukan.'}, 404);
    }

    return Response.json({'data': task});
  }

  // Memperbarui task
  Future<Response> update(Request request, int id) async {
    try {
      // Log input untuk debugging
      print('Request body: ${request.all()}');
      print('Task ID: $id');

      // Validasi input
      request.validate({
        'title': 'required',
        'description': 'required',
        'due_date': 'required|date',
        'status': 'required',
        'category_id': 'required|integer', // Pastikan kategori divalidasi
      });

      // Ambil data yang akan diupdate
      final data = {
        'title': request.input('title'),
        'description': request.input('description'),
        'due_date': request.input('due_date'),
        'status': request.input('status'),
        'category_id': request.input('category_id'), // Tambahkan category_id
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update task berdasarkan ID
      final updated =
          await Task().query().where('task_id', '=', id).update(data);

      // Cek apakah task berhasil diupdate
      if (updated == 0) {
        return Response.json({
          "message": "Task tidak ditemukan",
        }, HttpStatus.notFound);
      }

      return Response.json({
        "message": "Task berhasil diupdate",
        "data": data,
      }, HttpStatus.ok);
    } catch (e) {
      // Log error untuk debugging
      print('Error saat update task: $e');
      return Response.json({
        "message": "Terjadi kesalahan di sisi server.",
      }, HttpStatus.internalServerError);
    }
  }

  // Menghapus task
  Future<Response> destroy(int id) async {
    final deleted = await Task().query().where('task_id', '=', id).delete();

    if (deleted == 0) {
      return Response.json({'message': 'Task tidak ditemukan.'}, 404);
    }

    return Response.json({'message': 'Task berhasil dihapus.'});
  }
}

final TaskController taskController = TaskController();
