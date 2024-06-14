import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sunmolor_team/helper/dimension.dart';
import 'package:sunmolor_team/overlay/error_overlay.dart';
import 'package:sunmolor_team/overlay/success_overlay.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _folderController = TextEditingController();
  String? _selectedFolder;
  List<File> _images = [];
  final picker = ImagePicker();
  double _uploadProgress = 0.0;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _allPhotos = [];
  List<Map<String, dynamic>> _selectedPhotos = [];

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();
        if (userDoc.exists) {
          String status = userDoc['status'];
          setState(() {
            _isAdmin = status == 'admin' || status == 'founder';
          });
        }
      }
    } catch (e) {
      print('Error loading user status from Firestore: $e');
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    setState(() {
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        _images =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      } else {
        print('No images selected.');
      }
    });
  }

  Future<void> _uploadFiles() async {
    if (_images.isNotEmpty && _selectedFolder != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      String uploaderEmail = user.email!;
      for (var image in _images) {
        String fileName = Path.basename(image.path);
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('uploads/$_selectedFolder/$fileName');
        UploadTask uploadTask = storageReference.putFile(image);
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred.toDouble() /
                snapshot.totalBytes.toDouble();
          });
        });

        await uploadTask.whenComplete(() => null);
        String downloadURL = await storageReference.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('uploads')
            .doc(_selectedFolder)
            .collection('images')
            .add({
          'url': downloadURL,
          'nama_file': fileName,
          'tanggal_upload': DateTime.now(),
          'diupload_oleh': uploaderEmail,
        });
      }
      setState(() {
        _images = [];
        _uploadProgress = 0.0;
      });

      Navigator.of(context).push(
        SuccessOverlay(
          message: "Photo Berhasil Di Upload",
        ),
      );
    } else {
      Navigator.of(context).push(
        ErrorOverlay(
          message: "Tidak ada photo untuk diupload\nPilih foto terlebih dahulu",
        ),
      );
    }
  }

  Future<void> _createFolder(String folderName) async {
    await FirebaseFirestore.instance
        .collection('uploads')
        .doc(folderName)
        .set({'created': FieldValue.serverTimestamp()});
    setState(() {
      _selectedFolder = folderName;
    });
    Navigator.of(context).push(
      SuccessOverlay(
        message: "Folder Berhasil Dibuat",
      ),
    );
  }

  Future<List<String>> _getFolders() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('uploads').get();
    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<Map<String, dynamic>>> _getPhotos(String folder) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('uploads')
        .doc(folder)
        .collection('images')
        .get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> _downloadFile(String url) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final Reference ref = FirebaseStorage.instance.refFromURL(url);
    final Directory? tempDir = await getExternalStorageDirectory();
    final Directory downloadDir =
        Directory('${tempDir!.path}/sunmolor_team_photos');

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    final File file = File('${downloadDir.path}/${ref.name}');
    final downloadTask = ref.writeToFile(file);

    downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _downloadProgress = snapshot.bytesTransferred.toDouble() /
            snapshot.totalBytes.toDouble();
      });
    });

    await downloadTask.whenComplete(() {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });

      Navigator.of(context).push(
        SuccessOverlay(
          message: "Photo Berhasil Disimpan di ${file.path}",
        ),
      );
    });
  }

  Future<void> _deletePhoto(
      BuildContext context, Map<String, dynamic> photo) async {
    if (_selectedFolder != null && photo != null) {
      final Reference ref = FirebaseStorage.instance.refFromURL(photo['url']);
      await ref.delete();
      await FirebaseFirestore.instance
          .collection('uploads')
          .doc(_selectedFolder)
          .collection('images')
          .doc(photo['id'])
          .delete();
      setState(() {
        _allPhotos.remove(photo);
        _selectedPhotos.remove(photo);
      });
      Navigator.pop(context);
      Navigator.of(context).push(
        SuccessOverlay(
          message: "Photo Berhasil Dihapus",
        ),
      );
    }
  }

  Future<void> _selectAllPhotos() async {
    setState(() {
      _selectedPhotos = List.from(_allPhotos);
    });
  }

  Future<void> _deselectAllPhotos() async {
    setState(() {
      _selectedPhotos = [];
    });
  }

  Future<void> _downloadAllSelectedPhotos() async {
    for (var photo in _selectedPhotos) {
      await _downloadFile(photo['url']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Upload Photo'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) async {
              switch (item) {
                case 0:
                  await _selectAllPhotos();
                  break;
                case 1:
                  await _deselectAllPhotos();
                  break;
                case 2:
                  await _downloadAllSelectedPhotos();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.select_all_rounded),
                    SizedBox(width: 8),
                    Text('Pilih Semua'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Batalkan Pilihan'),
                  ],
                ),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.download_for_offline_rounded,
                        color: Colors.green),
                    SizedBox(width: 8),
                    Text('Download semua yang dipilih'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isAdmin)
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[500]),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _folderController,
                      decoration: InputDecoration(
                        labelText: 'Masukan Nama Folder',
                        labelStyle: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.create_new_folder_rounded,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (_folderController.text.isNotEmpty) {
                              _createFolder(_folderController.text);
                              _folderController.clear();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: FutureBuilder<List<String>>(
                    future: _getFolders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No folders available');
                      } else {
                        return DropdownButton<String>(
                          value: _selectedFolder,
                          hint: const Text('Pilih Folder'),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFolder = newValue;
                              _selectedPhotos = [];
                            });
                          },
                          items: snapshot.data!
                              .map<DropdownMenuItem<String>>((String folder) {
                            return DropdownMenuItem<String>(
                              value: folder,
                              child: Text(folder),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
                Wrap(
                  spacing: 10,
                  children: _images
                      .map((image) => Stack(
                            children: [
                              Image.file(image, width: 100, height: 100),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _images.remove(image);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                if (_uploadProgress > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: LinearProgressIndicator(
                      value: _uploadProgress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                if (_isAdmin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: _pickImages,
                        child: Icon(Icons.photo_library_rounded,
                            color: Colors.orange[200]),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: _uploadFiles,
                        child: Icon(Icons.upload_file_rounded,
                            color: Colors.orange[200]),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (_selectedFolder != null)
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getPhotos(_selectedFolder!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                color: Colors.white,
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                "assets/lottie/no.json",
                                frameRate: const FrameRate(60),
                                width: Dimensions.size100 * 2,
                                repeat: true,
                              ),
                              Text(
                                "Tidak ada photo di folder ini...",
                                style: TextStyle(
                                  fontSize: Dimensions.text20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        _allPhotos = List.from(snapshot.data!);
                        return Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                var photo = snapshot.data![index];
                                bool isSelected =
                                    _selectedPhotos.contains(photo);
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedPhotos.remove(photo);
                                      } else {
                                        _selectedPhotos.add(photo);
                                      }
                                    });
                                    await showDialog(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.network(photo['url']),
                                                if (_isDownloading)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16.0),
                                                    child: Column(
                                                      children: [
                                                        Lottie.asset(
                                                          'assets/lottie/download.json',
                                                          width: 100,
                                                          height: 100,
                                                        ),
                                                        LinearProgressIndicator(
                                                          value:
                                                              _downloadProgress,
                                                          minHeight: 10,
                                                          backgroundColor:
                                                              Colors.grey[200],
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.blue),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Icon(
                                                          Icons.close_rounded),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    ElevatedButton(
                                                      onPressed: _isDownloading
                                                          ? null
                                                          : () {
                                                              _downloadFile(
                                                                  photo['url']);
                                                            },
                                                      child: const Icon(
                                                        Icons
                                                            .file_download_rounded,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    if (_isAdmin)
                                                      ElevatedButton(
                                                        onPressed:
                                                            _isDownloading
                                                                ? null
                                                                : () {
                                                                    _deletePhoto(
                                                                        context,
                                                                        photo);
                                                                  },
                                                        child: const Icon(
                                                          Icons.delete_forever,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      isSelected
                                          ? Colors.grey
                                          : Colors.transparent,
                                      BlendMode.saturation,
                                    ),
                                    child: Image.network(photo['url']),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
