require 'package'

class Vivaldi < Package
  description 'Vivaldi is a new browser that blocks unwanted ads, protects you from trackers, and puts you in control with unique built-in features.'
  homepage 'https://vivaldi.com/'
  version '5.4.2753.51-1'
  compatibility 'aarch64,armv7l,x86_64'
  license 'Vivaldi'

  no_compile_needed

  depends_on 'cras'
  depends_on 'gtk3'
  depends_on 'gsettings_desktop_schemas'
  depends_on 'libx264'
  depends_on 'xdg_base'
  depends_on 'xdg_utils'
  depends_on 'sommelier'

  case ARCH
  when 'aarch64', 'armv7l'
    arch = 'armhf'
    source_sha256 'fd2155422defe0c6e0130526ba68b6b929ea6cb6da7565cce884f2179b7acd5d'
  when 'x86_64'
    arch = 'amd64'
    source_sha256 '59e851996bb35eae1406ea802d46d3dc386df21ed70c51e7be3a1f905373e0a4'
  end

  source_url "https://downloads.vivaldi.com/stable/vivaldi-stable_#{version}_#{arch}.deb"

  def self.patch
    # ERROR: ld.so: object '/home/chronos/user/.local/lib/vivaldi/media-codecs-89.0.4389.82/libffmpeg.so' from LD_PRELOAD cannot be preloaded
    system 'sed', '-i', "s:$HOME/.local/lib/vivaldi/:#{CREW_PREFIX}/share/vivaldi/:g", './opt/vivaldi/vivaldi'
    system 'sed', '-i', "s:$HOME/.local/lib/vivaldi/:#{CREW_PREFIX}/share/vivaldi/:g", './opt/vivaldi/update-ffmpeg'
    system 'sed', '-i', 's:/usr/bin/::g', './usr/share/applications/vivaldi-stable.desktop'
  end

  def self.install
    FileUtils.mkdir_p CREW_DEST_PREFIX

    FileUtils.mv './etc/', CREW_DEST_PREFIX
    FileUtils.mv Dir['./usr/*'], CREW_DEST_PREFIX
    FileUtils.mv './opt/vivaldi/', "#{CREW_DEST_PREFIX}/share/"

    FileUtils.ln_sf "#{CREW_PREFIX}/share/vivaldi/vivaldi", "#{CREW_DEST_PREFIX}/bin/vivaldi-stable"
    FileUtils.ln_sf "#{CREW_PREFIX}/share/vivaldi/vivaldi", "#{CREW_DEST_PREFIX}/bin/vivaldi"

    # Add icons for use with crew-launcher
    icon_base_path = "#{CREW_DEST_PREFIX}/share/icons/hicolor"
    FileUtils.mkdir_p icon_base_path
    Dir["#{CREW_DEST_PREFIX}/share/vivaldi/product_logo_*.png"].each do |filename|
      logo = File.basename(filename)
      size = File.basename(logo[13, 7], '.png')
      dims = "#{size}x#{size}"
      FileUtils.mkdir_p "#{icon_base_path}/#{dims}/apps"
      FileUtils.mv filename, "#{icon_base_path}/#{dims}/apps/vivaldi.png"
    end
  end

  def self.postinstall
    system "#{CREW_PREFIX}/share/vivaldi/update-ffmpeg", '--user'
  end

  def self.remove
    Dir.chdir(CREW_PREFIX) do
      FileUtils.rm_rf ["#{HOME}/.local/lib/vivaldi", '.config/vivaldi', '.cache/vivaldi', '.config/share/.vivaldi_reporting_data']
    end
  end
end
