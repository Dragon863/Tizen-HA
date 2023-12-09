import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:tizen_interop/5.5/tizen.dart'; // as tizen55;

String? getProxyAddress() {
  return using((Arena arena) {
    final Pointer<connection_h> pConnection = arena();
    if (tizen.connection_create(pConnection) != 0) {
      return null;
    }
    final connection_h connection = pConnection.value;

    try {
      final Pointer<Int32> pType = arena();
      if (tizen.connection_get_type(connection, pType) != 0) {
        return null;
      }
      // The Ehternet type means that the device is connected to a phone
      // and thus can use a proxy network.
      if (pType.value != connection_type_e.CONNECTION_TYPE_ETHERNET) {
        return null;
      }

      final Pointer<Pointer<Char>> pProxy = arena();
      const int addressFamily =
          connection_address_family_e.CONNECTION_ADDRESS_FAMILY_IPV4;
      if (tizen.connection_get_proxy(connection, addressFamily, pProxy) != 0) {
        return null;
      }
      arena.using(pProxy.value, calloc.free);

      return pProxy.value.toDartString();
    } finally {
      tizen.connection_destroy(connection);
    }
  });
}

Future<String> requestHTTP(url, type, {headers, body}) async {
  final HttpClient httpClient = HttpClient();

  final String? proxyAddress = getProxyAddress();

  if (proxyAddress != null && proxyAddress != "") {
    httpClient.findProxy = (Uri uri) => 'PROXY $proxyAddress';
  }

  try {
    final IOClient http = IOClient(httpClient);
    Response response;
    if (type == 'GET') {
      response = await http.get(Uri.parse(url), headers: headers);
    } else {
      response = await http.post(Uri.parse(url), headers: headers, body: body);
    }
    if ([200, 201].contains(response.statusCode)) {
      return response.body;
    } else {
      print(response.body);
      return 'Error: Unsuccessful';
    }
  } catch (error) {
    return 'Error: $error';
  }
}
