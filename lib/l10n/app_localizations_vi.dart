// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'KJ';

  @override
  String get home => 'Trang chủ';

  @override
  String get lessons => 'Bài học';

  @override
  String get quiz => 'Quiz';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get profileSettings => 'Cài đặt hồ sơ';

  @override
  String get adminPanel => 'Trang quản trị';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get accountSettings => 'Tài khoản';

  @override
  String get dataManagement => 'Dữ liệu';

  @override
  String get supportInfo => 'Hỗ trợ & thông tin';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get signOutSubtitle => 'Thoát tài khoản an toàn';

  @override
  String get clearLocalProgress => 'Xóa tiến độ cục bộ';

  @override
  String get clearLocalProgressSubtitle => 'Đặt lại streak và lịch sử cục bộ';

  @override
  String get progressDataCleared => 'Đã xóa dữ liệu tiến độ';

  @override
  String get appVersion => 'Phiên bản ứng dụng';

  @override
  String currentlyVersion(String version) {
    return 'Hiện tại v$version';
  }

  @override
  String get donate => 'Ủng hộ';

  @override
  String get donateSubtitle => 'Ủng hộ nhà phát triển';

  @override
  String get jlptLearner => 'Người học JLPT';

  @override
  String get notLoggedIn => 'Chưa đăng nhập';

  @override
  String get welcomeBack => 'Chào mừng trở lại';

  @override
  String get signInToContinue => 'Đăng nhập để tiếp tục hành trình Kanji';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get passwordMin => 'Mật khẩu (tối thiểu 6 ký tự)';

  @override
  String get validEmail => 'Nhập email hợp lệ';

  @override
  String get minCharacters => 'Tối thiểu 6 ký tự';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get startJourney => 'Bắt đầu hành trình học Kanji';

  @override
  String get noAccount => 'Chưa có tài khoản?';

  @override
  String get hasAccount => 'Đã có tài khoản?';

  @override
  String get defaultUser => 'Người dùng';

  @override
  String okaeriUser(String name) {
    return 'Okaeri, $name';
  }

  @override
  String get keepItUp => 'Tiếp tục nhé!';

  @override
  String get streakDaysUpper => 'NGÀY';

  @override
  String get dailyProgress => 'Tiến độ hôm nay';

  @override
  String get dailyProgressUpper => 'TIẾN ĐỘ HÔM NAY';

  @override
  String kanjiMastered(int mastered, int goal) {
    return '$mastered/$goal Kanji đã thành thạo';
  }

  @override
  String get continueLearningBadge => 'N5 • TUẦN 2';

  @override
  String get essentialVerbs => 'Động từ thiết yếu';

  @override
  String get continueLearningSubtitle =>
      'Hôm nay tập trung vào bộ thủ chỉ chuyển động và phương hướng.';

  @override
  String get continueText => 'Tiếp tục';

  @override
  String get recommendedForYou => 'Gợi ý cho bạn';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get communityRankings => 'Bảng xếp hạng cộng đồng';

  @override
  String get quizComingSoon => 'Màn hình quiz sắp ra mắt';

  @override
  String get profileComingSoon => 'Màn hình hồ sơ sắp ra mắt';

  @override
  String errorLoadingData(String error) {
    return 'Lỗi tải dữ liệu: $error';
  }

  @override
  String get dashboard => 'Thống kê';

  @override
  String get currentStreak => 'Streak hiện tại';

  @override
  String get longestStreak => 'Streak dài nhất';

  @override
  String get days => 'Ngày';

  @override
  String get quizPerformance => 'Hiệu suất quiz';

  @override
  String totalQuizzes(int count) {
    return '$count bài quiz';
  }

  @override
  String get recentStudyDays => 'Ngày học gần đây';

  @override
  String get noStudyDays => 'Chưa có ngày học. Bắt đầu học thôi!';

  @override
  String get globalRankings => 'Bảng xếp hạng';

  @override
  String get quizzes => 'Bài quiz';

  @override
  String get pointsShort => 'điểm';

  @override
  String get lessonsSubtitle => 'Chọn kỹ năng và cấp độ phù hợp với buổi học.';

  @override
  String get jlptKanji => 'Kanji JLPT';

  @override
  String get grammar => 'Ngữ pháp';

  @override
  String get vocabulary => 'Từ vựng';

  @override
  String get radicals => 'Bộ thủ';

  @override
  String get kanjiSubtitle => 'Học Kanji theo cấp độ JLPT.';

  @override
  String get grammarSubtitle => 'Luyện mẫu câu bằng quiz và flashcard.';

  @override
  String get vocabularySubtitle =>
      'Học từ với quiz, flashcard và trò ghép cặp.';

  @override
  String get radicalsSubtitle => 'Xem bộ thủ theo số nét.';

  @override
  String levelStudy(String level) {
    return 'Học cấp độ $level';
  }

  @override
  String essentialKanji(int count) {
    return '$count Kanji thiết yếu';
  }

  @override
  String grammarPoints(int count) {
    return '$count điểm ngữ pháp';
  }

  @override
  String vocabularyWords(int count) {
    return '$count từ vựng';
  }

  @override
  String get grammarPractice => 'Luyện ngữ pháp';

  @override
  String get grammarPracticeSubtitle => 'Quiz và flashcard cho N5, N4, N3';

  @override
  String get vocabularyPractice => 'Luyện từ vựng';

  @override
  String get vocabularyPracticeSubtitle => 'Quiz, flashcard và trò ghép cặp';

  @override
  String strokeCount(int count) {
    return '$count nét';
  }

  @override
  String strokeCountPlural(int count) {
    return '$count nét';
  }

  @override
  String get adminOverview => 'Tổng quan';

  @override
  String get adminUsers => 'Người dùng';

  @override
  String get adminQuizResults => 'Kết quả quiz';

  @override
  String get totalUsers => 'Tổng user';

  @override
  String get activeUsers => 'Đang hoạt động';

  @override
  String get blockedUsers => 'Bị khóa';

  @override
  String get totalXp => 'Tổng XP';

  @override
  String get totalPoints => 'Tổng điểm';

  @override
  String get searchUsers => 'Tìm user';

  @override
  String get all => 'Tất cả';

  @override
  String get active => 'Hoạt động';

  @override
  String get blocked => 'Bị khóa';

  @override
  String get user => 'User';

  @override
  String get admin => 'Admin';

  @override
  String get role => 'Vai trò';

  @override
  String get status => 'Trạng thái';

  @override
  String get block => 'Khóa';

  @override
  String get unblock => 'Mở khóa';

  @override
  String get delete => 'Xóa';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get deleteUser => 'Xóa user';

  @override
  String get deleteQuizResult => 'Xóa kết quả quiz';

  @override
  String get confirmDeleteUser => 'Xóa user này và toàn bộ kết quả quiz?';

  @override
  String get confirmDeleteQuizResult => 'Xóa kết quả quiz này?';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';
}
