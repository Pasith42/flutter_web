import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web/add_catalog.dart';
import 'package:flutter_web/edit_catalog.dart';
//import 'package:flutter_web/addcatalog.dart';
import 'package:flutter_web/model/catalogues.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Catalogues> items = [];
  SearchController searchController = SearchController();
  List<String> heading = [
    'ชื่อพัสดุ',
    'รหัสพัสดุ',
    'เลขที่ห้อง',
    'วันที่ซื้อใหม่',
    'วันที่ตรวจสอบล่าสุด',
    'รูปภาพ',
    'แก้ไข',
    'ลบ',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Iterable<Catalogues> searchCatalogues(
      String query, List<Catalogues> catalogues) {
    final suggestions =
        List.generate(catalogues.length, (index) => catalogues[index])
            .where((element) {
      final nameLower = element.name.toLowerCase();
      final roomLower = element.room.toLowerCase();
      final numberLower = element.number.toString().toLowerCase();
      final searchLower = query.toLowerCase();
      return nameLower.startsWith(searchLower) ||
          roomLower.startsWith(searchLower) ||
          numberLower.startsWith(searchLower);
    });
    return suggestions;
  }

  final firebase = FirebaseFirestore.instance.collection('keepDataสำเนา1');
  Stream<List<Catalogues>> readCatalogues() =>
      firebase.snapshots().map((snapshot) =>
          snapshot.docs.map((e) => Catalogues.tofromJson(e.data())).toList());

  Future<void> deleteCatalog(String doc, String http) async {
    final httpsReference = FirebaseStorage.instance.refFromURL(http);
    httpsReference.delete();
    return firebase.doc(doc).delete().then(
          (doc) => showDialog(
            context: context,
            builder: (BuildContext context) => Expanded(
              child: AlertDialog(
                content: const Text("ลบข้อมูลเสร็จสมบูรณ์"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      return Navigator.of(context).pop();
                    },
                    child: const Text(
                      'OK',
                    ),
                  ),
                ],
              ),
            ),
          ),
          onError: (e) => showDialog(
            context: context,
            builder: (BuildContext context) => Expanded(
              child: AlertDialog(
                title: Text(
                  "ข้อผิดพลาด",
                ),
                content: const Text("ลบข้อมูลไม่เสร็จสมบูรณ์\n ลองลบอีกครั้ง"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      return Navigator.of(context).pop();
                    },
                    child: const Text(
                      'OK',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Catalogues>>(
      stream: readCatalogues(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: SizedBox(
                  child: Text(
            'บางสิ่งผิดปกติ',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          )));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('ไม่มีข้อมูลรายการอุปกรณ์ของห้อง'),
            );
          }
        }
        final userCatalogues = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.normal),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  //ใช้งานหรือเปล่า
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Addcatalog()));
                },
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    SearchAnchor.bar(
                      constraints: const BoxConstraints(maxWidth: 700),
                      searchController: searchController,
                      barLeading: const Icon(
                        Icons.search,
                        color: Colors.black54,
                      ),
                      barTrailing: [
                        IconButton(
                            onPressed: () {
                              searchController.clear();
                            },
                            icon: const Icon(Icons.clear))
                      ],
                      viewTrailing: [
                        IconButton(
                            onPressed: () {
                              searchController.closeView(searchController.text);
                              List<Catalogues> item = searchCatalogues(
                                      searchController.text, userCatalogues)
                                  .toList();
                              setState(() {
                                items.clear();
                                items.addAll(item);
                              });
                            },
                            icon: const Icon(Icons.search)),
                        IconButton(
                            onPressed: () {
                              searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                            icon: const Icon(Icons.clear)),
                      ],
                      barTextStyle: MaterialStateProperty.all(
                          const TextStyle(color: Colors.black54)),
                      barHintText: 'ค้นหาข้อมูลชื่อของอุปกรณ์',
                      isFullScreen: false,
                      dividerColor: Colors.black38,
                      viewSide: const BorderSide(color: Colors.blue),
                      viewConstraints: const BoxConstraints(maxHeight: 350),
                      suggestionsBuilder: (context, controller) {
                        final keyword = controller.value.text;
                        //ต้องมี Listจากการกรอกข้อมูล
                        return searchCatalogues(keyword, userCatalogues).map(
                          (item) => ListTile(
                            leading: Image.network(
                              item.image,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                            title: Text(item.name),
                            subtitle: Column(
                              children: [
                                Text(item.room),
                                Text('${item.checkDate}')
                              ],
                            ),
                            onTap: () {
                              controller.closeView(keyword);
                              FocusScope.of(context).unfocus();
                              //ใช้งานหรือเปล่า
                              setState(() {
                                controller.text = item.name;
                                items.clear();
                                items.add(item);
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    userCatalogues.isEmpty
                        ? Center(
                            child: SizedBox(
                              height: 300,
                              child: Text(
                                'ไม่มีรายการที่มีอยู่',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                              ),
                            ),
                          )
                        : DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 135, 218, 139)),
                            headingRowHeight: 100,
                            dataRowMinHeight: 10,
                            dataRowMaxHeight: 70,
                            dividerThickness: 2,
                            border:
                                TableBorder.all(color: Colors.black, width: 1),
                            columns: <DataColumn>[
                              ...heading.map(
                                (data) => DataColumn(
                                  label: Text(
                                    data,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  numeric: true,
                                ),
                              )
                            ],
                            rows: items.isEmpty
                                ? <DataRow>[
                                    ...userCatalogues.map(
                                      (data) => DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(data.name)),
                                          DataCell(
                                              Text(data.number.toString())),
                                          DataCell(Text(data.room)),
                                          DataCell(Text(DateFormat('d/M/y')
                                              .format(data.startDate))),
                                          DataCell(Text(DateFormat('d/M/y')
                                              .format(data.checkDate))),
                                          DataCell(
                                            InkWell(
                                                focusColor: Colors.grey[350],
                                                child: Image.network(
                                                  data.image,
                                                  fit: BoxFit.fill,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                onTap: () async {
                                                  final httpsReference1 =
                                                      FirebaseStorage.instance
                                                          .refFromURL(
                                                              data.image);
                                                  return showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: Text(
                                                        httpsReference1
                                                            .fullPath,
                                                      ),
                                                      content: Image.network(
                                                        data.image,
                                                        fit: BoxFit.fitHeight,
                                                        height: 500,
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            print(data.image);
                                                            return Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_square,
                                                color: Colors.brown,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditCatalog(
                                                            name: data.name,
                                                            number: data.number,
                                                            room: data.room,
                                                            start:
                                                                data.startDate,
                                                            check:
                                                                data.checkDate,
                                                            image: data.image),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () => showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'ลบรายการ${data.name}',
                                                    ),
                                                    content: Text(
                                                        'คุณต้องการลบข้อมูล${data.name}\n หลังจากนั้นข้อมูล${data.name}จะไม่กลับมาอีก'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          return Navigator.of(
                                                                  context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteCatalog(
                                                              '${data.number}',
                                                              data.image);

                                                          return Navigator.of(
                                                                  context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'OK',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                : <DataRow>[
                                    ...items.map(
                                      (data) => DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(data.name)),
                                          DataCell(
                                              Text(data.number.toString())),
                                          DataCell(Text(data.room)),
                                          DataCell(Text(DateFormat('d/M/y')
                                              .format(data.startDate))),
                                          DataCell(Text(DateFormat('d/M/y')
                                              .format(data.checkDate))),
                                          DataCell(
                                            InkWell(
                                                focusColor: Colors.grey[350],
                                                child: Image.network(
                                                  data.image,
                                                  fit: BoxFit.fill,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                onTap: () async {
                                                  final httpsReference1 =
                                                      FirebaseStorage.instance
                                                          .refFromURL(
                                                              data.image);
                                                  return showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title: Text(
                                                        httpsReference1
                                                            .fullPath,
                                                      ),
                                                      content: Image.network(
                                                        data.image,
                                                        fit: BoxFit.fitHeight,
                                                        height: 500,
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            print(data.image);
                                                            return Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_square,
                                                color: Colors.brown,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditCatalog(
                                                            name: data.name,
                                                            number: data.number,
                                                            room: data.room,
                                                            start:
                                                                data.startDate,
                                                            check:
                                                                data.checkDate,
                                                            image: data.image),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () => showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'ลบรายการ${data.name}',
                                                    ),
                                                    content: Text(
                                                        'คุณต้องการลบข้อมูล${data.name}\n หลังจากนั้นข้อมูล${data.name}จะไม่กลับมาอีก'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          return Navigator.of(
                                                                  context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteCatalog(
                                                              '${data.number}',
                                                              data.image);

                                                          return Navigator.of(
                                                                  context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'OK',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
