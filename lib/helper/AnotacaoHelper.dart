//@dart=2.9
import 'package:notas_diarias/model/Anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  static final String nomeTabela = "anotacao";
  static final String colunaId = "id";
  static final String colunaTitulo = "titulo";
  static final String colunaDescricao = "descricao";
  static final String colunaData = "data";

  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();
  Database _db;

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal() {}

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    /*

    id titulo descricao data
    01 teste  teste     02/10/2020

    * */

    String sql = "CREATE TABLE $nomeTabela ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "titulo VARCHAR, "
        "descricao TEXT, "
        "data DATETIME)";
    await db.execute(sql);
  }

  inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados =
        join(caminhoBancoDados, "banco_minhas_anotacoes.db");

    var db =
        await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  recuperarAnotacoes() async {
    var bancoDados = await db;
    String sql = 'SELECT * FROM $nomeTabela ORDER BY data DESC';
    List anotacoes = await bancoDados.rawQuery(sql);

    return anotacoes;
  }

  Future<int> atualizarNota(Anotacao anotacao) async {
    var bancoDados = await db;
    await bancoDados
        .update(nomeTabela, anotacao.toMap(), where: "id = ?", whereArgs: []);
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;
    int resultado = await bancoDados.insert(nomeTabela, anotacao.toMap());
    return resultado;
  }

  Future<int> removerAnotacao(int id) async {
    var bancoDados = await db;
    return await bancoDados
        .delete(nomeTabela, where: "id = ?", whereArgs: [id]);
  }
}
