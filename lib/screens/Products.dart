import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart.dart';
import 'dart:math';

class Products extends StatefulWidget {
  final uid;

  Products({this.uid});
  @override
  _ProductsState createState() => _ProductsState();
}

String uid;
int grand = 0;

class _ProductsState extends State<Products> {
  bool iswheat = true;
  @override
  void initState() {
    uid = widget.uid;
    super.initState();
  }

  String getorderid() {
    Random rnd = new Random();
    int min = 65;
    int max = 122;
    List<int> a = [];
    for (int i = 0; i < 4; i++) {
      int temp = rnd.nextInt(90 - min) + min;
      int temp2 = rnd.nextInt(max - 97) + 97;
      a.add(temp);
      a.add(temp2);
    }
    print(a);
    String f = String.fromCharCodes(a);
    print(f);
    String dt = DateTime.now().millisecondsSinceEpoch.toString().substring(9);

    return (f + dt);
  }

  @override
  Widget build(BuildContext ncontext) {
    print(uid);
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 60),
          child: AppBar(
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            elevation: 10,
            backgroundColor: Theme.of(context).primaryColor,
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text('Products'),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  final String oid = getorderid();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Cart(
                            cid: widget.uid,
                            orderid: oid,
                          )));
                },
                icon: Hero(
                    tag: 'mytag',
                    child: Icon(
                      Icons.shopping_cart_sharp,
                      size: 34.0,
                    )),
              )
            ],
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(5, 3, 2, 2),
                    children: <Widget>[
                      SizedBox(height: 15),
                      Center(child: Text('Category')),
                      SizedBox(height: 20),
                      Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Wheat'),
                            Switch(
                              value: iswheat,
                              onChanged: (val) {
                                setState(() {
                                  iswheat = val;
                                });
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              inactiveTrackColor: Colors.white,
                            ),
                            SizedBox(height: 20),
                            Text('Besan'),
                            Switch(
                              value: !iswheat,
                              onChanged: (val) {
                                setState(() {
                                  iswheat = !val;
                                });
                              },
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              inactiveTrackColor: Colors.white,
                            ),
                          ]),
                      SizedBox(height: 25),
                    ]),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                child: Productlist(
                  isWheat: iswheat,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Productlist extends StatelessWidget {
  final bool isWheat;

  Productlist({
    this.isWheat,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Products').snapshots(),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          print('no daata');
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.teal[900],
          ));
        } else {
          dynamic recps = snapshot.data.docs;
          //  Dbservice db = Dbservice(uid: uid);

          List<Product> products = [];
          for (var recp in recps) {
            @required
            final id = recp.data()['productID'];
            @required
            final sellerid = recp.data()['uid'];
            @required
            final mrp = recp.data()['mrp'];
            @required
            final category = recp.data()['category'];
            @required
            final name = recp.data()['productName'];
            @required
            final packing = recp.data()['netWeight'];
            //  var docum = db.reference.doc(uid);
            //docum.get().then((docume){buyerName=docume.data()['Name'];} );
            //print(buyerName.toString()+'asddas');
            if (isWheat) {
              if (category.toLowerCase().contains('wheat')) {
                var mr = int.parse(mrp);
                final Product pro = Product(
                  id: id,
                  name: name,
                  category: category,
                  packing: packing,
                  mrp: mr,
                  mcontext: context,
                  sellerid: sellerid,
                );
                products.add(pro);
              }
            } else {
              var mr = int.parse(mrp);
              if (category.toLowerCase().contains('besan')) {
                final Product pro = Product(
                  id: id,
                  name: name,
                  category: category,
                  packing: packing,
                  mrp: mr,
                  mcontext: context,
                  sellerid: sellerid,
                );
                products.add(pro);
              }
            }
          }
          if (products.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 30),
                  Icon(
                    Icons.not_interested,
                    size: 80,
                  ),
                  Text('No Products')
                ],
              ),
            );
          } else {
            return ListView(
              shrinkWrap: true,
              children: products,
            );
          }
        }
      },
    );
  }
}

class Product extends StatefulWidget {
  @required
  final String id;
  @required
  final String sellerid;
  @required
  final int mrp;
  @required
  final String packing;
  @required
  final String name;
  @required
  final String category;
  @required
  final BuildContext mcontext;

  Product(
      {this.sellerid,
      this.id,
      this.mrp,
      this.packing,
      this.name,
      this.category,
      this.mcontext});

  @override
  _ProductState createState() => _ProductState();
}

List<Cartprod> aa = [];
List<String> prodincart = [];

class _ProductState extends State<Product> {
  int qty = 1;
  String name;
  @override
  void initState() {
    //total = widget.mrp;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Dbservice db = Dbservice(uid:uid);
    //total=widget.mrp;
    return ListTile(
      title: SizedBox(height: 80,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      /* Text(
                        "Product id :" + widget.id ?? 'no id',
                        style: TextStyle(fontSize: 14.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: 5,
                      ),*/
                      Text(
                        ' ${widget.category}',
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: Theme.of(context).primaryColorDark),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${widget.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      /* Text('Packing : ${widget.packing}'),
                      SizedBox(
                        height: 5,
                      ),
                      Text('MRP : Rs${widget.mrp}'),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Quantity : $qty'),*/
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton.icon(
                      label: Text(
                        'Order',
                        style: TextStyle(
                          color: Colors.teal,
                        ),
                      ),
                      icon: Icon(
                        Icons.shopping_cart,
                        color: Colors.teal[900],
                      ),
                      onPressed: () async {
                        showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15))),
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            int tempqty = 1;
                            int total = widget.mrp;
                            return StatefulBuilder(builder: (context, setState) {
                              return Container(
                                  constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height),
                                  // padding: EdgeInsets.only( bottom:MediaQuery.of(context).viewInsets.bottom),
                                  width: double
                                      .infinity, //height: MediaQuery.of(context).size.height,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      //padding: EdgeInsets.symmetric(horizontal: 18.0),
                                      //shrinkWrap: true,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        SizedBox(height: 15),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'MRP: Rs${widget.mrp}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Spacer(),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text('Category : ${widget.category}',
                                            overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 10),
                                        /* Text(
                                          'Product ID : ${widget.id}',
                                          overflow: TextOverflow.visible,
                                        ),
                                        SizedBox(height: 10),*/
                                        Text(
                                          'Name: ${widget.name}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Quantity:'),
                                            IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: () {
                                                  setState(() {
                                                    if (tempqty > 1) {
                                                      tempqty = --tempqty;
                                                      total =
                                                          (widget.mrp * tempqty);
                                                    }
                                                  });
                                                }),
                                            Text(tempqty.toString()),
                                            IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () {
                                                  setState(() {
                                                    tempqty = ++tempqty;
                                                    total =
                                                        (widget.mrp * tempqty);
                                                  });
                                                }),
                                          ],
                                        ),
                                        Text(
                                          "Total: " +
                                              (total != null
                                                  ? total.round().toString()
                                                  : "empty"),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        ButtonBar(
                                          children: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Cancel")),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();

                                                if (prodincart.isEmpty) {
                                                  prodincart.add(widget.id);
                                                  Cartprod cartprod = Cartprod(
                                                    category: widget.category,
                                                    rate: widget.mrp,
                                                    name: widget.name,
                                                    sellerid: widget.sellerid,
                                                    packing: widget.packing,
                                                    idprod: widget.id,
                                                    totalamt: total,
                                                    quantity: tempqty,
                                                  );
                                                  setState(() {
                                                    aa.add(cartprod);
                                                  });
                                                } else {
                                                  if (prodincart
                                                      .contains(widget.id)) {
                                                    for (var prod in aa) {
                                                      if (prod.idprod ==
                                                          widget.id) {
                                                        print(prod.idprod +
                                                            widget.id);
                                                        prod.quantity += qty;
                                                        prod.totalamt =
                                                            prod.quantity *
                                                                prod.rate;
                                                      }
                                                    }
                                                  } else {
                                                    prodincart.add(widget.id);

                                                    Cartprod cartprod = Cartprod(
                                                      category: widget.category,
                                                      rate: widget.mrp,
                                                      sellerid: widget.sellerid,
                                                      name: widget.name,
                                                      packing: widget.packing,
                                                      idprod: widget.id,
                                                      totalamt: total,
                                                      quantity: tempqty,
                                                    );
                                                    setState(() {
                                                      aa.add(cartprod);
                                                    });
                                                  }
                                                }
                                                ScaffoldMessenger.of(
                                                        widget.mcontext)
                                                    .showSnackBar(SnackBar(
                                                  content: Text('Added to cart'),
                                                  duration: Duration(seconds: 2),
                                                ));

//

                                                /*  showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) {
                                                    String orderid = getorderid();
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(20))),
                                                    title: Text('Confirm Order'),
                                                    content: ListView(
                                                      shrinkWrap: true,
                                                      children: <Widget>[
                                                        Text('Order ID : $orderid',overflow: TextOverflow.ellipsis,maxLines: 2,),
                                                        SizedBox(height: 5),
                                                        Text(
                                                            'Category : ${widget.category}',overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text('Name : ${widget.name}',overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                        SizedBox(height: 5),
                                                        Text('MRP: Rs${widget.mrp}',overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text('Quantity : $tempqty',overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                        SizedBox(height: 5),
                                                        Text('Total Amount : Rs ' +
                                                            total.round().toString(),overflow: TextOverflow.ellipsis,maxLines: 1,),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text('Cancel'),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text('Confirm'),
                                                        onPressed: () async {
                                                                         Navigator.of(context).pop();
                                                                       
                                                                       await db.getname();
                                                                       print(buyerName);  
                                            await db.placeorder(
                                                              context: context,
                                                              status: 'pending',
                                                              idprod: widget.id,
                                                              idcust: db.uid,
                                                              quantity: tempqty,
                                                              totalamt: total,
                                                              remark: remark==""?'no remarks':remark,
                                                              rate: widget.mrp,
                                                              packing:widget.packing,
                                                              custName: buyerName,
                                                              category: widget.category,
                                                              orderid: orderid);
                                       

                                                              if(!error){
                                                                NotificationSend not=NotificationSend();
                                                            var token = await not.gettoken(uid:db.uid);
                                                            await not.sendNotification(token);


                                                            Scaffold.of(widget.mcontext).showSnackBar(SnackBar(content: Text('Order has been placed')));
                                                              }print(
                                                                error
                                                              );
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });*/
                                              },
                                              child: Text('ADD TO CART'),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ));
                            });
                          },
                        );
                      }),
                )
                // SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
