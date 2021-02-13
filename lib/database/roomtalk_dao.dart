import 'package:sembast/sembast.dart';
import 'package:siuu_tchat/core/model/message.dart';
import 'package:siuu_tchat/database/app_database.dart';
import 'package:siuu_tchat/model/discussion.dart';

class RoomTalkDao{
  static const String DISCUSSION_STORE_NAME = 'roomtalk';
  final _roomStore = intMapStoreFactory.store(DISCUSSION_STORE_NAME);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insert(Message message) async {
    await _roomStore.add(await _db,message.toMap());
  }


  Future<List<Message>> getAll() async {

    final recordSnapshots = await _roomStore.find(
      await _db,
    );
    return recordSnapshots.map((snapshot) {
      final fruit = Message.fromJson(snapshot.value);
      return fruit;
    }).toList();
  }
}