import 'package:vania/vania.dart';

class CreateCategoriesTable extends Migration {
  @override
  Future<void> up() async {
    super.up();

    await createTableNotExists('categories', () {
      bigInt('category_id');
      primary('category_id');
      string('name', length: 50);
      dateTime('created_at', nullable: true);
      dateTime('updated_at', nullable: true);
      dateTime('deleted_at', nullable: true);
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('categories');
  }
}
