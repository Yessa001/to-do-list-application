import 'package:vania/vania.dart';

class CreateUsersTable extends Migration {

  @override
  Future<void> up() async{
   super.up();
   await createTableNotExists('users', () {
      bigInt('user_id');
      string('name', length: 100);
      string('email', length: 100);
      string('password', length: 200);
      dateTime('created_at', nullable: true);
      dateTime('updated_at', nullable: true);
      dateTime('deleted_at', nullable: true);
    });
  }
  
  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('users');
  }
}
