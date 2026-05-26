class ApiConstants {
  static const String baseUrl = 'http://192.168.0.106:8080/api/v1';

  // WebSocket (STOMP) — strip /api/v1 and switch scheme
  static const String wsUrl = 'ws://192.168.0.106:8080/ws';
  // STOMP destinations
  static String chatTopic(String inquiryId) => '/topic/chat/$inquiryId';
  static const String userQueue = '/user/queue/messages';
  static String chatSendDest(String inquiryId) => '/app/chat/$inquiryId/send';

  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // Users
  static const String me = '/users/me';
  static const String updateProfile = '/users/me';
  static const String kyc = '/users/me/kyc';

  // Properties
  static const String properties = '/properties';
  static const String myProperties = '/properties/my';
  static const String shortlist = '/properties/shortlist';
  static String propertyById(String id) => '/properties/$id';
  static String shortlistProperty(String id) => '/properties/$id/shortlist';
  static String boostProperty(String id) => '/properties/$id/boost';

  // Areas
  static const String areas = '/areas';

  // Subscriptions
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscriptionPurchase = '/subscriptions/purchase';
  static const String mySubscription = '/subscriptions/me';

  // Inquiries
  static const String inquiries = '/inquiries';
  static const String ownerInquiries = '/inquiries/owner';
  static const String tenantInquiries = '/inquiries/tenant';
  static String acceptInquiry(String id) => '/inquiries/$id/accept';
  static String rejectInquiry(String id) => '/inquiries/$id/reject';

  // Chats
  static const String chats = '/chats';
  static String chatMessages(String inquiryId) => '/chats/$inquiryId/messages';
  static String chatUnread(String inquiryId) => '/chats/$inquiryId/unread';

  // Leases
  static const String leases = '/leases';
  static String leaseById(String id) => '/leases/$id';
  static String signLease(String id) => '/leases/$id/sign';
  static String leasePayments(String id) => '/leases/$id/payments';
  static String terminateLease(String id) => '/leases/$id/terminate';

  // Notifications
  static const String notifications = '/notifications';

  // File upload
  static const String uploadFile = '/files/upload';
}
