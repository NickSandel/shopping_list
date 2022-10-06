import 'package:flutter/material.dart';

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
      home: ShoppingList(),
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
  // const ShoppingList({required this.products, super.key});

  // final List<Product> products;

  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  final List<Product> _shoppingItems = <Product>[];
  final List<Product> _shoppingList = <Product>[];
  final TextEditingController _textFieldController = TextEditingController();

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
        _shoppingList.remove(product);
      }
    });
  }

  void _handleItemRemoved(Product product) {
    setState(() {
      // When a user changes what's in the cart, you need
      // to change _shoppingCart inside a setState call to
      // trigger a rebuild.
      // The framework then calls build, below,
      // which updates the visual appearance of the app.

      _shoppingItems.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping List')),
      body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: _getItems()),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          tooltip: 'Add Item',
          child: const Icon(Icons.add)),
    );
  }

  void _addShoppingItem(String title) {
    // Wrapping it inside a set state will notify
    // the app that the state has changed
    setState(() {
      _shoppingItems.add(Product(name: title));
      _shoppingList.add(Product(name: title));
    });
    _textFieldController.clear();
  }

  // Generate a single item widget
  Future<dynamic> _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add a task to your list'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: 'Enter task here'),
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
    for (Product product in _shoppingItems) {
      todoWidgets.add(ShoppingListItem(
        product: product,
        inCart: _shoppingList.contains(product),
        onCartChanged: _handleCartChanged,
        onRemoveItem: _handleItemRemoved,
      ));
    }
    return todoWidgets;

    // return widget.products.map((product) {
    //   return ShoppingListItem(
    //     product: product,
    //     inCart: _shoppingList.contains(product),
    //     onCartChanged: _handleCartChanged,
    //   );
    // }).toList();
  }
}
