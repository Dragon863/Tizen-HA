import 'dart:convert';

import 'proxy.dart';

class API {
  String token;
  String baseUrl;

  API(this.token, this.baseUrl);

  Future<Map> getState(String entityId) async {
    final result =
        await requestHTTP("$baseUrl/api/states/$entityId", "GET", headers: {
      'content-type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return jsonDecode(result);
  }

  Future<bool> callService(String domain, String service, String data) async {
    try {
      final result = await requestHTTP(
        "$baseUrl/api/services/$domain/$service",
        "POST",
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: data,
      );
      if (result.startsWith("Error:") == true) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map>> listEntities({type}) async {
    List<Map> returnedMap = [];
    final result = await requestHTTP(
      "$baseUrl/api/states",
      "GET",
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    for (var entity in jsonDecode(result)) {
      if (type == null) {
        final entityState = await getState(entity['entity_id']);
        print(entityState);
        if (entityState['attributes'].containsKey('friendly_name')) {
          returnedMap.add(
            {
              'entity_id': entity['entity_id'],
              'friendly_name': entityState['attributes']['friendly_name'],
              'attributes': entityState,
            },
          );
        } else {
          returnedMap.add(
            {
              'entity_id': entity['entity_id'],
              'friendly_name':
                  entity['entity_id'].toString().replaceAll('light.', ''),
              'attributes': entityState,
            },
          );
        }
      } else {
        if (entity['entity_id'].toString().startsWith(type) == true) {
          final entityState = await getState(entity['entity_id']);
          if (entityState['attributes'].containsKey('friendly_name')) {
            returnedMap.add(
              {
                'entity_id': entity['entity_id'],
                'friendly_name': entityState['attributes']['friendly_name'],
                'attributes': entityState,
              },
            );
          } else {
            returnedMap.add(
              {
                'entity_id': entity['entity_id'],
                'friendly_name':
                    entity['entity_id'].toString().replaceAll('light.', ''),
                'attributes': entityState,
              },
            );
          }
        } // Ignore entities not of the searched type
      }
    }
    returnedMap.add({
      'friendly_name': 'spacerItem',
    });
    return returnedMap;
  }
}
