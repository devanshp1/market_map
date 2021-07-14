import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market_map/backend/database.dart';
import 'package:market_map/backend/notification.dart';
import 'package:market_map/screens/Products.dart';
import 'package:intl/intl.dart';

class Orders extends StatefulWidget {
  final String uid;
  Orders({this.uid});
  @override
  _OrdersState createState() => _OrdersState();
}

final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    uid = widget.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: PreferredSize(
          preferredSize:
              Size(double.infinity, MediaQuery.of(context).size.height / 5),
          child: AppBar(
              title: Text('My Orders'),
              bottom: TabBar(
                controller: _controller,
                unselectedLabelColor: Colors.white,
                labelColor: Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.black,
                indicatorWeight: 2.0,
                tabs: <Widget>[
                  Tab(
                    child: Text(' Current Orders '),
                  ),
                  Tab(
                    child: Text(' Order History '),
                  ),
                ],
              )),
        ),
        body: TabBarView(
          children: [
            OrderPage(
              current: true,
              uid: uid,
            ),
            OrderPage(
              current: false,
              uid: uid,
            )
          ],
          controller: _controller,
        ),
      ),
    );
  }
}

class OrderPage extends StatefulWidget {
  final bool current;
  final String uid;

  OrderPage({this.current, this.uid});
  @override
  _OrderPageState createState() => _OrderPageState();
}

Dbservice db;

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    print(uid);
    db = Dbservice(uid: widget.uid);
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            print('no daata');
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.teal[900],
            ));
          } else {
            final recps = snapshot.data.docs;
            List<OrdView> orderlist = [];
            for (var recp in recps) {
              @required
              final ordertotal = recp.data()['orderTotal'];
              @required
              final pid = recp.data()['productID'];
              @required
              final pname = recp.data()['productName'];
              @required
              final rate = recp.data()['mrp'];
              @required
              final cid = recp.data()['customerID'];
              @required
              final remark = recp.data()["remark"];
              @required
              final total = recp.data()['totalAmount'];
              @required
              final qty = recp.data()['quantity'];
              @required
              final dt = recp.data()['orderDate'];
              @required
              final bname = recp.data()['buyerName'];
              @required
              final packing = recp.data()['netWeight'];
              @required
              final category = recp.data()['category'];
              @required
              final String orderid = recp.data()['orderID'];
              @required
              final String sellerid = recp.data()['sellerID'];
              @required
              final String status = recp.data()['status'];
              String check = status.trim().toLowerCase();
              print(remark);
              if (cid == widget.uid) {
                if (widget.current) {
                  if (check == 'pending' ||
                      check == 'accepted' ||
                      check == 'dispatched') {
                    List<Proddetails> prods = [];
                    if (pid is String) {
                      Proddetails detail = Proddetails(
                        category: category,
                        packing: packing,
                        mrp: rate,
                        totalamt: total,
                        quantity: qty,
                        name: pname,
                        idprod: pid,
                      );
                      prods.add(detail);
                    }
                    if (pid is List) {
                      for (int i = 0; i < pid.length; i++) {
                        Proddetails detail = Proddetails(
                          idprod: pid[i],
                          category: category[i],
                          packing: packing[i],
                          mrp: rate[i],
                          totalamt: total[i],
                          quantity: qty[i],
                          name: pname[i],
                        );
                        prods.add(detail);
                      }
                    }
                    OrdView order = OrdView(
                      idcust: cid,
                      status: status,
                      dtorder: dt,
                      remark: remark,
                      bname: bname,
                      orderid: orderid,
                      prods: prods,
                      ordertotal: ordertotal,
                      sellerid: sellerid,
                    );
                    orderlist.add(order);
                  }
                } else {
                  if (check == 'delivered' || check == 'cancelled') {
                    List<Proddetails> prods = [];
                    if (pid is String) {
                      Proddetails detail = Proddetails(
                        idprod: pid,
                        category: category,
                        packing: packing,
                        mrp: rate,
                        totalamt: total,
                        quantity: qty,
                        name: pname,
                      );
                      prods.add(detail);
                    }
                    if (pid is List) {
                      for (int i = 0; i < pid.length; i++) {
                        Proddetails detail = Proddetails(
                          idprod: pid[i],
                          category: category[i],
                          packing: packing[i],
                          mrp: rate[i],
                          totalamt: total[i],
                          quantity: qty[i],
                          name: pname[i],
                        );
                        prods.add(detail);
                      }
                    }
                    OrdView order = OrdView(
                      idcust: cid,
                      status: status,
                      dtorder: dt,
                      remark: remark,
                      bname: bname,
                      orderid: orderid,
                      prods: prods,
                      ordertotal: ordertotal,
                      sellerid: sellerid,
                    );
                    orderlist.add(order);
                  }
                }
              }
            }
            if (orderlist.isNotEmpty) {
              return ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: orderlist,
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Icon(
                      Icons.not_interested,
                      size: 80,
                    ),
                    Text('No Orders'),
                  ],
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class OrdView extends StatelessWidget {
  final String orderid;
  final String idcust;
  final String status;
  final String remark;
  final dtorder;
  final String bname;
  final int ordertotal;
  final List<Proddetails> prods;
  final String sellerid;
  OrdView(
      {this.prods,
      this.sellerid,
      this.ordertotal,
      this.idcust,
      this.remark,
      this.status,
      this.dtorder,
      this.bname,
      this.orderid});
  @override
  Widget build(BuildContext context) {
    bool dispatched = false;
    if (status.toLowerCase() == 'dispatched') {
      dispatched = true;
    }
    if (status.toLowerCase() == 'pending') {
      dispatched = false;
    }
    return ListTile(
      subtitle: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Buyer Name : $bname',
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 4),
              /* Text(
                'OrderID : $orderid',
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),*/
              Text('Order Date : $dtorder'),
              SizedBox(height: 4),
              Text("Total amount : $ordertotal"),
              SizedBox(height: 4),
              Text(
                'Status : $status',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dispatched ? Colors.teal : Colors.blueGrey),
              ),
              Visibility(
                  visible: dispatched,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    title: Text('Confirm Delivery'),
                                    content:
                                        Text('The order has been delivered'),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel')),
                                      ElevatedButton(
                                          onPressed: () async {
                                            bool err = false;
                                            var dt = DateFormat.yMMMd()
                                                .format(DateTime.now());

                                            final CollectionReference order1 =
                                                FirebaseFirestore.instance
                                                    .collection('Orders');
                                            await order1.doc(orderid).update({
                                              'status': 'delivered',
                                              'deliverydate': dt
                                            });
                                            if (!err) {
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Order delivery confirmed'),
                                              ));
                                            }
                                            if (!err) {
                                              NotificationSend not =
                                                  NotificationSend();
                                              await not.sendNotification(
                                                  sellerid: sellerid,
                                                  body:
                                                      'Delivery confirmed of OrderID $orderid on $dt',
                                                  title: 'Order Delivered');
                                            }
                                          },
                                          child: Text('Confirm')),
                                    ],
                                  );
                                });
                          },
                          child: Text(
                            'Confirm Delivery',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal),
                          )))),
              Visibility(
                  visible: false,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    title: Text('Cancel Order'),
                                    content: Text('This will cancel the order'),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('  No  ')),
                                      ElevatedButton(
                                          onPressed: () async {
                                            bool err = false;
                                            var dt = DateFormat.yMMMd()
                                                .format(DateTime.now());
                                            final CollectionReference order1 =
                                                FirebaseFirestore.instance
                                                    .collection('Orders');

                                            await order1
                                                .doc(orderid)
                                                .delete()
                                                .catchError((e) {
                                              err = true;
                                            });

                                            if (!err) {
                                              NotificationSend not =
                                                  NotificationSend();
                                              await not.sendNotification(
                                                  sellerid: sellerid,
                                                  body:
                                                      'Order Cancelled by $idcust on $dt',
                                                  title: 'Lost an Order');
                                            }
                                          },
                                          child: Text('  Yes  ')),
                                    ],
                                  );
                                });
                          },
                          child: Text(
                            'Cancel order',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent),
                          )))),
              ExpansionTile(
                trailing: Icon(Icons.arrow_drop_down),
                title: Text('Order Details'),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: prods,
                          ),
                        )),
                        Container(
                            child: Text(
                          'Remarks : $remark',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                        ))
                      ],
                    ),
                  )
                ],
              ),
              Divider(
                color: Colors.black,
                height: 0,
                thickness: 2,
                indent: 15,
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Proddetails extends StatelessWidget {
  final String idprod;
  final int totalamt;
  final int quantity;
  final int mrp;
  final String packing;
  final String category;
  final String name;

  Proddetails({
    this.name,
    this.category,
    this.idprod,
    this.quantity,
    this.mrp,
    this.totalamt,
    this.packing,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /*Text(
          'ProuctID : $idprod',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Divider(),*/
        Text(
          'Product Name :$name',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Divider(),
        Text(
          'MRP :Rs $mrp',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Divider(),
        Text(
          'Quantity :$quantity',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Divider(),
        Text(
          'Category : $category',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Divider(),
        Text(
          'Packing : $packing',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Divider(),
        Text(
          'Item total :Rs $totalamt',
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        Divider(thickness: 4),
        SizedBox(height: 10),
      ],
    );
  }
}
