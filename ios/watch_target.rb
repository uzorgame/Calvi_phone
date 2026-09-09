# Додає в проєкт Xcode ціль годинникового застосунку.
#
# Скриптом, а не правкою `project.pbxproj` руками, і це не про зручність.
# Проєкт правиться на машині збірки, у репозиторії він лишається таким, яким
# був. Помилка тут валить одну збірку, а зіпсований у репозиторії файл проєкту
# зупинив би геть усі, включно з телефонними, і полагодити його без Xcode нема
# чим.
#
# Ідемпотентний: ціль, яка вже є, не створюється вдруге. Тому скрипт можна
# ганяти на кожній збірці, не питаючи, чи він уже відпрацював.
#
#   ruby ios/watch_target.rb
#
# Версію і номер збірки бере зі змінних середовища, бо вони мають збігатися з
# телефонними: Apple відхиляє пару, де годинник і телефон розходяться номерами.

require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT = File.join(ROOT, 'ios', 'Runner.xcodeproj')
NAME = 'CalviWatch'
PHONE_ID = 'com.calvi.calvi'
WATCH_ID = "#{PHONE_ID}.watchkitapp"

project = Xcodeproj::Project.open(PROJECT)

version = ENV['CALVI_VERSION'] || '1.0.0'
build = ENV['CALVI_BUILD'] || '1'

# Версія і номер проставляються щоразу, навіть коли ціль уже є.
#
# Номер збірки відомий пізніше за створення цілі: його дає TestFlight, і рахують
# його вже після того, як профілі лягли в проєкт. Тому скрипт викликається двічі,
# і другий раз має лишити по собі саме номер, а не «ціль уже є».
#
# Числа мусять збігатися з телефонними: пару, де годинник і телефон розходяться
# версією чи номером, Apple відхиляє цілком, і повідомлення про це приходить аж
# із завантаження.
def stamp(target, version, build)
  target.build_configurations.each do |config|
    config.build_settings['MARKETING_VERSION'] = version
    config.build_settings['CURRENT_PROJECT_VERSION'] = build
  end
end

if (already = project.targets.find { |t| t.name == NAME })
  stamp(already, version, build)
  project.save
  puts "#{NAME}: ціль уже є, оновив версію #{version} (#{build})"
  exit 0
end

phone = project.targets.find { |t| t.name == 'Runner' } or abort 'Немає цілі Runner'

# Ціль звичайним застосунком під watchOS, а не парою «застосунок плюс
# розширення»: з watchOS 7 годинниковий застосунок буває однією ціллю, і саме
# такий вигляд має бути в нового.
# Мова цілі swift, а не objc за замовчуванням: інакше в неї їдуть налаштування
# під міст із Objective-C, яких у чистому SwiftUI-застосунку немає.
watch = project.new_target(:application, NAME, :watchos, '10.0', nil, :swift)

group = project.new_group(NAME, "#{NAME}")
Dir.glob(File.join(ROOT, 'ios', NAME, '*.swift')).sort.each do |file|
  ref = group.new_reference(file)
  watch.add_file_references([ref])
end
group.new_reference(File.join(ROOT, 'ios', NAME, 'Info.plist'))

# Іконка. Без неї збірка складається, а завантаження в App Store Connect
# відхиляється перевіркою, і дізнаєшся про це аж наприкінці, після всіх хвилин
# збірки. Каталог іде ресурсом, а не просто файлом у групі.
icons = group.new_reference(File.join(ROOT, 'ios', NAME, 'Assets.xcassets'))
watch.add_resources([icons])

watch.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = WATCH_ID
  s['PRODUCT_NAME'] = 'Calvi'
  s['INFOPLIST_FILE'] = "#{NAME}/Info.plist"
  s['SDKROOT'] = 'watchos'
  # Платформи названі вголос, і це не дублювання SDKROOT.
  #
  # Проєкт Flutter на рівні проєкту ставить `SUPPORTED_PLATFORMS = iphoneos` у
  # Release і Profile, і ціль без власного значення його успадковує. Тоді для
  # Xcode годинниковий застосунок «підтримує iOS», і на архівуванні під iPhone
  # він збирає його як iOS-ціль: SDK підміняється на iphoneos, а компілятор
  # каталогу шукає в іконці годинника iOS-розміри, яких там немає. Саме звідси
  # «AppIcon did not have any applicable content» на обох форматах іконки
  # поспіль, і саме тому архів падав за шість секунд, ще до першого рядка
  # Swift.
  s['SUPPORTED_PLATFORMS'] = 'watchos watchsimulator'
  s['SUPPORTS_MACCATALYST'] = 'NO'
  # Четвірка це годинник. Без неї Xcode збирає під iPhone і падає на імпорті
  # WatchKit.
  s['TARGETED_DEVICE_FAMILY'] = '4'
  s['WATCHOS_DEPLOYMENT_TARGET'] = '10.0'
  s['SWIFT_VERSION'] = '5.0'
  s['MARKETING_VERSION'] = version
  s['CURRENT_PROJECT_VERSION'] = build
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['SKIP_INSTALL'] = 'YES'
  s['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'

  # Команда тільки якщо вона вже відома.
  #
  # Скрипт іде перед підписами, і в телефонної цілі команди на цей момент може
  # ще не бути. Порожній рядок, записаний сюди, не лишився б порожнім місцем: він
  # перекрив би значення рівня проєкту, яке підписи проставлять наступним кроком,
  # і збірка впала б на підписі саме годинникової цілі.
  team = phone.build_configurations.first.build_settings['DEVELOPMENT_TEAM']
  s['DEVELOPMENT_TEAM'] = team unless team.nil? || team.to_s.empty?
end

# Годинниковий застосунок їде всередині телефонного, у теці Watch. Без цієї фази
# він збереться і нікуди не потрапить, а Apple прийме ipa без нього мовчки.
embed = phone.new_copy_files_build_phase('Embed Watch Content')
embed.symbol_dst_subfolder_spec = :products_directory
embed.dst_path = '$(CONTENTS_FOLDER_PATH)/Watch'
embed.add_file_reference(watch.product_reference).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# Перед скриптом Flutter «Thin Binary», а не в кінці списку.
#
# Нова фаза стає останньою, тобто після скриптів. Скрипт «Thin Binary»
# оголошує весь Runner.app своїм результатом, а це копіювання пише всередину
# того самого Runner.app: Xcode бачив, що копіювання чекає на скрипт, а скрипт
# на вміст пакета, і зупиняв архів із «Cycle inside Runner». У проєктах, які
# робить сам Xcode, «Embed Watch Content» стоїть серед фаз копіювання, до
# будь-яких скриптів, і саме туди вона й переставляється.
phases = phone.build_phases
thin = phases.find { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
phases.move(embed, phases.index(thin)) if thin

# Телефонна ціль має чекати на годинникову, інакше вона копіює те, чого ще немає.
phone.add_dependency(watch)

project.save
puts "#{NAME}: ціль додано, #{WATCH_ID}, версія #{version} (#{build})"
