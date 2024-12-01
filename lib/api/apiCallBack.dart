/*
* Api callback handler
* */
abstract class ApiCallBacks {
  // void onSuccess(dynamic object,String strMsg,String order,String requestCode);
  void onSuccess(dynamic object, String strMsg, String requestCode);

  void onError(String errorMsg, String requestCode, String statusCode);

  void onConnectionError(String error, String requestCode);
}
