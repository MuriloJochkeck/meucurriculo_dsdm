import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

enum TipoCadastro { escolaridade, projetos, recomendacoes }

String _tituloTipo(TipoCadastro tipo) {
  return switch (tipo) {
    TipoCadastro.escolaridade => 'Escolaridade',
    TipoCadastro.projetos => 'Projetos',
    TipoCadastro.recomendacoes => 'Recomendações',
  };
}

IconData _iconeTipo(TipoCadastro tipo) {
  return switch (tipo) {
    TipoCadastro.escolaridade => Icons.school,
    TipoCadastro.projetos => Icons.code,
    TipoCadastro.recomendacoes => Icons.star,
  };
}

class AppState extends ChangeNotifier {
  final Map<TipoCadastro, List<String>> _itens = {
    // Dados iniciais para já ter conteúdo ao clicar nas seções.
    TipoCadastro.escolaridade: <String>[
      'IFC - Concórdia (2024 - atual)',
      'Ensino Médio Técnico em Informática para Internet',
    ],
    TipoCadastro.projetos: <String>[
      'GenZ Dynamics',
      'RentMaq',
      'Projeto sobre Cyberbullying',
      'Demais projetos escolares (SEPE, etc.)',
    ],
    TipoCadastro.recomendacoes: <String>[
      '“Top.”',
      '“O cara é foda.”',
      '“Melhor developer de Concórdia e região”',
    ],
  };

  List<String> itensDoTipo(TipoCadastro tipo) =>
      List.unmodifiable(_itens[tipo] ?? const <String>[]);

  int totalDoTipo(TipoCadastro tipo) => (_itens[tipo] ?? const <String>[]).length;

  void adicionar(TipoCadastro tipo, String texto) {
    final v = texto.trim();
    if (v.isEmpty) return;
    final lista = _itens[tipo] ??= <String>[];
    lista.insert(0, v);
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope não encontrado na árvore de widgets.');
    return scope!.notifier!;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState _state = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const PaginaInicial(),
      ),
    );
  }
}

class PaginaInicial extends StatelessWidget {
  const PaginaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Currículo'),
        actions: [
          IconButton(
            tooltip: 'Adicionar cadastro',
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CadastroPage()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 60,
              child: Image.asset('images/yurialberto.jpg'),
            ),
          ),

          const SizedBox(height: 20),
          

          const SizedBox(height: 25),

          // Breve descrição (fica na página inicial)
          Card(
            child: ListTile(
              title: const Text('Murilo Victor Jochkeck'),
              subtitle: const Text(
                'Eu sou o Murilo, tenho 17 anos e atualmente estou cursando o ensino médio técnico em informática para internet no IFC - Concórdia',
              ),
            ),
          ),

          // Escolaridade
          Card(
            child: ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Escolaridade'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ListaCadastrosPage(tipo: TipoCadastro.escolaridade),
                  ),
                );
              },
            ),
          ),

          // Projetos
          Card(
            child: ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Projetos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ListaCadastrosPage(tipo: TipoCadastro.projetos),
                  ),
                );
              },
            ),
          ),

          // Recomendações
          Card(
            child: ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Recomendações'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const ListaCadastrosPage(tipo: TipoCadastro.recomendacoes),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  TipoCadastro _tipo = TipoCadastro.escolaridade;

  final _textoCtrl = TextEditingController();

  @override
  void dispose() {
    _textoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<TipoCadastro>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: TipoCadastro.values
                    .map(
                      (t) => DropdownMenuItem<TipoCadastro>(
                        value: t,
                        child: Text(_tituloTipo(t)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _tipo = v);
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _textoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Texto',
                    hintText: 'Digite e salve (você pode cadastrar várias vezes).',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: null,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe um texto.';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  onPressed: () {
                    final ok = _formKey.currentState?.validate() ?? false;
                    if (!ok) return;

                    state.adicionar(_tipo, _textoCtrl.text);

                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListaCadastrosPage extends StatelessWidget {
  const ListaCadastrosPage({super.key, required this.tipo});

  final TipoCadastro tipo;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final itens = state.itensDoTipo(tipo);

    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloTipo(tipo)),
      ),
      body: itens.isEmpty
          ? Center(
              child: Text(
                'Nenhum cadastro ainda.\nToque no + para adicionar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: itens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(_iconeTipo(tipo)),
                    title: Text(itens[index]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CadastroPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
