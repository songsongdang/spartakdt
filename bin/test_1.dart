import 'dart:io';
import 'package:collection/collection.dart';

class Product {
  String name;
  int price;

  Product(this.name, this.price);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => name.hashCode ^ price.hashCode;
}

class ShoppingMall {
  List<Product> products;
  Map<Product, int> cart = {};
  int totalPrice = 0;

  /// 여러 번 삭제한 상품들을 누적 저장
  Map<Product, int> lastRemovedItems = {};

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

  void removeFromCart() {
    if (cart.isEmpty) {
      print('장바구니에 담긴 상품이 없습니다.');
      return;
    }
    stdout.write('장바구니에서 빼려는 상품 이름을 입력해 주세요\n');
    String? nameInput = stdin.readLineSync();

    if (nameInput == null || nameInput.trim().isEmpty) {
      print('입력값이 올바르지 않아요!');
      return;
    }

    Product? selectedProduct = cart.keys.firstWhereOrNull(
      (p) => p.name == nameInput.trim(),
    );

    if (selectedProduct == null) {
      print('장바구니에 해당 상품이 없습니다.');
      return;
    }

    stdout.write('상품 개수를 입력해 주세요\n');
    String? countInput = stdin.readLineSync();
    int count;

    try {
      count = int.parse(countInput ?? '');
    } catch (e) {
      print('입력값이 올바르지 않아요!');
      return;
    }

    int currentCount = cart[selectedProduct]!;
    if (count <= 0) {
      print('$count개보다 많은 개수의 상품만 뺄 수 있어요!');
      return;
    }
    if (count > currentCount) {
      print('장바구니에 담긴 개수보다 많이 뺄 수 없습니다.');
      return;
    }

    // 누적 삭제 정보 저장
    lastRemovedItems[selectedProduct] =
        (lastRemovedItems[selectedProduct] ?? 0) + count;

    // 상품 개수 차감
    cart[selectedProduct] = currentCount - count;
    totalPrice -= selectedProduct.price * count;
    if (cart[selectedProduct] == 0) {
      cart.remove(selectedProduct);
    }
    print('장바구니에서 상품을 $count개 뺐어요!');
  }

  void restoreLastRemovedItems() {
    if (lastRemovedItems.isNotEmpty) {
      lastRemovedItems.forEach((product, count) {
        cart[product] = (cart[product] ?? 0) + count;
        totalPrice += product.price * count;
      });
      print('삭제한 모든 상품을 장바구니에 복구했습니다!');
      lastRemovedItems.clear();
    } else {
      print('복구할 상품이 없습니다.');
    }
  }

  void showCartSummary() {
    if (cart.isEmpty || totalPrice == 0) {
      print('장바구니에 담긴 상품이 없습니다.');
      return;
    }
    int total = 0;
    print('[장바구니 내역]');
    cart.forEach((product, count) {
      int itemTotal = product.price * count;
      total += itemTotal;
      print('${product.name} - $count개, $itemTotal원');
    });
    print('상품 총 합: $total원');
  }

  void clearCart({bool askRestore = false}) {
    if (cart.isEmpty || totalPrice == 0) {
      print('이미 장바구니가 비어있습니다.');
      lastRemovedItems.clear();
    } else {
      if (askRestore && lastRemovedItems.isNotEmpty) {
        print('장바구니에서 삭제한 아이템을 다시 장바구니에 넣으시겠어요?');
        print('1. yes   2. no');
        stdout.write('> ');
        String? input = stdin.readLineSync();
        if (input == '1') {
          restoreLastRemovedItems();
          return;
        } else if (input == '2') {
          cart.clear();
          totalPrice = 0;
          lastRemovedItems.clear();
          print('장바구니를 초기화합니다.');
        } else {
          print('잘못된 입력입니다. 장바구니를 초기화하지 않습니다.');
        }
      } else {
        cart.clear();
        totalPrice = 0;
        lastRemovedItems.clear();
        print('장바구니를 초기화합니다.');
      }
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
  bool lastActionWasRemove = false; // 6번 이후 7번 눌렀는지 추적

  while (running) {
    if (!awaitingExitConfirmation) {
      print(
        '\n[1] 상품 목록 보기 / [2] 장바구니에 담기 / [3] 장바구니에 담긴 상품의 총 가격 보기 / [4] 프로그램 종료 / [6] 장바구니에서 상품 빼기 / [7] 장바구니 복구/초기화',
      );
      stdout.write('> ');
      String? input = stdin.readLineSync();

      switch (input) {
        case '1':
          mall.showProducts();
          lastActionWasRemove = false;
          break;
        case '2':
          mall.addToCart();
          lastActionWasRemove = false;
          break;
        case '3':
          mall.showCartSummary();
          lastActionWasRemove = false;
          break;
        case '4':
          print('정말 종료하시겠습니까?');
          print('[5] 종료 / [그 외] 종료하지 않습니다.');
          awaitingExitConfirmation = true;
          break;
        case '6':
          mall.removeFromCart();
          lastActionWasRemove = true;
          break;
        case '7':
          mall.clearCart(askRestore: lastActionWasRemove);
          lastActionWasRemove = false;
          break;
        default:
          print('지원하지 않는 기능입니다! 다시 시도해 주세요');
          lastActionWasRemove = false;
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
