# Додає в проєкт Xcode ціль живої активності: острівець на iPhone.
#
# Скриптом, а не правкою `project.pbxproj` руками, з тієї самої причини, що й
# годинник у сусідньому `watch_target.rb`: проєкт правиться на машині збірки, у
# репозиторії він лишається таким, яким був. Помилка тут валить одну збірку, а
# зіпсований у репозиторії файл проєкту зупинив би геть усі, і полагодити його
# без Xcode нема чим.
#
# Ідемпотентний: ціль, яка вже є, не створюється вдруге, тільки оновлює версію.
#
#   ruby ios/live_target.rb
#
# Що саме додається:
#
#   * ціль `CalviLive`, розширення WidgetKit під iOS, всередині телефонного
#     застосунку;
#   * файл `CalviLiveAttributes.swift` **в обидві цілі**, і в розширення, і в
#     сам застосунок: тип активності мусить бути один на двох, інакше вони
#     мовчки розійдуться у форматі й оновлення перестануть доходити.

require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT = File.join(ROOT, 'ios', 'Runner.xcodeproj')
NAME = 'CalviLive'
PHONE_ID = 'com.calvi.calvi'
LIVE_ID = "#{PHONE_ID}.live"

# Живі активності зʼявились в iOS 16.1, а острівець того самого року. Нижче
# піднімати нема сенсу: система просто не має чого показати.
MIN_IOS = '16.2'

project = Xcodeproj::Project.open(PROJECT)

version = ENV['CALVI_VERSION'] || '1.0.0'
build = ENV['CALVI_BUILD'] || '1'

def stamp(target, version, build)
  target.build_configurations.each do |config|
    config.build_settings['MARKETING_VERSION'] = version
    config.build_settings['CURRENT_PROJECT_VERSION'] = build
  end
end

phone = project.targets.find { |t| t.name == 'Runner' } or abort 'Немає цілі Runner'
team = phone.build_configurations.first.build_settings['DEVELOPMENT_TEAM']

attributes = File.join(ROOT, 'ios', NAME, 'CalviLiveAttributes.swift')

live = project.targets.find { |t| t.name == NAME }
if live
  stamp(live, version, build)
  puts "#{NAME}: ціль уже є, оновив версію #{version} (#{build})"
else
  live = project.new_target(:app_extension, NAME, :ios, MIN_IOS, nil, :swift)

  group = project.new_group(NAME, NAME.to_s)
  Dir.glob(File.join(ROOT, 'ios', NAME, '*.swift')).sort.each do |file|
    ref = group.new_reference(file)
    live.add_file_references([ref])

    # Тип активності компілюється і в застосунок: він її заводить і оновлює.
    phone.add_file_references([ref]) if file == attributes
  end
  group.new_reference(File.join(ROOT, 'ios', NAME, 'Info.plist'))

  # Каталог кольорів розширення.
  #
  # Без нього розширення не має власного кольору взагалі, і там, де система
  # фарбує щось сама (обведення острівця, тло віджета, будь-яка типова відтінка
  # всередині нашого вмісту), вона бере свій відтінок замість нашого. Це та сама
  # діра, що була в андроїдному сповіщенні, де через відсутній колір система
  # брала його з оформлення телефона.
  assets = File.join(ROOT, 'ios', NAME, 'Assets.xcassets')
  live.add_resources([group.new_reference(assets)])

  stamp(live, version, build)
  live.build_configurations.each do |config|
    s = config.build_settings
    s['PRODUCT_BUNDLE_IDENTIFIER'] = LIVE_ID
    s['PRODUCT_NAME'] = NAME
    s['INFOPLIST_FILE'] = "#{NAME}/Info.plist"
    s['IPHONEOS_DEPLOYMENT_TARGET'] = MIN_IOS
    s['SUPPORTED_PLATFORMS'] = 'iphoneos iphonesimulator'
    s['TARGETED_DEVICE_FAMILY'] = '1'
    s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
    s['SWIFT_VERSION'] = '5.0'
    s['DEVELOPMENT_TEAM'] = team if team
    s['CODE_SIGN_STYLE'] = 'Manual'
    s['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks'
    # Імена кольорів із каталогу вище. Без цих двох рядків каталог лежить у
    # пакеті, а система про нього не знає і далі фарбує своїм.
    s['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
    s['ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME'] = 'WidgetBackground'
    s['GENERATE_INFOPLIST_FILE'] = 'NO'
  end

  # Розширення їде всередині телефонного застосунку, у теці PlugIns, і рівно
  # так, як це робить Xcode, коли додає ціль віджета сам.
  embed = phone.new_copy_files_build_phase('Embed Live Activity')
  embed.symbol_dst_subfolder_spec = :plug_ins
  embed.add_file_reference(live.product_reference).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

  # Перед скриптом Flutter «Thin Binary», з тієї самої причини, що й у
  # годинника: скрипт оголошує весь Runner.app своїм результатом, а копіювання
  # пише всередину того самого пакета, і Xcode зупиняє архів із «Cycle inside
  # Runner».
  phases = phone.build_phases
  thin = phases.find { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
  phases.move(embed, phases.index(thin)) if thin

  phone.add_dependency(live)

  puts "#{NAME}: ціль додано, #{LIVE_ID}, версія #{version} (#{build})"
end

project.save
