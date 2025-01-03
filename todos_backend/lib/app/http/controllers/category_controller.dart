import 'package:vania/vania.dart';
import 'package:todos_backend/app/models/category.dart';
import 'package:todos_backend/app/models/task.dart';

class CategoryController extends Controller {
  // Menampilkan semua kategori
  Future<Response> index() async {
    final categories = await Category().query().get();
    return Response.json({'data': categories});
  }

  // Menambahkan kategori baru
  Future<Response> store(Request request) async {
    try {
      request.validate({
        'name': 'required|string|max_length:100',
      });

      final categoryData = request.input();
      categoryData['created_at'] = DateTime.now().toIso8601String();

      final category = await Category().query().insert(categoryData);

      return Response.json({
        'message': 'Kategori berhasil ditambahkan.',
        'data': category,
      }, 201);
    } catch (e) {
      return Response.json({'message': 'Terjadi kesalahan di sisi server.'}, 500);
    }
  }

  // Mendapatkan detail kategori berdasarkan ID
  Future<Response> show(int id) async {
    final category = await Category().query().where('id', '=', id).first();

    if (category == null) {
      return Response.json({'message': 'Kategori tidak ditemukan.'}, 404);
    }

    return Response.json({'data': category});
  }

  // Mengambil task berdasarkan kategori
  Future<Response> tasksByCategory(int categoryId) async {
    try {
      final tasks = await Task().query().where('category_id', '=', categoryId).get();

      if (tasks.isEmpty) {
        return Response.json({'message': 'Tidak ada task yang ditemukan untuk kategori ini.'}, 404);
      }

      return Response.json({'data': tasks});
    } catch (e) {
      return Response.json({'message': 'Terjadi kesalahan saat mengambil task berdasarkan kategori.'}, 500);
    }
  }
}

final CategoryController categoryController = CategoryController();
