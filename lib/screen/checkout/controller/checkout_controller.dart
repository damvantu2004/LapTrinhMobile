import 'package:flutter/material.dart';
import 'package:furniture_app/data/models/Order.dart';
import 'package:furniture_app/data/models/cart.dart';
// import 'package:furniture_app/data/models/payment.dart';
import 'package:furniture_app/data/models/product.dart';
import 'package:furniture_app/data/repository/cart_repository.dart';
import 'package:furniture_app/data/repository/order_repository.dart';
// import 'package:furniture_app/screen/congrats/view/congrats_page.dart';
import 'package:get/get.dart';
// import '../../../data/models/card.dart' as MyCard;

class CheckoutController extends GetxController {
  // Khai báo danh sách giỏ hàng và sản phẩm
  List<Cart> carts = [];
  List<Product> products = [];

  // Khai báo các biến lưu giá trị đơn hàng
  // MyCard.Card payment = MyCard.Card.template();
  double priceOrder = 0, priceDelivery = 0, priceTotal = 0, priceDiscount = 0;
  // MyDiscount? discount;
  bool paymentLoadButton = false; // Cờ kiểm tra trạng thái nút thanh toán

  @override
  void onInit() {
    super.onInit();
    // Lấy dữ liệu giỏ hàng và sản phẩm từ Get.arguments khi chuyển màn hình
    if (Get.arguments['carts'] != null) {
      carts = Get.arguments['carts'];
    }
    if (Get.arguments['products'] != null) {
      products = Get.arguments['products'];
    }

    // Tính toán tổng giá trị đơn hàng dựa trên giỏ hàng và sản phẩm
    for (int i = 0; i < carts.length; i++) {
      priceOrder = priceOrder + products[i].price! * carts[i].amount;
    }
  }


  // Phương thức tính giá vận chuyển cho khu vực đô thị
  double checkWeightUrban(double weight) {
    if (weight > 0 && weight <= 3) return 1.32; // Trọng lượng từ 0-3kg
    if (weight > 3 && weight <= 5) return 2; // Trọng lượng từ 3-5kg
    if (weight > 5 && weight <= 10) return 3.45; // Trọng lượng từ 5-10kg
    if (weight > 10 && weight <= 20) return 5.80; // Trọng lượng từ 10-20kg
    if (weight > 20 && weight <= 50) return 10; // Trọng lượng từ 20-50kg
    if (weight > 50 && weight <= 100) return 20; // Trọng lượng từ 50-100kg
    return (weight - 100) * 0.2 + 20; // Trọng lượng trên 100kg
  }

  // Phương thức tính giá vận chuyển cho khu vực ngoại thành
  double checkWeightSuburban(double weight) {
    if (weight > 0 && weight <= 3) return 2.09; // Trọng lượng từ 0-3kg
    if (weight > 3 && weight <= 5) return 2.51; // Trọng lượng từ 3-5kg
    if (weight > 5 && weight <= 10) return 4.73; // Trọng lượng từ 5-10kg
    if (weight > 10 && weight <= 20) return 8.99; // Trọng lượng từ 10-20kg
    if (weight > 20 && weight <= 50) return 15; // Trọng lượng từ 20-50kg
    if (weight > 50 && weight <= 100) return 30; // Trọng lượng từ 50-100kg
    return (weight - 100) * 0.5 + 30; // Trọng lượng trên 100kg
  }

  // Phương thức xử lý khi người dùng nhấn nút thanh toán
  Future<void> clickPaymentButton() async {
    if (paymentLoadButton == false) {
      paymentLoadButton = true; // Đánh dấu nút thanh toán đang tải
      update(); // Cập nhật lại UI

      // Tạo đối tượng đơn hàng với thông tin giỏ hàng, trạng thái, phương thức thanh toán
      MyOrder order = MyOrder(
        carts: carts,
        status: [
          StatusOrder(status: "Ordered", date: DateTime.now()),
          StatusOrder(status: "Preparing"),
          StatusOrder(status: "Delivery in progress"),
          StatusOrder(status: "Completed")
        ],
        paymentInCash: true, // Phương thức thanh toán tiền mặt
        // discountID: discount != null ? discount!.id : null,
        priceOrder: priceOrder, // Giá trị sản phẩm
        priceDelivery: priceDelivery, // Giá vận chuyển
        priceDiscount: priceDiscount, // Giảm giá
        priceTotal: priceTotal, // Tổng giá trị
      );

      // Gửi đơn hàng vào hệ thống
      await OrderRepository().addToOrder(order);
      // Xóa các sản phẩm đã đặt trong giỏ hàng
      await CartRepository().deleteCarts(carts);

      // Quay lại màn hình trước và thông báo làm mới giỏ hàng
      Get.back(result: "Reload list cart");
      // Get.to(const CongratsPage()); // Chuyển đến màn hình chúc mừng (bị chú thích)
    }
  }
}
