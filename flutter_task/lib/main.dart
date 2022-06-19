import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_task/MyVideoPlayerPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'detailfolder.dart';


/**************************************************************************
 * main() --- Flutter application invocation point
 *
 ************************************************************************/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  MyHomePage(),
    );
  }
}


/**************************************************************************
 * MyHomePage() --- Class  for show home screen content
 *
 ************************************************************************/

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


/**************************************************************************
 * _MyHomePageState() --- Class is stateful class for homepage
 *
 ************************************************************************/
class _MyHomePageState extends State<MyHomePage> {
  final folderController = TextEditingController();
  String nameOfFolder ="";
  String applicationPath ="";
   late List<FileSystemEntity> _folders;
  final ImagePicker _picker = ImagePicker();
  bool ischild =false;
  GlobalKey<InnerFolderState> globalKey = GlobalKey();


  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    primary: Colors.black87,
    minimumSize: Size(88, 36),
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    backgroundColor: Colors.blue,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    _folders=[];
    getDir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Folder Info"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              ischild =false;
              _displayOptionDialog(context,applicationPath);
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          // childAspectRatio: MediaQuery.of(context).size.width /
          //     (MediaQuery.of(context).size.height / 4),
        ),
        itemBuilder: (context, index) {
          return Material(
            elevation: 6.0,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                          future: getFileType(_folders[index]),
                          builder: (ctx,snapshot){
                            debugPrint("Folder  length  ${_folders.length}");
                            if(snapshot.hasData)
                            {
                             String type = getUrlType(_folders[index].path);
                             bool isFolder =FileSystemEntity.isDirectorySync(_folders[index].path);
                             debugPrint("File or Folder  $isFolder");

                             debugPrint("File Type  $type");
                              // FileStat f=snapshot.data;
                              // debugPrint("File type  ${f.toString()}");
                              // debugPrint("File type1  ${snapshot.data.runtimeType.toString()}");
                              // if(/*f.type*/snapshot.data.runtimeType.toString().contains("file"))
                              if(!isFolder)
                                 {
                                   if(type == "Unknown") {
                                     return Icon(
                                       Icons.file_copy_outlined,
                                       size: 100,
                                       color: Colors.orange,
                                     );
                                   }
                                   else{
                                     if(type == "Image"){
                                       debugPrint("Image ");
                                       return Image.file(
                                         File(_folders[index].path),
                                         height: 100,
                                       );
                                     }

                                     if(type == "Video"){
                                       debugPrint("Image ");
                                       return InkWell(
                                         onTap: () {
                                           Navigator.push(context,
                                               MaterialPageRoute(
                                                   builder: (builder) {
                                                     return VideoPlayerPage(
                                                         filespath: _folders[index]
                                                             .path);
                                                   }));
                                         },
                                         child: Icon(
                                           Icons.play_circle_fill,
                                           size: 50,
                                           color: Colors.blue,
                                         ),
                                       );
                                     }
                                   }
                              }
                                else {
                                  return InkWell(
                                    onTap: ()  {
                                      Navigator.push(context,
                                           MaterialPageRoute(
                                              builder: (builder) {
                                                return InnerFolder(key: globalKey,
                                                    filespath: _folders[index]
                                                        .path, callbackfunction:callFunction,naviagate:callFunctionNavigate,urltype:getUrlType);
                                              }));
                                    },
                                    child: Icon(
                                      Icons.folder,
                                      size: 100,
                                      color: Colors.orange,
                                    ),
                                  );
                                }
                            }
                            return Icon(
                              Icons.file_copy_outlined,
                              size: 100,
                              color: Colors.orange,
                            );
                          }),
                      Text(
                        '${_folders[index].path.split('/').last}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: _folders.length,
      ),
    );
  }

  /**************************************************************************
   * _displayOptionDialog() --- Show the dialog with three options
   *
   ************************************************************************/


  _displayOptionDialog(BuildContext context,String path) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Option'),
          elevation: 10,
          children:[
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                _showFolderCreateDialog(context,path);
              },
              child: const Text('Create Folder'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(path);
              },
              child: const Text(' choose an image'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                _pickVideo(path);
              },
              child: const Text(' video from gallery '),
            ),
          ],
          //backgroundColor: Colors.green,
        );
      },
    );
  }



  /**************************************************************************
   * _showFolderCreateDialog() --- Show the folder create dialog
   *
   ************************************************************************/

  Future<void> _showFolderCreateDialog(BuildContext context,String path) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                'ADD FOLDER',
                textAlign: TextAlign.left,
              ),

            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                controller: folderController,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter folder name'),
                onChanged: (val) {
                  setState(() {
                    nameOfFolder = folderController.text;
                    print(nameOfFolder);
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              style: flatButtonStyle,
              child: Text(
                'Add',
                style: TextStyle(color: Colors.black87),
              ),
              onPressed: () async {
                if (nameOfFolder != null) {
                  await callFolderCreationMethod(nameOfFolder,path);
                  getDir();
                  setState(() {
                    folderController.clear();
                    nameOfFolder = "";
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              style: flatButtonStyle,
              child: Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /**************************************************************************
   * callFolderCreationMethod() --- Create the folder
   *
   ************************************************************************/
  callFolderCreationMethod(String folderInAppDocDir,String path) async {
    // ignore: unused_local_variable
    String actualFileName = await createFolderInAppDocDir(folderInAppDocDir,path);
    print(actualFileName);
    _syncFiles(path);
  }

  /**************************************************************************
   * _syncFiles() --- sync the files
   *
   ************************************************************************/

  _syncFiles(String path){
    final myDir = new Directory(path);
    setState(() {
      _folders = myDir.listSync(recursive: false, followLinks: false);
    });
    print("Sync file is called ");
  }

  /**************************************************************************
   * createFolderInAppDocDir() --- Create the folder
   *
   ************************************************************************/

  Future<String> createFolderInAppDocDir(String folderName,String path) async {

    // final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    // final Directory _appDocDirFolder = Directory('${_appDocDir.path}/$folderName/');
    // final Directory _appDocDirFolder = Directory('${applicationPath}/$folderName/');
    final Directory _appDocDirFolder = Directory('${path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
      await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  /**************************************************************************
   * getDir() --- get the  directory and file list
   *
   ************************************************************************/

  Future<void> getDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    applicationPath = dir;
    debugPrint("Directory path $applicationPath");
    String pdfDirectory = '$applicationPath/';
    final myDir = new Directory(pdfDirectory);
    debugPrint("Directory path1 $myDir");

    setState(() {
      _folders = myDir.listSync(recursive: false, followLinks: false);
    });
    print(_folders);
  }

  Future getFileType(file)
  {

    return file.stat();
  }

  /**************************************************************************
   * getUrlType() --- Check the file type
   *
   ************************************************************************/

  String getUrlType(String url) {
    Uri uri = Uri.parse(url);
    String typeString = uri.path.substring(uri.path.length - 3).toLowerCase();
    if (typeString == "jpg" || typeString == "png") {
      return "Image";
    }
    if (typeString == "mp4") {
      return "Video";
    } else {
      return "Unknown";
    }
  }

  /**************************************************************************
   * callFunction() --- Show alert dialog from child view
   *
   ************************************************************************/

  void callFunction(BuildContext context,String path){
    print("pick image is called 1111");
    print("Current path $path");
    ischild =true;
    _displayOptionDialog(context,path);
  }

  /**************************************************************************
   * callFunctionNavigate() --- Naviage the view from child view
   *
   ************************************************************************/


  void callFunctionNavigate(BuildContext context,String path){
    print("Navigate to next screen");
    Navigator.push(context,
        MaterialPageRoute(
            builder: (builder) {
             GlobalKey globalKey =getglobelkey();
              return InnerFolder(key: globalKey,
                  filespath:path, callbackfunction:callFunction,naviagate:callFunctionNavigate,urltype:getUrlType);
            }));
  }

  /**************************************************************************
   * _pickImage() --- pick the image from gallery
   *
   ************************************************************************/

  Future<void> _pickImage(String path) async{
    try {
      print("pick image is called");
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: null,
        maxHeight: null,
        imageQuality: 100,
      );
      debugPrint("File Path ${pickedFile!.path}");
      File file = File(pickedFile.path);
      // moveFile(file);
      _SaveImageFile(file,path/*applicationPath*/);
      _syncFiles(path);
    } catch (e) {
      setState(() {
        // _pickImageError = e;
      });
    }
  }

  /**************************************************************************
   * _pickVideo() --- pick the video from gallery
   *
   ************************************************************************/

  Future<void> _pickVideo(String path) async {
    try{
      final XFile? videofile = await _picker.pickVideo(
          source: ImageSource.gallery, maxDuration: const Duration(seconds: 10));
      debugPrint("Video File Path ${videofile!.path}");
      File file = File(videofile.path);
      _saveVideoFile(file,path);
      _syncFiles(path);

    }
    catch(e){

    }
  }

  /**************************************************************************
   * getApplicationPath() --- get application path
   *
   ************************************************************************/

  void getApplicationPath() async{
    final appDocDir = await getApplicationDocumentsDirectory();
    applicationPath = appDocDir.path;
  }
  /**************************************************************************
   * _SaveImageFile() --- Save the image file
   *
   ************************************************************************/

  Future<File> _SaveImageFile(File pickedFile,String path) async {

    String fileName = pickedFile.path.split('/').last;
    print("file name == $fileName");
    Directory _appDocDirFolder = Directory('${path}');
    if (!await _appDocDirFolder.exists())
      _appDocDirFolder = await _appDocDirFolder.create(recursive: true);

    String temppath = _appDocDirFolder.path;
    File file = File('$temppath/${fileName}');
    var imgfile = await file.create();
    imgfile.openWrite();
    imgfile.writeAsBytesSync(pickedFile.readAsBytesSync());

    return imgfile;
  }

  /**************************************************************************
   * _saveVideoFile() --- Save the video
   *
   ************************************************************************/

  Future<File> _saveVideoFile(File pickedFile,String path) async {
    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // String appDocPath = appDocDir.path;
    String fileName = pickedFile.path.split('/').last;
    print("file name == $fileName");


    Directory _appDocDirFolder = Directory('${path}');
    if (!await _appDocDirFolder.exists())
      _appDocDirFolder = await _appDocDirFolder.create(recursive: true);

    // String temppath = _appDocDirFolder.path;
    File file = File('$path/${fileName}.mp4');
    var imgfile = await file.create();
    imgfile.openWrite();
    imgfile.writeAsBytesSync(pickedFile.readAsBytesSync());

    return imgfile;
  }

  /**************************************************************************
   * getglobelkey() --- get global key of child view
   *
   ************************************************************************/

  GlobalKey getglobelkey(){
    GlobalKey<InnerFolderState> globalKey = GlobalKey();
    globalKey =globalKey;
    return globalKey;

  }
}
