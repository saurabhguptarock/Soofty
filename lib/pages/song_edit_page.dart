import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:soofty/shared/shared_code.dart';
import '../main.dart';
import 'package:soofty/model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SongEditPage extends StatefulWidget {
  final MusicFiles musicFiles;

  const SongEditPage({Key key, this.musicFiles}) : super(key: key);

  @override
  _SongEditPageState createState() => _SongEditPageState();
}

class _SongEditPageState extends State<SongEditPage> {
  ProgressDialog pr;
  double progress = 0.0;

  @override
  void initState() {
    analytics.setCurrentScreen(screenName: 'Song Edit Page');
    initialize();

    super.initState();
  }

  initialize() async {
    await handlePermission();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: () async {
            pr = ProgressDialog(context,
                isDismissible: false, type: ProgressDialogType.Download);
            pr.style(
                message: 'Downloading...',
                borderRadius: 10.0,
                backgroundColor: Colors.white,
                progressWidget: CircularProgressIndicator(),
                elevation: 10.0,
                insetAnimCurve: Curves.easeInOut,
                progress: progress,
                maxProgress: 100.0,
                progressTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400),
                messageTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 19.0,
                    fontWeight: FontWeight.w600));
            Dio dio = Dio();
            try {
              pr.show();
              Directory tempDir = await getApplicationDocumentsDirectory();
              String tempPath = tempDir.path;
              await dio.download(widget.musicFiles.audioUrl,
                  '$tempPath/${widget.musicFiles.name}.m4a',
                  onReceiveProgress: (rec, total) {
                setState(() {
                  progress =
                      double.parse(((rec / total) * 100).toStringAsFixed(0));
                });
              });
            } catch (e) {
              print(e);
            }
            pr.dismiss();
          },
          child: Text('data'),
        ),
      ),
    );
  }
}
