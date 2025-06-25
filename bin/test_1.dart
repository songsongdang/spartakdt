import 'dart:io';
import 'package:collection/collection.dart';

class Product {
  String name;
  int price;

  Product(this.name, this.price);
}

class ShoppingMall {
  List<Product> products;
  Map<Product, int> cart = {};
  int totalPrice = 0;

  ShoppingMall(this.products);

  void showProducts() {
    for (var product in products) {
      print('${product.name} / ${product.price}원');
    }
  }

  void addToCart() {
    stdout.write('상품 이름을 입력해 주세요!\n');
    String? nameInput = stdin.readLineSync();

    if (nameInput == null || nameInput.trim().isEmpty) {
      print('입력값이 올바르지 않아요!');
      return;
    }

    Product? selectedProduct = products.firstWhereOrNull(
      (p) => p.name == nameInput.trim(),
    );

    if (selectedProduct == null) {
      print('입력값이 올바르지 않아요!');
      return;
    }

    stdout.write('상품 개수를 입력해 주세요!\n');
    String? countInput = stdin.readLineSync();
    int count;

    try {
      count = int.parse(countInput ?? '');
    } catch (e) {
      print('입력값이 올바르지 않아요!');
      return;
    }

    if (count <= 0) {
      print('$count개보다 많은 개수의 상품만 담을 수 있어요!');
      return;
    }

    cart[selectedProduct] = (cart[selectedProduct] ?? 0) + count;
    totalPrice += selectedProduct.price * count;
    print('장바구니에 상품이 담겼어요!');
  }

  void showCartSummary() {
    if (cart.isEmpty || totalPrice == 0) {
      print('장바구니에 담긴 상품이 없습니다.');
      return;
    }
    // 장바구니에 담긴 상품 이름을 리스트로 저장
    List<String> productNames = cart.keys
        .map((product) => product.name)
        .toList();
    String names = productNames.join(', ');
    print('장바구니에 $names가 담겨있네요. 총 $totalPrice원 입니다!');
  }

  void clearCart() {
    if (cart.isEmpty || totalPrice == 0) {
      print('이미 장바구니가 비어있습니다.');
    } else {
      cart.clear();
      totalPrice = 0;
      print('장바구니를 초기화합니다.');
    }
  }
}

void main() {
  List<Product> productList = [
    Product('pants', 45000),
    Product('skirt', 30000),
    Product('shose', 35000),
    Product('shorts', 38000),
    Product('socks', 5000),
  ];

  ShoppingMall mall = ShoppingMall(productList);

  bool running = true;
  bool awaitingExitConfirmation = false;

  while (running) {
    if (!awaitingExitConfirmation) {
      print(
        '\n[1] 상품 목록 보기 / [2] 장바구니에 담기 / [3] 장바구니에 담긴 상품의 총 가격 보기 / [4] 프로그램 종료 / [6] 장바구니 초기화',
      );
      stdout.write('> ');
      String? input = stdin.readLineSync();

      switch (input) {
        case '1':
          mall.showProducts();
          break;
        case '2':
          mall.addToCart();
          break;
        case '3':
          mall.showCartSummary();
          break;
        case '4':
          print('정말 종료하시겠습니까?');
          print('[5] 종료 / [그 외] 종료하지 않습니다.');
          awaitingExitConfirmation = true;
          break;
        case '6':
          mall.clearCart();
          break;
        default:
          print('지원하지 않는 기능입니다! 다시 시도해 주세요');
      }
    } else {
      stdout.write('> ');
      String? confirmInput = stdin.readLineSync();
      if (confirmInput == '5') {
        print('이용해 주셔서 감사합니다 ~ 안녕히 가세요!');
        running = false;
      } else {
        print('종료하지 않습니다.');
        awaitingExitConfirmation = false;
      }
    }
  }
}
