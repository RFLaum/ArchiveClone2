# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# User.create(name: 'admin', email: 'zzedar+admin@gmail.com',
#             password: 'adminpassword', password_confirmation: 'adminpassword',
#             is_confirmed: true, adult: true, admin: true)
# Source.create(name: 'Foundation', book: true)
# Source.create(name: 'The Matrix', movies: true)
# Source.create(name: 'The Identity Matrix', book: true)



#re-enable these when uploading to heroku

=begin
100.times do
  u_name = Forgery('internet').user_name
  next if User.exists?(name: u_name)
  u_email = u_name + '@' + Forgery('internet').domain_name
  # u_hash = Digest::SHA1.hexdigest(Time.now.to_s.split('').shuffle.join)
  u_pass = Forgery('basic').password
  u_hash = Forgery('basic').encrypt(u_pass)
  User.create(
    name: u_name,
    email: u_email,
    password: u_pass,
    password_confirmation: u_pass,
    confirmation_hash: u_hash,
    is_confirmed: true,
    adult: Forgery(:basic).boolean
  )
end

100.times do
  t_name = RandomWord.adjs.next
  t_name.gsub!('_', '')
  next if Tag.exists?(name: t_name)
  Tag.create(name: t_name, adult: Forgery(:basic).boolean)
end

=end

500.times do
  s_name = RandomWord.phrases.next.titleize
  c_name = RandomWord.phrases.next.titleize
  s_author = User.order("Random()").first
  sum_length = Forgery(:basic).number(at_least: 5, at_most: 15)
  s_summary = Forgery(:lorem_ipsum).paragraph(sentences: sum_length, random: true)
  s_adult = Forgery(:basic).boolean
  s_text = ""
  Forgery(:basic).number(at_least: 20, at_most: 50).times do
    num_sent = Forgery(:basic).number(at_least: 10, at_most: 30)
    s_text += Forgery(:lorem_ipsum).paragraph(sentences: num_sent, html: true, random: true)
  end
  Story.create(
    title: s_name,
    author: s_author.name,
    chapter_title: c_name,
    body: s_text,
    summary: s_summary,
    adult_override: s_adult
  )
end
