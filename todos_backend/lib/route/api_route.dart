import 'package:vania/vania.dart';
import 'package:todos_backend/app/http/controllers/auth.dart';
import 'package:todos_backend/app/http/controllers/task_controller.dart';
import 'package:todos_backend/app/http/controllers/category_controller.dart';

final categoryController = CategoryController();

class ApiRoute implements Route {
  @override
  void register() {
    // Routes for AuthController
    Router.group(() {
      Router.post('register', authController.register);
      Router.post('login', authController.login);
    }, prefix: 'auth');

    Router.get('/me', authController.me);

    Router.group(() {
      // Routes for TaskController
      Router.get('tasks', taskController.index);
      Router.get('tasks/{id}', taskController.show);
      Router.post('task', taskController.store);
      Router.put('tasks/{id}', taskController.update);
      Router.delete('tasks/{id}', taskController.destroy);

      Router.get('categories', categoryController.index);
      Router.get('categories/{id}', categoryController.show);
      Router.get('categories/{id}/tasks', categoryController.tasksByCategory);
    }, prefix: 'api');
  }
}
