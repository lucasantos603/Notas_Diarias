//@dart=2.9
import 'package:flutter/material.dart';
import 'package:notas_diarias/helper/anotacaoHelper.dart';
import 'package:notas_diarias/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  // const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  List<Anotacao> _anotacoes = List<Anotacao>();
  var _db = AnotacaoHelper();

  _exibirTelaNota({Anotacao anotacao}) {
    String textoSalvarAtualizer = "";
    if (anotacao == null) {
      //adicionando uma nova nota
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizer = "Salvar";
    } else {
      //atualizando uma nota
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizer = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("$textoSalvarAtualizer anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Titulo", hintText: "Digite título..."),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite a Descrição..."),
                ),
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar")),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);

                    _descricaoController.clear();
                    _tituloController.clear();
                  },
                  child: Text(textoSalvarAtualizer))
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    List<Anotacao> listaTemporaria = [];

    for (var lista in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(lista);
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });

    listaTemporaria = null;

    _recuperarAnotacoes();

    // print("Lista anotacoes: " + anotacoesRecuperadas.toString());
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    //salvando
    if (anotacaoSelecionada == null) {
      Anotacao anotacao =
          Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      //atualizando
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();

      int resultado = await _db.atualizarNota(anotacaoSelecionada);
    }

    // print("data atual: " + DateTime.now().toString());
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");

    // var formatador = DateFormat("y/M/d H:m:s");
    var formatador = DateFormat.yMMMd("pt_BR");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    await _db.removerAnotacao(id);

    _recuperarAnotacoes();
  }

  @override
  void initState() {
    _recuperarAnotacoes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("minhas anotações"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _anotacoes.length,
            itemBuilder: (context, index) {
              final item = _anotacoes[index];

              return Card(
                child: ListTile(
                  title: Text(item.titulo),
                  subtitle:
                      Text("${_formatarData(item.data)} - ${item.descricao} "),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        //Anotação
                        onTap: () {
                          _exibirTelaNota(anotacao: item);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      GestureDetector(
                        //Excluir
                        onTap: () {
                          _removerAnotacao(item.id);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exibirTelaNota,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
