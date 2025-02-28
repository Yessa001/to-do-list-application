import 'dart:io';
import 'package:vania/vania.dart';
import 'create_users_table.dart';
import 'create_tasks_table.dart';
import 'create_categories_table.dart';
import 'create_personal_access_tokens_table.dart';

void main(List<String> args) async {
  await MigrationConnection().setup();
  if (args.isNotEmpty && args.first.toLowerCase() == "migrate:fresh") {
    await Migrate().dropTables();
  } else {
    await Migrate().registry();
  }
  await MigrationConnection().closeConnection();
  exit(0);
}

class Migrate {
  registry() async {
     await CreatePersonalAccessTokensTable().up();
		//  await CreateUsersTable().up();
 		//  await CreateCategoriesTable().up();
		//  await CreateTasksTable().up();
	}

  dropTables() async {
		 await CreatePersonalAccessTokensTable().down();
		 await CreateCategoriesTable().down();
		 await CreateTasksTable().down();
		 await CreateUsersTable().down();
	 }
}
