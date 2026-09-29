import 'package:flutter_test/flutter_test.dart';
import 'package:vecindario_app/features/stores/models/cart_model.dart';

void main() {
  test('mantiene variantes del mismo producto como líneas separadas', () {
    final cart = CartModel(storeId: 'store-1', storeName: 'Pijamas Luna');

    cart.addItem(
      CartItem(
        storeItemId: 'pijama-1',
        name: 'Pijama estrellas',
        price: 45000,
        variant: 'Talla S - Azul',
      ),
    );
    cart.addItem(
      CartItem(
        storeItemId: 'pijama-1',
        name: 'Pijama estrellas',
        price: 45000,
        variant: 'Talla M - Roja',
      ),
    );
    cart.addItem(
      CartItem(
        storeItemId: 'pijama-1',
        name: 'Pijama estrellas',
        price: 45000,
        variant: 'Talla M - Roja',
      ),
    );

    expect(cart.items, hasLength(2));
    expect(cart.itemCount, 3);
    expect(cart.getQuantity('pijama-1'), 3);
    expect(cart.items.last.quantity, 2);
    expect(cart.items.last.displayName, 'Pijama estrellas · Talla M - Roja');
  });
}
