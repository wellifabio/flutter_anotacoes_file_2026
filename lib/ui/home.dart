import '../root/file.dart';
import 'package:intl/intl.dart';

import '../models/anotacao.dart';

import './style/colors.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Anotacao> dados = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() async {
    List<String> linhas = (await GerenciaArquivo.lerArquivo()).split('\n');
    setState(() {
      dados = linhas
          .where((linha) => linha.trim().isNotEmpty)
          .map((linha) {
            List<String> partes = linha.split(',');
            if (partes.length >= 2) {
              return Anotacao(
                data: partes[0],
                texto: partes.sublist(1).join(','),
              );
            }
            return null;
          })
          .whereType<Anotacao>()
          .toList();
    });
  }

  void salvarDados() {
    String conteudo = dados.map((a) => a.toCSV()).join('\n');
    GerenciaArquivo.salvarArquivo(conteudo);
  }

  void modalAdd(String? anotacao, int? indice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Anotação'),
          content: TextField(
            controller: TextEditingController(text: anotacao),
            style: TextStyle(color: AppColors.p1),
            onChanged: (value) {
              setState(() {
                anotacao = value;
              });
            },
            maxLines: null,
            minLines: 5,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(hintText: "Digite sua anotação aqui"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if (indice != null) {
                    dados[indice] = Anotacao(
                      data: DateTime.now().toString(),
                      texto: anotacao ?? dados[indice].texto,
                    );
                  } else {
                    dados.add(
                      Anotacao(
                        data: DateTime.now().toString(),
                        texto: anotacao ?? '',
                      ),
                    );
                  }
                });
                salvarDados();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void modalDelete(int indice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir Anotação'),
          content: Text('Tem certeza que deseja excluir esta anotação?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  dados.removeAt(indice);
                });
                salvarDados();
              },
              child: Text('Sim'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Não'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anotações'),
        actions: [
          GestureDetector(
            onTap: () => modalAdd(null, null),
            child: Container(
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.p4,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: AppColors.p1, size: 35),
            ),
          ),
        ],
      ),
      body: Center(
        child: ListView.separated(
          itemBuilder: (context, i) {
            return ListTile(
              title: Text(
                '${DateFormat('dd/MM/yyyy').format(DateTime.parse(dados[i].data))} - ${DateFormat('hh:mm').format(DateTime.parse(dados[i].data))}',
              ),
              subtitle: Text(dados[i].texto),
              trailing: GestureDetector(
                onTap: () {
                  modalDelete(i);
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.p1,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete, color: AppColors.p4),
                ),
              ),
              onTap: () => modalAdd(dados[i].texto, i),
            );
          },
          separatorBuilder: (_, _) => Divider(),
          itemCount: dados.length,
        ),
      ),
    );
  }
}
