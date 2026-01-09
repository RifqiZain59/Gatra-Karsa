import 'package:get/get.dart';

import '../modules/daftarsave/bindings/daftarsave_binding.dart';
import '../modules/daftarsave/views/daftarsave_view.dart';
import '../modules/detail_wayang/bindings/detail_wayang_binding.dart';
import '../modules/detail_wayang/views/detail_wayang_view.dart';
import '../modules/detaildalang/bindings/detaildalang_binding.dart';
import '../modules/detaildalang/views/detaildalang_view.dart';
import '../modules/detailevent/bindings/detailevent_binding.dart';
import '../modules/detailevent/views/detailevent_view.dart';
import '../modules/detailkisah/bindings/detailkisah_binding.dart';
import '../modules/detailkisah/views/detailkisah_view.dart';
import '../modules/detailmuseum/bindings/detailmuseum_binding.dart';
import '../modules/detailmuseum/views/detailmuseum_view.dart';
import '../modules/deteksi/bindings/deteksi_binding.dart';
import '../modules/deteksi/views/deteksi_view.dart';
import '../modules/editprofile/bindings/editprofile_binding.dart';
import '../modules/editprofile/views/editprofile_view.dart';
import '../modules/event/bindings/event_binding.dart';
import '../modules/event/views/event_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/gantikatasandi/bindings/gantikatasandi_binding.dart';
import '../modules/gantikatasandi/views/gantikatasandi_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/kebijakanprivasi/bindings/kebijakanprivasi_binding.dart';
import '../modules/kebijakanprivasi/views/kebijakanprivasi_view.dart';
import '../modules/ketentuanpemakaian/bindings/ketentuanpemakaian_binding.dart';
import '../modules/ketentuanpemakaian/views/ketentuanpemakaian_view.dart';
import '../modules/kisah/bindings/kisah_binding.dart';
import '../modules/kisah/views/kisah_view.dart';
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/lupapassword/bindings/lupapassword_binding.dart';
import '../modules/lupapassword/views/lupapassword_view.dart';
import '../modules/museum/bindings/museum_binding.dart';
import '../modules/museum/views/museum_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/quiz/bindings/quiz_binding.dart';
import '../modules/quiz/views/quiz_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/riwayatlogin/bindings/riwayatlogin_binding.dart';
import '../modules/riwayatlogin/views/riwayatlogin_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/tentangkami/bindings/tentangkami_binding.dart';
import '../modules/tentangkami/views/tentangkami_view.dart';
import '../modules/tokoh/bindings/tokoh_binding.dart';
import '../modules/tokoh/views/tokoh_view.dart';
import '../modules/ulasan/bindings/ulasan_binding.dart';
import '../modules/ulasan/views/ulasan_view.dart';
import '../modules/verification/bindings/verification_binding.dart';
import '../modules/verification/views/verification_view.dart';
import '../modules/video/bindings/video_binding.dart';
import '../modules/video/views/video_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.TENTANGKAMI,
      page: () => const TentangkamiView(),
      binding: TentangkamiBinding(),
    ),
    GetPage(
      name: _Paths.DETEKSI,
      page: () => const DeteksiView(),
      binding: DeteksiBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO,
      page: () => const VideoView(),
      binding: VideoBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_WAYANG,
      page: () => const DetailWayangView(),
      binding: DetailWayangBinding(),
    ),
    GetPage(
      name: _Paths.QUIZ,
      page: () => const QuizView(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: _Paths.LEADERBOARD,
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
    ),
    GetPage(
      name: _Paths.MUSEUM,
      page: () => const MuseumView(),
      binding: MuseumBinding(),
    ),
    GetPage(
      name: _Paths.TOKOH,
      page: () => const TokohView(),
      binding: TokohBinding(),
    ),
    GetPage(
      name: _Paths.KISAH,
      page: () => const KisahView(),
      binding: KisahBinding(),
    ),
    GetPage(
      name: _Paths.EVENT,
      page: () => const EventView(),
      binding: EventBinding(),
    ),
    GetPage(
      name: _Paths.DETAILDALANG,
      page: () => const DetaildalangView(),
      binding: DetaildalangBinding(),
    ),
    GetPage(
      name: _Paths.DETAILMUSEUM,
      page: () => const DetailmuseumView(),
      binding: DetailmuseumBinding(),
    ),
    GetPage(
      name: _Paths.DETAILEVENT,
      page: () => const DetaileventView(),
      binding: DetaileventBinding(),
    ),
    GetPage(
      name: _Paths.DETAILKISAH,
      page: () => const DetailkisahView(),
      binding: DetailkisahBinding(),
    ),
    GetPage(
      name: _Paths.EDITPROFILE,
      page: () => const EditprofileView(),
      binding: EditprofileBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.RIWAYATLOGIN,
      page: () => const RiwayatloginView(),
      binding: RiwayatloginBinding(),
    ),
    GetPage(
      name: _Paths.KETENTUANPEMAKAIAN,
      page: () => const KetentuanpemakaianView(),
      binding: KetentuanpemakaianBinding(),
    ),
    GetPage(
      name: _Paths.KEBIJAKANPRIVASI,
      page: () => const KebijakanprivasiView(),
      binding: KebijakanprivasiBinding(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: _Paths.VERIFICATION,
      page: () => const VerificationView(),
      binding: VerificationBinding(),
    ),
    GetPage(
      name: _Paths.GANTIKATASANDI,
      page: () => const GantikatasandiView(),
      binding: GantikatasandiBinding(),
    ),
    GetPage(
      name: _Paths.LUPAPASSWORD,
      page: () => const LupapasswordView(),
      binding: LupapasswordBinding(),
    ),
    GetPage(
      name: _Paths.DAFTARSAVE,
      page: () => const DaftarsaveView(),
      binding: DaftarsaveBinding(),
    ),
    GetPage(
      name: _Paths.ULASAN,
      page: () => const UlasanView(),
      binding: UlasanBinding(),
    ),
  ];
}
