import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/model/cartmodel.dart';
import 'package:e_commerce/model/product.dart';
import 'package:e_commerce/provider/product_provider.dart';
import 'package:e_commerce/screens/homepage.dart';
import 'package:e_commerce/widgets/cartsingleproduct.dart';
import 'package:e_commerce/widgets/mybutton.dart';
import 'package:e_commerce/widgets/notification_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckOut extends StatefulWidget {
  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  TextStyle myStyle = TextStyle(
    fontSize: 18,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProductProvider productProvider;

  Widget _buildBottomSingleDetail({String startName, String endName}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          startName,
          style: myStyle,
        ),
        Text(
          endName,
          style: myStyle,
        ),
      ],
    );
  }

  User user;
  double total;
  List<CartModel> myList;
  int index;
  Widget _buildButton() {
    return Column(
        children: productProvider.userModelList.map((e) {
      return Container(
        height: 50,
        child: MyButton(
          name: "Buy",
          onPressed: () {
            if (productProvider.getCheckOutModelList.isNotEmpty) {
              FirebaseFirestore.instance.collection("Order").add({
                "Product": productProvider.getCheckOutModelList
                    .map((c) => {
                          "ProductName": c.name,
                          "ProductPrice": c.price,
                          "ProductQuetity": c.quentity,
                          "ProductImage": c.image,
                          "Product Color": c.color,
                          "Product Size": c.size,
                        })
                    .toList(),
                "TotalPrice": total.toStringAsFixed(2),
                "UserName": e.userName,
                "UserEmail": e.userEmail,
                "UserNumber": e.userPhoneNumber,
                "UserAddress": e.userAddress,
                "UserId": user.uid,
              });
              setState(() {
                myList.clear();
                productProvider.cartModelList.clear();
              });

              productProvider.addNotification("Notification");
            } else {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("No Item Yet"),
                ),
              );
            }
          },
        ),
      );
    }).toList());
  }

  @override
  void initState() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    myList = productProvider.checkOutModelList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = FirebaseAuth.instance.currentUser;
    double subTotal = 0;
    double discount = 3;
    double discountRupees;
    double shipping = 60;

    productProvider = Provider.of<ProductProvider>(context);
    productProvider.getCheckOutModelList.forEach((element) {
      subTotal += element.price * element.quentity;
    });

    discountRupees = discount / 100 * subTotal;
    total = subTotal + shipping - discountRupees;
    if (productProvider.checkOutModelList.isEmpty) {
      total = 0.0;
      discount = 0.0;
      shipping = 0.0;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("CheckOut Page", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx) => HomePage(),
              ),
            );
          },
        ),
        actions: <Widget>[
          NotificationButton(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        width: 100,
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.only(bottom: 15),
        child: _buildButton(),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 480,
              child: ListView.builder(
                itemCount: myList.length,
                itemBuilder: (ctx, myIndex) {
                  index = myIndex;
                  return CartSingleProduct(
                    isCount: true,
                    index: myIndex,
                    color: myList[myIndex].color,
                    size: myList[myIndex].size,
                    image: myList[myIndex].image,
                    name: myList[myIndex].name,
                    price: myList[myIndex].price,
                    quentity: myList[myIndex].quentity,
                  );
                },
              ),
            ),
            Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildBottomSingleDetail(
                    startName: "Subtotal",
                    endName: "\$ ${subTotal.toStringAsFixed(2)}",
                  ),
                  _buildBottomSingleDetail(
                    startName: "Discount",
                    endName: "${discount.toStringAsFixed(2)}%",
                  ),
                  _buildBottomSingleDetail(
                    startName: "Shipping",
                    endName: "\$ ${shipping.toStringAsFixed(2)}",
                  ),
                  _buildBottomSingleDetail(
                    startName: "Total",
                    endName: "\$ ${total.toStringAsFixed(2)}",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
