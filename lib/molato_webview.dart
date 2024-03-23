import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:molato/widgets/loading_indicator.dart';

class MolatoWebView extends StatefulWidget {
  const MolatoWebView({super.key});

  @override
  State<MolatoWebView> createState() => _MolatoWebViewState();
}

class _MolatoWebViewState extends State<MolatoWebView> {
  late bool isLoading;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    isLoading = true;

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   debugPrint('blocking navigation to ${request.url}');
            //   return NavigationDecision.prevent;
            // }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            debugPrint("$request");
          },
        ),
      )
      ..loadRequest(Uri.parse('https://molato.fun/'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    late WebViewWidget webViewWidget;

    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      debugPrint("android detected for webview");
      webViewWidget = WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams(
          controller: _webViewController.platform,
          displayWithHybridComposition: true,
          //   gestureRecognizers: {
          //   Factory<OneSequenceGestureRecognizer>(() {
          //     TapGestureRecognizer tabGestureRecognizer = TapGestureRecognizer();
          //     tabGestureRecognizer.onTapDown = (_) {
          //       FocusScope.of(context).unfocus();
          //     };
          //     return tabGestureRecognizer;
          //   }),
          //   // pinch-to-zoom 기능을 위해서
          //   Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
          // },
        ),
      );
    } else {
      debugPrint("Not android detected for webview");
      webViewWidget = WebViewWidget(
        controller: _webViewController,
        // gestureRecognizers: {
        //   Factory<OneSequenceGestureRecognizer>(() {
        //     TapGestureRecognizer tabGestureRecognizer = TapGestureRecognizer();
        //     tabGestureRecognizer.onTapDown = (_) {
        //       FocusScope.of(context).unfocus();
        //     };
        //     return tabGestureRecognizer;
        //   }),
        //   // pinch-to-zoom 기능을 위해서
        //   Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
        // },
      );
    }
    // T
    return Scaffold(
      body: SafeArea(
        child: isLoading ? const CircularLoadingIndicator() : webViewWidget
      ),
    );
  }
}
