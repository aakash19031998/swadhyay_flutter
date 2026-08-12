/// Central registry of asset paths so no widget hardcodes a raw path string.
class AppAssets {
  const AppAssets._();

  static const String _images = 'assets/images';

  static const String appIcon = '$_images/app_icon.png';
  static const String splashGif = '$_images/splash.gif';
  static const String logoHk = '$_images/logo_hk.svg';
  static const String homeBackground = '$_images/home_screen_background.svg';
}
