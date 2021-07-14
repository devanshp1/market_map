import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:market_map/backend/database.dart';
import 'package:market_map/backend/razorpay.dart';
import 'Products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_map/backend/sharable.dart';

class Cart extends StatefulWidget {
  final String cid;
  final String orderid;

  Cart({
    this.cid,
    this.orderid,
  });

  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> {
  Dbservice db;
  @override
  void initState() {
    super.initState();

    db = Dbservice(uid: widget.cid);
  }

  bool isLoading = false;
  List<int> qty = [];
  List<int> rate = [];
  List<int> totalamt = [];
  List<String> prodname = [];
  List<String> category = [];
  List<String> packing = [];
  String remark = '';
  String sellerid = '';
  @override
  Widget build(BuildContext context) {
    bool cartnotempty = aa.isNotEmpty;
    grand = 0;
    print(aa);
    if (cartnotempty) {
      for (var prod in aa) {
        grand += prod.totalamt;
        if (sellerid == '') {
          sellerid = prod.sellerid;
        }
      }
    }
    return SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              elevation: 10,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Cart  '),
                  Hero(
                      tag: 'mytag',
                      child: Icon(
                        Icons.shopping_cart_sharp,
                        size: 20.0,
                        color: Colors.black87,
                      )),
                  Spacer(),
                ],
              ),
              actions: [
                Visibility(
                  visible: cartnotempty,
                  child: IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        size: 40.0,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          prodincart = [];
                          aa = [];
                          print(aa.toString());
                          //context.findAncestorStateOfType<CartState>().dispose();
                          print('aa.toString()');
                        });
                      }),
                ),
              ],
            ),
            body: Stack(fit: StackFit.expand, children: [
              Padding(
                  padding: EdgeInsets.all(7.0),
                  child: aa.isNotEmpty
                      ? ListView(
                          shrinkWrap: true,
                          children: [
                            /* Text(
                              'OrderID : ${widget.orderid}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),*/
                            SizedBox(height: 10),
                            AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                child: ListView(
                                  //mainAxisSize: MainAxisSize.min,
                                  shrinkWrap: true,
                                  children: aa,
                                  addAutomaticKeepAlives: true,
                                ),
                              ),
                            ),
                            AspectRatio(
                              aspectRatio: 2,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: TextFormField(
                                        autofocus: false,
                                        onChanged: (val) {
                                          remark = val.trim();
                                        },
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          labelText: 'Add Remarks',
                                          border: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                            color: Colors.black,
                                          )),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    /* Center(
                                      child: Text(
                                        'Order Total : Rs $grand',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),*/
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 70)
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 140,
                              ),
                              SizedBox(height: 10),
                              Text(
                                '   Empty Cart\n Go buy something',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        )),
              Positioned(
                left: 0,
                bottom: 0,
                child: Visibility(
                  visible: cartnotempty,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    fit: StackFit.passthrough,
                    children: [
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.width/4.5,
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                          maxHeight: MediaQuery.of(context).size.width,
                        ),
                        child: ElevatedButton(
                          style: elevatedbutton,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            for (var prod in aa) {
                              prodname.add(prod.name);
                              category.add(prod.category);
                              packing.add(prod.packing);
                              totalamt.add(prod.totalamt);
                              rate.add(prod.rate);
                              qty.add(prod.quantity);
                            }
                            String _buyerName,
                                _buyeremail,
                                _buyerPhno,
                                _address;
                            final CollectionReference reference =
                                FirebaseFirestore.instance
                                    .collection('Users/AppUsers/Buyers');
                            var document = reference.doc(uid).get();
                            await document.then((doc) {
                              _buyerName = doc.data()['Name'];
                              _buyerPhno = doc.data()['other phone no'];
                              _buyeremail = doc.data()['email'];
                              _address = doc.data()["Address"];
                            });

                            setState(() {
                              isLoading = false;
                            });
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => Checkout(
                                          buyeremail: _buyeremail,
                                          buyerName: _buyerName,
                                          buyerPhno: _buyerPhno,
                                          qty: qty,
                                          packing: packing,
                                          address: _address,
                                          category: category,
                                          totalamt: totalamt,
                                          rate: rate,
                                          grand: grand,
                                          sellerid: sellerid,
                                          uid: widget.cid,
                                          orderid: widget.orderid,
                                          prodname: prodname,
                                          remark: remark,
                                        )));
                            /* 
                            print(prodincart.toString());
                            await db.getname();
                            print(buyerName);
                            print(sellerid);

                            await db.placeorder(
                                context: context,
                                status: 'pending',
                                idprod: prodincart,
                                idcust: db.uid,
                                quantity: qty,
                                totalamt: totalamt,
                                remark: remark ?? 'no remarks' ,
                                rate: rate,
                                packing: packing,
                                custName: buyerName,
                                prodname: prodname,
                                category: category,
                                ordertotal: grand,
                                sellerid: sellerid,
                                orderid: widget.orderid);

                            if (!error) {
                              
                              setState(() {
                                aa = [];
                                prodincart = [];
                                isLoading=false;
                              });
                              _key.currentState.showSnackBar(SnackBar(
                                content: Text('Order placed'),
                                duration: Duration(seconds: 2),
                              ));
                              NotificationSend not = NotificationSend();
                              await not.sendNotification(
                                  sellerid: sellerid,
                                  body:
                                      'Order placed by $buyerName,of Total Amount - $grand',
                                  title: 'Got a new Order');
                            }*/
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Place Order',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    'Rs $grand',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 1),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Visibility(
                  visible: isLoading,
                  child: Positioned(
                    right: 0,
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 10,
                      )),
                    ),
                  ))
            ])));
  }
}

// ignore: must_be_immutable
class Cartprod extends StatefulWidget {
  final String idprod;
  int totalamt;
  int quantity;
  final int rate;
  final String packing;
  final String category;
  final String name;
  final String sellerid;

  Cartprod(
      {this.sellerid,
      this.category,
      this.idprod,
      this.name,
      this.packing,
      this.quantity,
      this.rate,
      this.totalamt});
  @override
  _CartprodState createState() => _CartprodState();

  CartState findstate(BuildContext context) {
    context.findAncestorStateOfType();
    print(context.findAncestorStateOfType().toString());

    return context.findAncestorStateOfType<CartState>();
  }
}

class _CartprodState extends State<Cartprod> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /*Text(
              'Product ID : ${widget.idprod}',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),*/
            Text('${widget.name}'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Quantity : '),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (widget.quantity > 1) {
                          for (var item in aa) {
                            if (item.idprod == widget.idprod) {
                              item.quantity -= 1;
                              item.totalamt = widget.rate * widget.quantity;
                              grand += item.rate;
                            }
                          }
                        }
                      });
                      widget.findstate(context).setState(() {});
                    }),
                Text('${widget.quantity}'),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        for (var item in aa) {
                          if (item.idprod == widget.idprod) {
                            item.quantity += 1;
                            item.totalamt = widget.rate * widget.quantity;
                            grand += item.rate;
                          }
                        }
                      });
                      widget.findstate(context).setState(() {});
                    }),
              ],
            ),
            Text('MRP : ${widget.rate}'),
            Text('Packing : ${widget.packing}'),
            Text('Category : ${widget.category}'),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Item Total :${widget.totalamt}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                /* IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      size: 40.0,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        prodincart
                            .removeWhere((element) => element == widget.idprod);

                        aa.removeWhere((item) => item.idprod == widget.idprod);
                        print(aa.toString());
                        //context.findAncestorStateOfType<CartState>().dispose();
                        print('aa.toString()');
                      });

                      
                    }),*/
              ],
            ),
            SizedBox(height: 10),
            Divider(
              color: Colors.black,
              thickness: 3,
            )
          ],
        ),
      ),
    );
  }
}
