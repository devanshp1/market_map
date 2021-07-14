import 'package:market_map/screens/Products.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:market_map/backend/notification.dart';
import 'package:market_map/backend/database.dart';

class Checkout extends StatefulWidget {
  final List<int> qty;
  final List<int> rate;
  final List<int> totalamt;
  final List<String> prodname;
  final List<String> category;
  final List<String> packing;
  final String remark;
  final String sellerid;
  final String orderid;
  final int grand;
  final String uid, buyerName, buyeremail, buyerPhno, address;
  Checkout(
      {this.uid,
      this.buyeremail,
      this.buyerName,
      this.address,
      this.buyerPhno,
      this.grand,
      this.orderid,
      this.prodname,
      this.category,
      this.packing,
      this.qty,
      this.rate,
      this.remark,
      this.sellerid,
      this.totalamt});
  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  Razorpay razorpay;
  Dbservice db;
  String _newaddress;
  TextEditingController add = TextEditingController();
  @override
  void initState() async {
    super.initState();
    db = Dbservice(uid: widget.uid);

    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() {
    var options = {
      "key": "<Your API key",
      "amount": widget.grand * 100,
      "name": widget.buyerName,
      "description": "Payment for OrderId ${widget.orderid}",
      "prefill": {"contact": widget.buyerPhno, "email": widget.buyeremail},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      Toast.show(e.toString(), context, duration: 3);
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(PaymentSuccessResponse res) async {
  
    Toast.show("Order Placed   " + res.paymentId.toString(), context,
        duration: 3);
    await db.placeorder(
        context: context,
        status: 'pending',
        idprod: prodincart,
        idcust: db.uid,
        quantity: widget.qty,
        totalamt: widget.totalamt,
        remark: widget.remark ?? 'no remarks',
        rate: widget.rate,
        packing: widget.packing,
        custName: widget.buyerName,
        prodname: widget.prodname,
        category: widget.category,
        ordertotal: widget.grand,
        //sellerid: sellerid,
        orderid: widget.orderid,
        add: address == true ? _newaddress : widget.address);
    aa = [];
    prodincart = [];

    Navigator.of(context).pop();

    NotificationSend not = NotificationSend();
    await not.sendNotification(
        sellerid: widget.sellerid,
        body: 'Order placed by $buyerName,of Total Amount - $grand',
        title: 'Got a new Order');
  }

  void handlerErrorFailure(PaymentFailureResponse res) {
    print("Pament error");
    Toast.show("Payment error " + res.message.toString(), context, duration: 3);
  }

  void handlerExternalWallet(ExternalWalletResponse res) {
    print("External Wallet");
    Toast.show("External Wallet" + res.walletName, context, duration: 3);
  }

  void _onChange(int val) {
    setState(() {
      gv = val;
      if (val == 0) {
        address = false;
      }
      if (val == 1) {
        address = true;
      }
    });
  }

  int gv = 0;
  bool address = false;
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text("Choose Delivery address"),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(value: 0, groupValue: gv, onChanged: _onChange),
                TextFormField(
               
                  enabled: false,
                  maxLines: 4,
                  initialValue: widget.address,
                ),
              ],
            ),
            Text("another address"),
            Row(
              children: [
                Radio(value: 1, groupValue: gv, onChanged: _onChange),
                Form(
                  key: _key,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    validator: (val) =>
                        val.length < 15 ? "please add complete address" : "",
                    onChanged: (val) {
                      _newaddress = val.trim();
                    },
                    controller: add,
                    enabled: address,
                    maxLines: 4,
                    initialValue: '',
                  ),
                ),
              ],
            ),
            Text("Amount to be paid : ${widget.grand}"),
            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              child: Text(
                "Proceed to payment ",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (address) {
                  if (_key.currentState.validate()) {
                    openCheckout();
                  }
                } else {
                  openCheckout();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
