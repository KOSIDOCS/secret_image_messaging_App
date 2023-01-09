import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secret_image_messaging/core/custom_colors.dart';
import 'package:secret_image_messaging/utils/helpers.dart';
import 'package:steganograph/steganograph.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/ws'),
      pingInterval: const Duration(seconds: 1));
  // WebSocketChannel channel2 = WebSocketChannel.connect(
  //   // Uri.parse('wss://ws-feed.pro.coinbase.com'),
  //   Uri.parse('ws://localhost:8080/ws'),
  // );
  final myChatId = const Uuid().v4();
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final streamController = StreamController.broadcast();
  late Socket socket;
  String imageData = '';
  List<Map<String, dynamic>> messages = [
    {
      'id': 1,
      'isMe': true,
      'messageType': 'text',
      'message': 'Hello Friends here?'
    },
    {
      'id': 2,
      'isMe': false,
      'messageType': 'text',
      'message': 'Hello Friends here?'
    },
    {
      'id': 3,
      'isMe': true,
      'messageType': 'text',
      'message': 'Hello Friends here?'
    },
    {
      'id': 4,
      'isMe': false,
      'messageType': 'text',
      'message': 'Hello Friends here?'
    },
    {
      'id': 5,
      'isMe': true,
      'messageType': 'text',
      'message': 'Hello Friends here?'
    },
    {
      'id': 6,
      'isMe': false,
      'messageType': 'text',
      'message': 'Hello Friends here?'
    },
  ];

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  // void handleData(Uint8List data, EventSink<String> sink) {
  //   sink.add(data.);
  // }

  void connectToServer() {
    try {
      // channel = IOWebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'),
      //     pingInterval: const Duration(seconds: 1));

      // channel.stream.listen((event) {
      //   log('Recieved Infor right here');
      //   if (kDebugMode) {
      //     print('Listing');
      //   }

      //   final decodeEvent = jsonDecode(event);

      //   final newMessage = {
      //     'id': decodeEvent['id'],
      //     'isMe': decodeEvent['id'] == myChatId,
      //     'messageType': 'text',
      //     'message': decodeEvent['message']
      //   };

      //   log(decodeEvent['message']);

      //   setState(() {
      //     messages.add(newMessage);
      //   });

      //   log(event);
      // });

      // channel2 = WebSocketChannel.connect(
      //   // Uri.parse('wss://ws-feed.pro.coinbase.com'),
      //   Uri.parse('ws://localhost:8080/ws'),
      // );

      // log(channel.stream.isBroadcast.toString());

      // streamController.addStream(channel.stream);

      // streamController.add(
      //   jsonEncode({
      //     'id': 6,
      //     'isMe': false,
      //     'messageType': 'text',
      //     'message': 'See you soon'
      //   }),
      // );

      /// Listen for all incoming data
      // channel.stream.listen(
      //   (data) {
      //     if (kDebugMode) {
      //       print(data);
      //     }

      //     final decodeEvent = jsonDecode(data);

      //     final newMessage = {
      //       'id': decodeEvent['id'],
      //       'isMe': decodeEvent['id'] == myChatId,
      //       'messageType': 'text',
      //       'message': decodeEvent['message']
      //     };

      //     setState(() {
      //       messages.add(newMessage);
      //     });
      //   },
      //   onError: (error) {
      //     if (kDebugMode) {
      //       print(error);
      //     }
      //   },
      // );

      // var fromByte = StreamTransformer<List<int>, List<int>>.fromHandlers(
      //     handleData: (data, sink) {
      //   sink.add(data.buffer.asInt64List());
      // });

      //   final transform = StreamTransformer<Uint8List, String>.fromBind(
      // (stream) => stream.transform(utf8.decoder));

      // StreamTransformer doubleTransformer =
      //     StreamTransformer<Uint8List, String>.fromHandlers(handleData: handleData);

      Socket.connect("localhost", 4567).then((Socket sock) {
        socket = sock;
        socket
            .map((uint8list) => uint8list.toList())
            .transform(const Utf8Decoder())
            //.transform(const LineSplitter())
            .listen(dataHandler,
                onError: errorHandler,
                onDone: doneHandler,
                cancelOnError: false);
      }).catchError((e) {
        log("Unable to connect: $e");
        exit(1);
      });

      // //Connect standard in to the socket
      // stdin.listen(
      //     (data) => socket.write('${String.fromCharCodes(data).trim()}\n'));
    } catch (e) {
      log(e.toString());
    }
  }

  void dataHandler(data) async {
    log('New data');
    log('The data ${data.toString()}');
    log(data[data.length - 1]);

    // is new sections
    final lastelement = data[data.length - 1];

    if (lastelement == '}') {
      setState(() {
        imageData += data;
      });

      // final json = jsonDecode(data);
      final json = jsonDecode(imageData);

      final newMessage = {
        'id': json['id'] ?? '',
        'isMe': json['id'] == myChatId,
        'messageType': json['type'] ?? 'text',
        'message': json['type'] == 'text'
            ? json['message']
            : _getImageBinary(json['message'])
      };

      if (kDebugMode) {
        print('Json here $json');
      }

      setState(() {
        imageData = '';
        messages.add(newMessage);
      });
    } else {
      log('Not Image data yet');
      setState(() {
        imageData += data;
      });
    }

    // end new sections
    setState(() {});

    if (kDebugMode) {
      print(data);
    }

    setState(() {});
    // if (kDebugMode) {
    //   print(data);
    // }

    // log(String.fromCharCodes(data).trim());

    // final fromString = String.fromCharCodes(data);

    const fromString = '';

    if (fromString.contains('Welcome') == false) {
      // if (kDebugMode) {
      //   print('Printing local');
      //   print(fromString);
      //   print(String.fromCharCodes(data));
      // }

      List<String> wr = [];

      // if (kDebugMode) {
      //   print('Base 64');
      //   print(utf8.decode(data));
      //   print('The lsit');
      //   print(utf8.decode(data as List<int>));
      //   // ignore: unnecessary_cast
      //   final list = utf8.decode(data as List<int>);
      //   final parse = list.split(':');
      //   print(parse.length);
      //   print(parse[0]);
      //   print(parse[1]);
      //   print(parse[2].split(',')[0]);
      //   final word = parse[2].substring(1, parse[2].length - 1);
      //   final word2 = parse[2].split('[');
      //   wr = word2[1].split(',');
      //   print('this ${word2.length}, ${wr[wr.length - 1]}');
      //   print(parse);
      //   //final newData = await jsonDecode(list);
      //   print('This section though'); // [137,80,78,71,13,10,26
      //   print(list);
      //   // print(newData);
      //   //print(json.decode(utf8.decode(data)) as Map<String, dynamic>);
      //   //log();
      // }

      //final decodeEvent = jsonDecode(fromString);

      // json.decode(utf8.decode(data));

      // final newMessage = {
      //   'id': decodeEvent['id'] ?? '',
      //   'isMe': decodeEvent['id'] == myChatId,
      //   'messageType': decodeEvent['type'] ?? 'text',
      //   'message': decodeEvent['message']
      // };

      // log('Data Here ${data.toString()}');

      // log('Saw here $wr');

      // final newMessage = {
      //   'id': '',
      //   'isMe': false,
      //   'messageType': 'image',
      //   'message': Uint8List.fromList(wr.map(int.parse).toList()),
      // };

      // setState(() {
      //   messages.add(newMessage);
      // });
    }
  }

  void errorHandler(error, StackTrace trace) {
    log(error.toString());
  }

  void doneHandler() {
    log('It\'s done now with you.');
    if (kDebugMode) {
      print('done');
    }
    socket.destroy();
    exit(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    streamController.close();
    super.dispose();
  }

  Uint8List _getImageBinary(dynamicList) {
    List<int> intList =
        dynamicList.cast<int>().toList(); //This is the magical line.
    Uint8List data = Uint8List.fromList(intList);
    return data;
  }

  Future<void> pickAndSend() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    var tempDir = await getTemporaryDirectory();
    final outPutPath = '${tempDir.path}/result.png';

    if (image != null) {
      log(image.path);
      File? file = await Steganograph.encode(
        image: File(image.path),
        message: 'Some secret message from kosidev',
        outputFilePath: outPutPath,
      );
      final byte = await file?.readAsBytes();
      //final json = jsonEncode(byte);
      final json =
          jsonEncode({'id': myChatId, 'message': byte, 'type': 'image'});
      socket.add(json.codeUnits);

      final newMessage = {
        'id': myChatId,
        'isMe': true,
        'messageType': 'image',
        'message': byte,
      };

      setState(() {
        messages.add(newMessage);
      });
    }
  }

  Future<File> getFile({required Uint8List bytes}) async {
    final directory = await getTemporaryDirectory();
    final filepath = '${directory.path}/image.png';
    File imgFile = File(filepath);
    return await imgFile.writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context: context),
      child: Scaffold(
        backgroundColor: BrandColors.kMainBrandColor,
        body: Stack(
          children: [
            Positioned(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.13,
                      ),
                      ...messages.map((e) {
                        if (e['messageType'] == 'text') {
                          return ChatBubble(
                            message: e['message'],
                            isMe: e['isMe'],
                          );
                        } else {
                          return GestureDetector(
                            onTap: () async {
                              String? embeddedMessage =
                                  await Steganograph.decode(
                                image: await getFile(bytes: e['message']),
                              );

                              if (embeddedMessage != null) {
                                final snackBar = SnackBar(
                                  content: Text(embeddedMessage),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      // Some code to undo the change.
                                    },
                                  ),
                                );

                                // Find the ScaffoldMessenger in the widget tree
                                // and use it to show a SnackBar.
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            child: Image.memory(e['message']),
                          );
                        }
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100.0,
                decoration: const BoxDecoration(color: Colors.black),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40.0),
                      child: Image.asset(
                        'assets/images/placeholder.jpg',
                        width: 40.0,
                        height: 40.0,
                      ),
                    ),
                    const Align(
                      alignment: Alignment(0.0, 0.5),
                      child: Padding(
                        padding: EdgeInsets.only(left: 14.0),
                        child: Text(
                          'Russel Hue',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 13.0),
                      decoration: BoxDecoration(
                          color: BrandColors.kMainBrandColor,
                          borderRadius: BorderRadius.circular(12.4)),
                      child: const Text(
                        'Agree to Offer',
                        style: TextStyle(color: Colors.white, fontSize: 11.0),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Align(
                      alignment: Alignment(0.0, 0.7),
                      child: Icon(
                        Icons.bookmark_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Align(
                      alignment: Alignment(0.0, 0.7),
                      child: Icon(
                        Icons.phone_android_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50.0,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.05,
                ),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.0)),
                child: TextFormField(
                  maxLines: null,
                  controller: _controller,
                  cursorColor: BrandColors.kSecondaryColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    suffixIcon: Container(
                      width: 95.0,
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.emoji_emotions_outlined,
                            size: 20.0,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          GestureDetector(
                            onTap: () async {
                              await pickAndSend();
                            },
                            child: const Icon(
                              Ionicons.attach_outline,
                              size: 20.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              final message = {
                                'id': myChatId,
                                'message': _controller.text,
                                'type': 'text', // added now
                              };

                              final newMessage = {
                                'id': myChatId,
                                'isMe': true,
                                'messageType': 'text',
                                'message': _controller.text,
                              };

                              setState(() {
                                messages.add(newMessage);
                              });

                              //final di = JsonUtf8Encoder();
                              //channel.sink.add(jsonEncode(message));
                              //await streamController.done;
                              // streamController.add(jsonEncode(message));
                              //streamController.sink.add(jsonEncode(message));
                              //[87, 101, 108, 99, 111, 109, 101, 32, 116, 111, 32, 100, 97, 114, 116, 45, 99, 104, 97, 116, 33, 32, 84, 104, 101, 114, 101, 32, 97, 114, 101, 32, 48, 32, 111, 116, 104, 101, 114, 32, 99, 108, 105, 101, 110, 116, 115, 10]
                              // socket.write(di.convert(message));
                              // final siwar = di.convert(message);
                              // if (kDebugMode) {
                              //   print(String.fromCharCodes(siwar));
                              // }
                              //socket.write(jsonEncode(message).codeUnits);
                              socket.add(jsonEncode(message).codeUnits);
                              _controller.clear();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: BrandColors.kIconColors,
                                  borderRadius: BorderRadius.circular(9.0)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8.0,
                              ),
                              child: Transform.rotate(
                                angle: 5.8,
                                child: const Icon(
                                  Ionicons.send_outline,
                                  size: 13.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          )
                        ],
                      ),
                    ),
                    hintStyle:
                        const TextStyle(color: Colors.white, fontSize: 14.0),
                    hintText: "Write a new task",
                    contentPadding: const EdgeInsets.only(
                      left: 13.0,
                      top: 13.0,
                      bottom: 13.0,
                      right: 14.0,
                    ),
                  ),
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topRight: const Radius.circular(10.0),
              bottomLeft: const Radius.circular(10.0),
              bottomRight: Radius.circular(isMe ? 10.0 : 0.0),
              topLeft: Radius.circular(isMe ? 0.0 : 10.0)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 14.0,
        ),
        margin: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
