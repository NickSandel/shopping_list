import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const ShoppingList(),
    );
  }
}

class Product {
  const Product({required this.name});

  final String name;
}

typedef CartChangedCallback = Function(Product product, bool inCart);
typedef ItemRemovedCallback = Function(Product product);

class ShoppingListItem extends StatelessWidget {
  ShoppingListItem({
    required this.product,
    required this.inCart,
    required this.onCartChanged,
    required this.onRemoveItem,
  }) : super(key: ObjectKey(product));

  final Product product;
  final bool inCart;
  final CartChangedCallback onCartChanged;
  final ItemRemovedCallback onRemoveItem;

  Color _getColor(BuildContext context) {
    // The theme depends on the BuildContext because different
    // parts of the tree can have different themes.
    // The BuildContext indicates where the build is
    // taking place and therefore which theme to use.

    return inCart //
        ? Colors.black54
        : Theme.of(context).primaryColor;
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if (!inCart) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          onCartChanged(product, inCart);
        },
        leading: CircleAvatar(
          backgroundColor: _getColor(context),
          child: Text(product.name[0]),
        ),
        title: Text(
          product.name,
          style: _getTextStyle(context),
        ),
        trailing: IconButton(
            color: _getColor(context),
            icon: const Icon(Icons.delete),
            onPressed: () {
              onRemoveItem(product);
            }));
  }
}

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  ShoppingListState createState() => ShoppingListState();
}

class ShoppingListState extends State<ShoppingList> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final List<String> _shoppingItems = <String>[];
  final List<Product> _shoppingList = <Product>[];
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _getShoppingItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> items = prefs.getStringList("shopping_list") ?? [];
    _shoppingItems.clear();
    for (String item in items) {
      _shoppingItems.add(item);
    }
    setState(() {});
    // });
  }

  void _handleCartChanged(Product product, bool inCart) {
    setState(() {
      // When a user changes what's in the cart, you need
      // to change _shoppingCart inside a setState call to
      // trigger a rebuild.
      // The framework then calls build, below,
      // which updates the visual appearance of the app.

      if (!inCart) {
        _shoppingList.add(product);
      } else {
        _removeItem(product.name);
      }
    });
  }

  void _removeItem(String itemName) {
    // Loop through to find the product to remove but only remove it after
    List<Product> itemToRemove = <Product>[];
    for (Product listItem in _shoppingList) {
      if (listItem.name == itemName) {
        itemToRemove.add(listItem);
      }
    }
    _shoppingList.removeWhere((item) => itemToRemove.contains(item));
  }

  void _removeAll() {
    setState(() {
      _shoppingItems.clear();
      save(_shoppingItems);
    });
  }

  void _handleItemRemoved(Product product) {
    setState(() {
      // When a user changes what's in the cart, you need
      // to change _shoppingCart inside a setState call to
      // trigger a rebuild.
      // The framework then calls build, below,
      // which updates the visual appearance of the app.

      _shoppingItems.remove(product.name);
      save(_shoppingItems);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _getShoppingItems();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: _getItems()),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          onPressed: () => _displayDialog(context),
          tooltip: 'Add Item',
          heroTag: null,
          child: const Icon(Icons.add),
        ),
        const SizedBox(
          height: 30,
        ),
        FloatingActionButton(
            onPressed: () => _removeAll(),
            tooltip: 'Remove All',
            heroTag: null,
            child: const Icon(Icons.delete_sweep_rounded)),
      ]),
    );
  }

  void _addShoppingItem(String title) {
    // Wrapping it inside a set state will notify
    // the app that the state has changed
    setState(() {
      _shoppingItems.add(title);
      save(_shoppingItems);
    });
    _textFieldController.clear();
  }

  void save(list) async {
    final prefs = await _prefs;
    await prefs.remove("shopping_list");
    await prefs.setStringList("shopping_list", list);
  }

  // Generate a single item widget
  Future<dynamic> _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add an item to your shopping'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: 'Enter item here'),
              textCapitalization: TextCapitalization.words,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ADD'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _addShoppingItem(_textFieldController.text);
                },
              ),
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  List<Widget> _getItems() {
    final List<Widget> todoWidgets = <Widget>[];
    for (String product in _shoppingItems) {
      todoWidgets.add(ShoppingListItem(
        product: Product(name: product),
        inCart: _checkList(product),
        onCartChanged: _handleCartChanged,
        onRemoveItem: _handleItemRemoved,
      ));
    }
    return todoWidgets;
  }

  bool _checkList(name) {
    for (Product product in _shoppingList) {
      if (product.name == name) {
        return true;
      }
    }
    return false;
  }
}
