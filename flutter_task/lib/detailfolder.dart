import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'MyVideoPlayerPage.dart';
class InnerFolder extends StatefulWidget{

  InnerFolder({Key? key,required this.filespath,
    required this.callbackfunction,required this.naviagate,required this.urltype}): super(key: key);
  final String filespath;

  final Function callbackfunction,naviagate,urltype;

  @override
  State<StatefulWidget> createState() {
    return InnerFolderState();
  }

}


class InnerFolderState extends State<InnerFolder>{

  String get fileStr =>widget.filespath;
  final folderController = TextEditingController();
  String nameOfFolder="";
  late List<FileSystemEntity> _folders;
  String deleletfile="";


  Future<void> getDir() async {
    /* final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    String pdfDirectory = '$dir/';
    final myDir = new Directory(pdfDirectory);*/

    // final directory = await getApplicationDocumentsDirectory();
    // final dir = directory.path;
    // debugPrint("Clicked folder  $fileStr");
    final myDir = new Directory(fileStr);

    setState(() {
      _folders = myDir.listSync(recursive: false, followLinks: false);
    });
    print(_folders);
  }


  @override
  void initState() {

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
              widget.callbackfunction(context,widget.filespath);
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

                            if(snapshot.hasData)
                            {
                              // FileStat f=snapshot.data;
                              // debugPrint("File type  ${f.toString()}");
                              String type = widget.urltype(_folders[index].path);
                              bool isFolder =FileSystemEntity.isDirectorySync(_folders[index].path);
                              debugPrint("File or Folder  $isFolder");

                              debugPrint("File Type  $type");
                              debugPrint("File type1  ${snapshot.data.runtimeType.toString()}");

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
                                    debugPrint("Video ");
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
                              }else
                              {
                                return  InkWell(
                                  onTap: (){
                                    widget.naviagate(context,_folders[index].path);
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
  Future getFileType(file)
  {

    return file.stat();
  }

  _syncFiles(String path){
    final myDir = new Directory(path);
    setState(() {
      _folders = myDir.listSync(recursive: false, followLinks: false);
    });
    print("Sync file is called ");
  }
}