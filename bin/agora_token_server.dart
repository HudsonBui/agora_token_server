import 'dart:io';

import 'package:agora_token_server/utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:agora_token_service/agora_token_service.dart';
// import 'package:agora_token_service/rtm_token_builder.dart';

void main(List<String> arguments) async {
  final router = Router();

  router.get('/rtcToken', (Request request) {
    final channelName = request.url.queryParameters['channelName'];
    final uid = request.url.queryParameters['uid'] ?? '0';

    if (channelName == null) {
      return Response.badRequest(body: 'channelName is required');
    }

    final token = generateRtcToken(appId, appCertificate, channelName, uid);
    return Response.ok(token);
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  // final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}

//This token will be only valid in 3 hours
String generateRtcToken(
    String appId, String appCertificate, String channelName, String uid) {
  // Implement token generation logic using Agora's token generation algorithm
  final agoraTokenBuilder = RtcTokenBuilder.build(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channelName,
      uid: uid,
      role: RtcRole.publisher,
      expireTimestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10800);
  return agoraTokenBuilder;
}

// //This token will be only valid in 3 hours
// String generateRtmToken(
//     String appId, String appCertificate, String channelName, String uid) {
//   // Implement token generation logic using Agora's token generation algorithm
//   final agoraTokenBuilder = RtmTokenBuilder.build(
//       appId: appId,
//       appCertificate: appCertificate,
//       channelName: channelName,
//       uid: uid,
//       role: RtcRole.publisher,
//       expireTimestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10800);
//   return agoraTokenBuilder;
// }