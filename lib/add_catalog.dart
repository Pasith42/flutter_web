import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web/model/catalogues.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

final formatter = DateFormat.yMMMMEEEEd();

class Addcatalog extends StatefulWidget {
  const Addcatalog({super.key});

  @override
  State<Addcatalog> createState() => _AddcatalogState();
}

class _AddcatalogState extends State<Addcatalog> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _roomController = TextEditingController();
  DateTime? _selectedstartDate;
  DateTime? _selectedcheckDate;
  Uint8List? selectedImageInBytes;
  String? selctFile;

  final firebasetore = FirebaseFirestore.instance;

  void _saveCatalogue() {
    final enterName = _nameController.text;
    //เพราะว่าเรากำหนดพิมพ์ข้อความตัวเลขอย่างเดียว ไม่จำเป็นมีตัวอักษร
    final enterNumber = int.tryParse(_numberController.text);
    final enterRoom = _roomController.text;
    final enterStartDate = _selectedstartDate;
    final enterChecktDate = _selectedcheckDate;

    final amountIsInvalid = enterNumber == null || enterNumber <= 0;

    if (enterName.isEmpty ||
        amountIsInvalid ||
        enterRoom.isEmpty ||
        enterStartDate == null ||
        enterChecktDate == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ข้อผิดพลาดในการนำเข้าข้อมูลรายการ'),
          content: const Text(
              'กรุณาตรวจสอบวันเดือนปี ชื่ออุปกรณ์ รหัสอุปกรณ์ และชื่อห้องด้วยครับ'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Okay'),
            )
          ],
        ),
      );
      return;
    }
    //ทดสอบ
    addToFirebase(
      enterName,
      enterNumber,
      enterRoom,
      enterStartDate,
      enterChecktDate,
    );
    /*
    ref.read(userCtataloguesProvider.notifier).appCatalogue(
        enterName,
        enterNumber,
        enterRoom,
        enterStartDate,
        enterChecktDate,
        _selectedImage!);
    */

    Navigator.of(context).pop();
    //แก้ไข
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text('เพิ่มรายการเสร็จสมบูรณ์'),
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
    );
  }

  void _presentDatePickerStart() async {
    final now = DateTime.now();
    final firstDate = DateTime(
        now.year - 1 /*เลือกตัวเลข ย้อนหลังกี่ปีครับ*/, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedstartDate = pickedDate;
    });
  }

  void _presentDatePickerEnd() async {
    final now = DateTime.now();
    final firstDate = DateTime(
        now.year - 1 /*เลือกตัวเลข ย้อนหลังกี่ปีครับ*/, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedcheckDate = pickedDate;
    });
  }

  //ทดสอบ
  Future<String> uploadImageToFirebase(
      String selctFile, Uint8List selectedImageInBytes) async {
    try {
      Reference reference =
          FirebaseStorage.instance.ref().child('mypicture1/$selctFile');
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      await reference
          .putData(selectedImageInBytes, metadata)
          .whenComplete(() => null);

      String downloadURL = await reference.getDownloadURL();

      return downloadURL;
    } on FirebaseException catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<void> addToFirebase(
      String enterName,
      int enterNumber,
      String enterRoom,
      DateTime enterStartDate,
      DateTime enterChecktDate) async {
    try {
      var imagetoFirebase =
          await uploadImageToFirebase(selctFile!, selectedImageInBytes!);
      final keepData = firebasetore.collection('keepDataสำเนา1');
      keepData
          .doc('$enterNumber')
          .set(Catalogues(
            name: enterName,
            number: enterNumber,
            room: enterRoom,
            startDate: enterStartDate,
            checkDate: enterChecktDate,
            image: imagetoFirebase,
          ).toFirestore())
          .onError((error, _) => print("Error writing document: $error"));
    } catch (err) {
      print('Caught error: $err');
    }
  }

  Future<void> selectFile() async {
    FilePickerResult? fileResult;
    try {
      fileResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
      );
    } on PlatformException catch (e) {
      print('Unsupported operation ${e.toString()}');
    } catch (e) {
      print(e.toString());
    }
    if (fileResult != null) {
      setState(() {
        selctFile = fileResult!.files.first.name;
        selectedImageInBytes = fileResult.files.first.bytes;
      });
    }
    print(selctFile);
  }

//ตรวจสอบใช้งานหรือไม่ครับ
  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('เพิ่มรายการใหม่',
              style: TextStyle(color: Colors.black)
              /*
            Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.onBackground),
                */
              ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              children: [
                TextField(
                    decoration: const InputDecoration(labelText: 'ชื่ออุปกรณ์'),
                    keyboardType: TextInputType.emailAddress,
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black)
                    /*Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
                      */
                    ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                    decoration:
                        const InputDecoration(labelText: 'รหัสของอุปกรณ์'),
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black)
                    /*Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),*/
                    ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                    decoration: const InputDecoration(labelText: 'ชื่อห้อง'),
                    controller: _roomController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black)
                    /*Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),*/
                    ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('วันที่เริ่มใช้งาน: '),
                    Text(
                        _selectedstartDate == null
                            ? 'ไม่มีข้อมูลวันเดือนปี'
                            : formatter.format(_selectedstartDate!),
                        style: const TextStyle(color: Colors.black)
                        /*Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),*/
                        ),
                    IconButton(
                        onPressed: _presentDatePickerStart,
                        icon: const Icon(Icons.calendar_month)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('วันที่ตรวจสอบสภาพ: '),
                    Text(
                        _selectedcheckDate == null
                            ? 'ไม่มีข้อมูลวันเดือนปี'
                            : formatter.format(_selectedcheckDate!),
                        style: const TextStyle(color: Colors.black)
                        /*Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground),*/
                        ),
                    IconButton(
                        onPressed: _presentDatePickerEnd,
                        icon: const Icon(Icons.calendar_month)),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 300,
                  width: 500,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2)),
                  ),
                  child: selctFile == null
                      ? Center(
                          child: TextButton.icon(
                              onPressed: selectFile,
                              icon: const Icon(Icons.image_outlined),
                              label: const Text('Take Picture from gallery')),
                        )
                      : GridTile(
                          footer: GridTileBar(
                            backgroundColor: Colors.black38,
                            title: Center(
                              child: IconButton(
                                  onPressed: selectFile,
                                  icon: const Icon(Icons.image_outlined)),
                            ),
                            subtitle: const Center(child: Text('Gallery')),
                          ),
                          child: Image.memory(
                            selectedImageInBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                ),
/*GestureDetector(
        onTap: () async {
          final source = await showImageSource(context);

          _takePicture(source!);
        },
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),),),*/
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('ยกเลิก')),
                    const SizedBox(
                      width: 40,
                    ),
                    ElevatedButton(
                        onPressed: _saveCatalogue,
                        child: const Text('บันทึก')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
