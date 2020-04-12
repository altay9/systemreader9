import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReadScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('öyküleri oku'), backgroundColor: Colors.blue),

      body: WebView(
    initialUrl: new Uri.dataFromString("<iframe width=\"500\" height=\"280\" frameborder=\"0\" allowfullscreen=\"\" src=\"https://embed.wattpad.com/story/185512243\" ></iframe>", mimeType: "text/html").toString(),
    javascriptMode: JavascriptMode.unrestricted,
    onWebViewCreated: (WebViewController webViewController) {

    },
    ),
    );
  }
}