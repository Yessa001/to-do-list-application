import 'package:vania/vania.dart';

class CreateTasksTable extends Migration {
  @override
  Future<void> up() async {
    super.up();

    await createTableNotExists('tasks', () {
      bigInt('task_id');
      bigInt('user_id');
      bigInt('category_id');
      string('title', length: 50); 
      text('description'); 
      date('due_date'); 
      string('status', length: 20);
      dateTime('created_at', nullable: true);
      dateTime('updated_at', nullable: true);
      dateTime('deleted_at', nullable: true);

      foreign('user_id', 'users', 'user_id', constrained: true, onDelete: 'CASCADE');
      foreign('category_id', 'categories', 'category_id', constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('tasks');
  }
}
