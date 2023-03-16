// Copyright 2022 Tebault Technology Group. All rights reserved.
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'dart:async' show Future;
import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class CoursePackageUtility {
  String _coursePackageName = "scormy_course.zip";

// setup class as a singleton using factory method
  CoursePackageUtility._privateConstructor();
  static final CoursePackageUtility _instance =
      CoursePackageUtility._privateConstructor();
  factory CoursePackageUtility() => _instance;

  /// Get the target path where all work will be done.
  Future<String> get targetPath async {
    Directory tempDirectory = await getTemporaryDirectory();
    return tempDirectory.path;
  }

  /// creates the zip package
  Future<bool> createZipArchive(String srcfolder) async {
    String path = await targetPath;
    String dataDirName = p.join(path, srcfolder);
    return await _zipDirectory(dataDirName);
  }

  /// Creates a zip file in the target directory with the name given by
  /// packageName.  Returns Future<bool>
  Future<bool> _zipDirectory(String dataDirName) async {
    // get the folder we want to zip
    String filename = await zipFilename;

    try {
      final packageFile = File(filename);

      // if a package with the same name exists, then remove it.
      if (packageFile.existsSync()) packageFile.deleteSync();

      // create the zip file.
      var encoder = ZipFileEncoder();
      encoder.zipDirectory(Directory(dataDirName), filename: filename);
    } catch (e) {
      developer.log(e.toString(),
          name: '_zipDirectory', level: 10, time: DateTime.now());
      return false;
    }
    return true;
  }

  //Copies course files from the asset package to a temporary folder
  Future<bool> copyFiles(String srcfolder) async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> courseFiles = json.decode(manifestJson);

    String path = await targetPath;

    // see if the targetPath exists and if so, deleted it.
    Directory test = Directory(p.join(path, srcfolder));
    if (test.existsSync()) {
      test.deleteSync(recursive: true);
    }

    var futures = <Future>[];
    courseFiles.forEach((key, value) async {
      if (key.contains(srcfolder)) {
        futures.add(_copyAsset(key, path));
      }
    });
    await Future.wait(futures);

    return true;
  }

  /// Copies a file from the asset bundle to a file with the same
  /// name in the target directory
  Future<String> _copyAsset(String filename, String targetPath) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      var data = await rootBundle.load(filename);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      if (defaultTargetPlatform == TargetPlatform.windows) {
        filename = filename.replaceAll("/", "\\");
      }

      String targetFile = p.join(targetPath, filename);
      File file = File(targetFile);
      file.createSync(recursive: true);
      file.writeAsBytesSync(bytes, mode: FileMode.write, flush: true);
      return targetFile;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// This updates the course specific properties. A dependancy is that
  /// the course files have already exist in the

  //.updateFiles(_title.text, _url.text, _percent)
  Future<bool> updateFiles(String title, String contentString, double percent,
      bool isYouTube) async {
    try {
      String videoId = "";
      String embedHTML = "";
      String path = await targetPath;
      String coursefolder = isYouTube ? "youtube" : "embed";

      var futures = <Future>[];

      if (isYouTube) {
        final Uri url = Uri.parse(contentString);
        videoId = url.pathSegments.last;
      } else {
        embedHTML = contentString;
        coursefolder = "embed";
      }

      // update the course files based on user input
      futures.add(updateManifestFile(path, title, coursefolder));
      futures.add(updateIndexFile(path, title, embedHTML, coursefolder));
      futures.add(updateConfigFile(path, videoId, percent, coursefolder));

      // wait for all the files to finish updating
      Future.wait(futures);
    } catch (e) {
      throw Exception(e.toString());
    }
    // return a value so the FutureBuilder has something to look for.
    return true;
  }

  // This reads the filename, replaces the TAG value with the VALUE
  /// and then saves the file to the target location
  Future<String> updateManifestFile(
      String targetPath, String value, String coursefolder) async {
    String fileName = p.join(coursefolder, "imsmanifest.xml");
    String key = "$coursefolder/imsmanifest.xml";
    String text = await rootBundle.loadString(key);
    // create the RegExp expression
    String expression = "#TITLE#";

    // create the RegEx pattern
    Pattern pattern = RegExp(expression, multiLine: true, caseSensitive: true);

    // escape the value
    value = htmlSerializeEscape(value, attributeMode: true);

    // update the tag with the value
    text = text.replaceAll(pattern, value);

    // write the file
    _writeFile(targetPath, fileName, text);

    return fileName;
  }

// This reads the filename, replaces the TAG value with the VALUE
  /// and then saves the file to the target location
  Future<String> updateIndexFile(String targetPath, String title,
      String embedHTML, String coursefolder) async {
    String fileName = p.join(coursefolder, "index.html");
    String key = "$coursefolder/index.html";
    String text = await rootBundle.loadString(key);

    // create the RegExp expression
    String expression = "#TITLE#";

    // create the RegEx pattern
    Pattern pattern = RegExp(expression, multiLine: true, caseSensitive: true);

    // escape the value
    title = htmlSerializeEscape(title, attributeMode: true);

    // update the tag with the value
    text = text.replaceAll(pattern, title);

    // if the embedHTML is not empty, then assume this is an embed course
    // and update the embed tag
    if (embedHTML.isNotEmpty) {
      // if this is not YouTube video
      // see if it is a URL or not
      if (embedHTML.toLowerCase().startsWith("http")) {
        // if a URL, turn it into an embed code
        String tempEmbedHTML =
            "<iframe src='#URL#' width='1440px' height='900px'></iframe>";
        embedHTML = tempEmbedHTML.replaceAll("#URL", embedHTML);
      }
      // create the RegExp expression
      expression = "#EMBED#";

      // create the RegEx pattern
      pattern = RegExp(expression, multiLine: true, caseSensitive: true);

      text = text.replaceAll(pattern, embedHTML);
    }

    // write the file
    _writeFile(targetPath, fileName, text);

    return fileName;
  }

  Future<String> updateConfigFile(String targetPath, String videoId,
      double percent, String courseFolder) async {
    // don't update the config if not a video course
    if (courseFolder != "youtube") return "";

    String fileName = p.join(courseFolder, "scormy-config.js");
    String key = "$courseFolder/scormy-config.js";
    String text = await rootBundle.loadString(key);

    // create the RegExp expression
    String expression1 = "#VIDEOID#";
    String expression2 = "#PERCENT#";

    // create the RegEx patterns
    Pattern pattern1 =
        RegExp(expression1, multiLine: true, caseSensitive: true);

    Pattern pattern2 =
        RegExp(expression2, multiLine: true, caseSensitive: true);

    // update the tag with the value
    text = text.replaceAll(pattern1, videoId);
    text = text.replaceAll(pattern2, percent.toString());

    // write the file
    _writeFile(targetPath, fileName, text);

    return fileName;
  }

  /// Write text to the given filename.
  void _writeFile(String targetPath, String fileName, String text) async {
    try {
      String outFile = p.join(targetPath, fileName);
      File file = File(outFile);
      file.writeAsStringSync(text,
          encoding: utf8, mode: FileMode.write, flush: true);
    } catch (e) {
      developer.log(e.toString(),
          name: 'writeFile', level: 10, time: DateTime.now());
    }
  }

  /// Reads text from the given file
  // ignore: unused_element
  String? _readFile(String targetPath, String fileName) {
    String inputFile = p.join(targetPath, fileName);
    File file = File(inputFile);
    return file.readAsStringSync(encoding: utf8);
  }

  String get coursePackageName {
    return _coursePackageName;
  }

  set coursePackageName(String value) {
    //remove anything not a letter, number or space
    String valueA9 = value.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '');

    // replace spaces with underscore
    valueA9 = valueA9.replaceAll(" ", "_");

    // The max email attachment length is 78 characters.  subtract 4 for the extension
    // then we need to trim the length to be 74 characters max
    if (valueA9.length > 74) {
      valueA9 = valueA9.substring(0, 74);
    }

    _coursePackageName = "$valueA9.zip";
  }

  /// this saves the zip package created in  the targetPath
  /// to a locale file provided by outputFileName
  Future<bool> saveZipPackage(String? outputFileName) async {
    String srcFileName = await zipFilename;
    File srcFile = File(srcFileName);
    if (outputFileName != null) {
      srcFile.copySync(outputFileName);
      return true;
    } else {
      return false;
    }
  }

  // returns the name of the zip package.
  Future<String> get zipFilename async {
    String path = await targetPath;
    String srcFilename = p.join(path, coursePackageName);
    return srcFilename;
  }

  String htmlSerializeEscape(String text, {bool attributeMode = false}) {
    StringBuffer? result;
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      String? replace;
      switch (ch) {
        case '&':
          replace = '&amp;';
          break;
        case '\u00A0' /*NO-BREAK SPACE*/ :
          replace = '&nbsp;';
          break;
        case '"':
          if (attributeMode) replace = '&quot;';
          break;
        case '<':
          if (!attributeMode) replace = '&lt;';
          break;
        case '>':
          if (!attributeMode) replace = '&gt;';
          break;
      }
      if (replace != null) {
        result ??= StringBuffer(text.substring(0, i));
        result.write(replace);
      } else if (result != null) {
        result.write(ch);
      }
    }

    return result != null ? result.toString() : text;
  }

  Future<String?> saveAsDialog(String dialogTitle) async {
    String filename;
    try {
      filename = p.basename(await zipFilename);
      String? outputFile = await FilePicker.platform.saveFile(
          lockParentWindow: true,
          type: FileType.any,
          dialogTitle: dialogTitle,
          fileName: filename);

      if (outputFile != null) {
        await saveZipPackage(outputFile);
        return outputFile;
      } else {
        return "";
      }
    } catch (e) {
      rethrow;
    }
  }
}
