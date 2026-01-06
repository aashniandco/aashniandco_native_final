// lib/utils/helpers.dart

bool isNetworkError(String message) {
  return message.contains("SocketException") ||
      message.contains("ClientException") ||
      message.contains("Failed host lookup") ||
      message.contains("Connection refused");
}