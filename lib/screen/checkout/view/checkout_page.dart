import 'package:flutter/material.dart'; // Thư viện Flutter để xây dựng giao diện người dùng.
import 'package:furniture_app/data/values/colors.dart'; // Import tệp màu tùy chỉnh.
import 'package:furniture_app/data/values/fonts.dart'; // Import tệp font chữ tùy chỉnh.
import 'package:furniture_app/data/values/strings.dart'; // Import tệp chứa các chuỗi ký tự.
import 'package:furniture_app/screen/checkout/controller/checkout_controller.dart'; // Import controller cho trang checkout.
import 'package:get/get.dart'; // Thư viện GetX để quản lý trạng thái.
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Thư viện tạo hiệu ứng tải.

/// Màn hình checkout sử dụng GetX để quản lý trạng thái.
class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      // Sử dụng GetBuilder để cập nhật giao diện khi trạng thái của `CheckoutController` thay đổi.
      builder: (value) => Scaffold(
        backgroundColor: backgroundColor, // Màu nền.
        appBar: buildAppBar(), // Thanh AppBar được định nghĩa bên dưới.
        body: GestureDetector(
          behavior: HitTestBehavior.translucent, // Nhận sự kiện nhấn trên toàn bộ màn hình.
          onTap: () {
            FocusScope.of(context).unfocus(); // Ẩn bàn phím khi nhấn vào khu vực khác.
          },
          child: _buildBody(), // Nội dung chính của trang.
        ),
      ),
    );
  }

  /// Tạo AppBar với các tùy chỉnh về tiêu đề và nút quay lại.
  AppBar buildAppBar() => AppBar(
    centerTitle: true,
    elevation: 0, // Xóa hiệu ứng đổ bóng.
    title: Text(
      titleCheckout, // Tiêu đề từ file chuỗi ký tự.
      style: TextStyle(
        color: textHeaderColor, // Màu tiêu đề.
        fontFamily: 'JosefinSans', // Font chữ.
        fontSize: Get.width * 0.05, // Kích thước chữ tùy theo chiều rộng màn hình.
        fontWeight: FontWeight.w700, // Độ đậm của chữ.
      ),
    ),
    leading: InkWell(
      onTap: () => Get.back(), // Hành động quay lại trang trước đó.
      child: Padding(
        padding: EdgeInsets.only(left: Get.width * 0.05),
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.black, // Màu của icon.
          size: Get.width * 0.05, // Kích thước của icon.
        ),
      ),
    ),
    backgroundColor: backgroundColor, // Màu nền của AppBar.
  );

  /// Xây dựng phần nội dung chính của trang.
  Widget _buildBody() => SingleChildScrollView(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListProduct(), // Danh sách sản phẩm.



          SizedBox(height: Get.height * 0.04), // Khoảng cách giữa các thành phần.
          _buttonConfirm(), // Nút xác nhận thanh toán.
        ],
      ),
    ),
  );

  /// Hiển thị danh sách sản phẩm trong giỏ hàng.
  Widget _buildListProduct() {
    if (controller.carts.isEmpty) { // Kiểm tra giỏ hàng có trống không.
      return Center(
        child: Text(
          "Your cart is empty", // Thông báo giỏ hàng trống.
          style: TextStyle(
            fontSize: 16,
            color: Colors.black.withOpacity(0.8),
            fontFamily: nunito_sans, // Font chữ tùy chỉnh.
          ),
        ),
      );
    }

    List<Widget> c = []; // Danh sách các widget sản phẩm.
    for (int i = 0; i < controller.carts.length; i++) {
      c.addAll([buildItemProduct(i), const Divider()]); // Thêm sản phẩm và đường phân cách.
    }
    return Column(children: c);
  }

  /// Xây dựng giao diện chi tiết từng sản phẩm.
  Widget buildItemProduct(int index) {
    return SizedBox(
      width: Get.width, // Chiều rộng là toàn màn hình.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // Bo góc hình ảnh.
              // image: DecorationImage(
              //   image: NetworkImage(controller.products[index].imagePath?[0] ?? ""),
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          Container(
            width: Get.width - 170, // Phần còn lại dành cho thông tin sản phẩm.
            padding: const EdgeInsets.only(left: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.products[index].name.toString(), // Tên sản phẩm.
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Cắt chữ nếu quá dài.
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.8),
                    fontFamily: nunito_sans,
                  ),
                ),
                Text(
                  '\$ ${controller.products[index].price}', // Giá sản phẩm.
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Get.width * 0.05,
                    fontFamily: nunito_sans,
                  ),
                ),
                // Các thông tin khác như số lượng, kích thước...
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nội dung nút xác nhận thanh toán.
  Center _buttonConfirm() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: buttonColor, // Màu của nút.
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey, // Màu bóng đổ.
              blurRadius: 6,
              offset: Offset(1, 3), // Vị trí bóng đổ.
            ),
          ],
        ),
        child: Center(
          child: InkWell(
            onTap: () {
              controller.clickPaymentButton(); // Hành động khi nhấn nút.
            },
            child: Container(
              width: Get.width * 0.5,
              height: Get.height * 0.05,
              padding: EdgeInsets.all(Get.height * 0.015),
              child: controller.paymentLoadButton
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "LOADING", // Hiển thị trạng thái tải.
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'JosefinSans',
                    ),
                  ),
                  LoadingAnimationWidget.waveDots(
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              )
                  : const Text(
                "PAYMENT", // Hiển thị chữ "PAYMENT" khi không tải.
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
