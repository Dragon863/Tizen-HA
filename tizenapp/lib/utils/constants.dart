import 'package:home_assistant/home_assistant.dart';

final connectionUrl = 'https://hass.danieldb.uk';
final token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIyOWRhOTFkOWJlNzg0ZGM5ODdlOTFiOTkyYWNhM2UxNSIsImlhdCI6MTcwMTY0MTI2NCwiZXhwIjoyMDE3MDAxMjY0fQ.fKV8qGqYZYJLQI2JvVmX9ZtJWzxwQxY9RbKfGbFM1Vk';

final homeAssistant = HomeAssistant(
  baseUrl: connectionUrl,
  bearerToken: token,
);
