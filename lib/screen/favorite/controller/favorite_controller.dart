import 'package:flutter/material.dart';
import 'package:furniture_app/data/models/product.dart';
import 'package:furniture_app/data/repository/product_repository.dart';
import 'package:furniture_app/data/values/strings.dart';
import 'package:get/get.dart';

import '../../../data/models/cart.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repository/cart_repository.dart';
import '../../../data/repository/user_repository.dart';

class FavoriteController extends GetxController {
  // Danh sách sản phẩm yêu thích
  List<Product> products = [];
  // Danh sách giỏ hàng của người dùng
  List<Cart> carts = [];

  // Thông tin người dùng hiện tại
  late UserProfile currenUser;

  @override
  void onInit() {
    super.onInit();
    // Gọi phương thức loadFavorite() khi controller được khởi tạo
    loadFavorite();
  }

  // Phương thức tải dữ liệu yêu thích
  Future<void> loadFavorite() async {
    // Lấy danh sách giỏ hàng từ repository
    carts = await CartRepository().getAllMyCarts();

    // Lấy thông tin người dùng hiện tại
    currenUser = await UserRepository().getUserProfile();

    // Lấy danh sách sản phẩm yêu thích dựa trên danh sách `favorites` của người dùng
    for (int i = 0; i < (currenUser.favories ?? []).length; i++) {
      products
          .add(await ProductRepository().getProduct(currenUser.favories![i]));
      // Cập nhật giao diện sau khi thêm sản phẩm
      update();
    }
  }

  // Phương thức xóa sản phẩm yêu thích theo chỉ số
  void deleteItemWithIndex(int index) {
    // Cập nhật lại danh sách yêu thích trong repository (xóa sản phẩm này)
    UserRepository().updateFavorite(products[index].id.toString(), false);

    // Xóa sản phẩm khỏi danh sách hiển thị
    products.removeAt(index);

    // Cập nhật lại giao diện
    update();
  }

  // Phương thức thêm sản phẩm yêu thích (chưa được sử dụng)
  void addItemWithIndex(int index) {
    // Để trống, có thể được bổ sung sau nếu cần logic để thêm sản phẩm vào danh sách yêu thích
    // products.removeAt(index);
    // update();
  }
}
