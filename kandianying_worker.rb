require_relative 'bundle/bundler/setup'
require 'kandianying'
require 'json'
require 'config_env'
require 'aws-sdk'
require_relative 'models/english_cinema'
require_relative 'models/chinese_cinema'

ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")

LOCATION = {
  'kaohsiung' => { 'vieshow' => %w(01),
                   'ambassador' => %w(ec07626b-b382-474e-be39-ad45eac5cd1c) },
  'taichung' => { 'vieshow' => %w(02 03 11) },
  'tainan' => { 'vieshow' => %w(04 13),
                'ambassador' => %w(ace1fe19-3d7d-4b7c-8fbe-04897cbed08c) },
  'hsinchu' => { 'vieshow' => %w(05 12),
                 'ambassador' => %w(38897fa9-094f-4e63-9d6d-c52408438cb6) },
  'taipei' => { 'vieshow' => %w(06 08 09),
                'ambassador' => %w(84b87b82-b936-4a39-b91f-e88328d33b4e
                                   5c2d4697-7f54-4955-800c-7b3ad782582c
                                   453b2966-f7c2-44a9-b2eb-687493855d0e
                                   9383c5fa-b4f3-4ba8-ba7a-c25c7df95fd0) },
  'new taipei city' => {
    'vieshow' => %w(10),
    'ambassador' => %w(357633f4-36a4-428d-8ac8-dee3428a5919
                       3301d822-b385-4aa8-a9eb-aa59d58e95c9) },
  'toufen' => { 'vieshow' => %w(14) },
  'pingtung' => { 'ambassador' => %w(41aae717-4464-49f4-ac26-fec2d16acbd6) },
  'kinmen' => { 'ambassador' => %w(65db51ce-3ad5-48d8-8e32-7e872e56aa4a) }
}

LANGUAGES = %w(english chinese)

result_for_db = Hash.new do |lang, v|
  lang[v] = Hash.new do |city, va|
    city[va] = Hash.new { |key, val| key[val] = {} }
  end
end

LANGUAGES.each do |language|
  LOCATION.keys.each do |city|
    # break unless city == 'kaohsiung'
    LOCATION[city].each do |vie_amb, codes|
      if vie_amb == 'vieshow'
        codes.each do |code|
          cinema = HsinChuMovie::Vieshow.new(code, language)
          result_for_db[language][city]['vieshow'][code] = {
            'cinema_name' => cinema.cinema_name,
            'movie_names' => cinema.movie_names,
            'movie_table' => cinema.movie_table
          }
          puts "Done with #{cinema.cinema_name}"
          # sleep rand(0..3)
        end
      elsif vie_amb == 'ambassador'
        codes.each do |code|
          cinema = HsinChuMovie::Ambassador.new(code, language)
          result_for_db[language][city]['ambassador'][code] = {
            'cinema_name' => cinema.cinema_name,
            'movie_names' => cinema.movie_names,
            'movie_table' => cinema.movie_table
          }
          puts "Done with #{cinema.cinema_name}"
          # sleep rand(0..3)
        end
      end; end; end
end

en_cinema = EnglishCinema.new(
  date: Date.today.to_s, kaohsiung: result_for_db['english']['kaohsiung'],
  taichung: result_for_db['english']['taichung'],
  tainan: result_for_db['english']['tainan'],
  hsinchu: result_for_db['english']['hsinchu'],
  taipei: result_for_db['english']['taipei'],
  new_taipei_city: result_for_db['english']['new taipei city'],
  toufen: result_for_db['english']['toufen'],
  pingtung: result_for_db['english']['pingtung'],
  kinmen: result_for_db['english']['kinmen']
)
if en_cinema.save
  puts "Done for #{Date.today} with #{en_cinema.id}"
  sleep 5
  EnglishCinema.all.each { |e| e.destroy unless e.id == en_cinema.id }
  sleep 5
end
ch_cinema = ChineseCinema.new(
  date: Date.today.to_s, kaohsiung: result_for_db['chinese']['kaohsiung'],
  taichung: result_for_db['chinese']['taichung'],
  tainan: result_for_db['chinese']['tainan'],
  hsinchu: result_for_db['chinese']['hsinchu'],
  taipei: result_for_db['chinese']['taipei'],
  new_taipei_city: result_for_db['chinese']['new taipei city'],
  toufen: result_for_db['chinese']['toufen'],
  pingtung: result_for_db['chinese']['pingtung'],
  kinmen: result_for_db['chinese']['kinmen']
)
if ch_cinema.save
  puts "Done for #{Date.today} with #{ch_cinema.id}"
  sleep 5
  ChineseCinema.all.each { |e| e.destroy unless e.id == ch_cinema.id }
end
