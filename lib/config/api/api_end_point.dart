/*
 * @Author: Km Muzahid
 * @Date: 2026-01-07 12:29:06
 * @Email: km.muzahid@gmail.com
 */

// “Which course are you more excited to play?”
String _domain = 'http://10.10.26.185:5004';
// String _domain = 'https://humayon5004.binarybards.online';

class ApiEndPoint {
  ApiEndPoint._();
  static final ApiEndPoint instance = ApiEndPoint._();
  final String domain = _domain;
  final String baseUrl = '$_domain/api/v1';
  final String refreshTokenEndpoint = '/auth/refresh-token';
  final String createUser = '/users/create';
  final String verifyOtp = '/users/verify-otp';
  final String login = '/auth/login';
  final String resetPassword = '/auth/forgot-password-reset';
  final String getProfile = '/users/my-profile';
  final String setting = '/setting';

  final String resendOtp = '/auth/resend-otp';
  final String forgotPasswordOtp = '/auth/forgot-password-otp';

  final String changePassword = '/auth/change-password';

  // final String logout = '/auth/logout';

  final String deleteAccount = '/users/delete-my-account';

  //app based

  final String userPlayedCourse = '/compareCourse/user'; //get

  final String createPostData = '/postData/create-postData';

  final String post = '/post';
  final String userPost = '/post/user';

  //course
  final String coursePublic = '/course/public';
  final String courseUser = '/course/user';

  final String sharePost = '/post/share-post';

  final String createPostReport = '/postReport/create-post-report';

  final String likePost = '/comments/like';

  final String follow = '/follow/create-follow';

  final String updateMyProfile = '/users/update-my-profile';

  final String wishlistCourse = '/wishlistCourse/user';

  final String leaderboard = '/users/ranking';

  final String createFriend = '/friend/create-friend';

  final String rankData = '/compareCourse/rank-data';

  final String createCompareCourse = '/compareCourse/create';

  final String createWishlistCourse = '/wishlistCourse/create';

  final String reorderRank = '/compareCourse/custom-rank-data';

  final String courseMap = '/course/map';

  final String coursePost = '/course/post';

  final String postDetails = '/post';

  //
  final String allFriends = '/friend/all-friends';

  final String createTournament = '/tournament/create-tournament';

  final String getTournament = '/tournament/user';

  final String settingsOnOff = '/users/settings-on-off';

  final String support = '/support';

  //notification
  final String notification = '/notification'; //get

  final String notificationReadSingle = '/notification/read'; //patch

  final String notificationAllRead = '/notification/all-read'; //post

  final String acceptFriendRequest = '/friend/accept-friend-request'; //post

  final String rejectFriendRequest = '/friend/reject-friend-request'; //post

  final String faq = '/faq'; //get
}
