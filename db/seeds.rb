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

%i[book music theater video_games anime comics movies misc tv].each do |type|
  500.times do
    src_name = RandomWord.phrases.next.titleize
    next if Source.exists?(name: src_name)
    Source.create(name: src_name, type => true)
  end
end

500.times do
  src_name = Forgery(:name).full_name
  next if Source.exists?(name: src_name)
  Source.create(name: src_name, celeb: true)
end

30000.times do
  c_name = Forgery(:name).full_name
  c_source = Source.order("Random()").first
  next if Character.where(source: c_source).where(name: c_name).exists?
  #do it by source_name so the stories are correctly updated
  Character.create(name: c_name, source_name: c_source.name)
end

30000.times do
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

Story.find_each do |story|
  num_chars = Forgery(:basic).number(at_least: 1, at_most: 6)
  chars = Character.order('Random()').first(num_chars)
  chars.each { |char| story.add_character(char) }
end

Story.find_each do |story|
  num_comments = Forgery(:basic).number(at_least: 1, at_most:5)
  usrs = User.order("Random()").first(num_comments)
  usrs.each do |usr|
    num_sent = Forgery(:basic).number(at_least: 1, at_most: 5)
    com_cont = Forgery(:lorem_ipsum).paragraph(sentences: num_sent, html: true, random: true)
    Comment.create(author: usr.name, content: com_cont, story_id: story.id)
  end
end

num_to_edit = (Comment.count / 3).to_i
# edit_message = "<p>Edit comment test: Alpha Beta Gamma.</p>"
Comment.order("Random()").limit(num_to_edit).find_each do |comment|
  edit_message = Forgery(:lorem_ipsum).paragraph(sentences: 5, html: true, random: true)
  comment.update(content: comment.content + edit_message)
end

Story.find_each do |story|
  num_comments = Forgery(:basic).number(at_least: 1, at_most:5)
  usrs = User.order("Random()").first(num_comments)
  usrs.each do |usr|
    com_cont = Forgery(:lorem_ipsum).paragraph(sentences: 5, html: true, random: true)
    Comment.create(author: usr.name, content: com_cont, story_id: story.id)
  end
end

=end

#Don't do it this way because it won't update the updated_at column
# sql = "UPDATE comments SET content = content || '<p>a</p>' " +
#       "WHERE id = 3852"
# ActiveRecord::Base.connection.execute(sql)
# Comment.where(id: 3737).update_all(content: '<p>test content</p>')

# num_to_edit = (Comment.count / 3).to_i
# Comment.order("Random()").limit(num_to_edit).find_each do |comment|
#   edit_message = Forgery(:lorem_ipsum).paragraph(sentences: 5, html: true, random: true)
#   comment.update(content: comment.content + edit_message)
# end


# Comment.delete_all
#
# Story.find_each do |story|
#   num_comments = Forgery(:basic).number(at_least: 1, at_most: 5)
#   usrs = User.order("Random()").first(num_comments)
#   usrs.each do |usr|
#     com_cont = Forgery(:lorem_ipsum).paragraph(sentences: 5, html: true, random: true)
#     Comment.create(author: usr.name, content: com_cont, story_id: story.id)
#   end
# end

# num_to_edit = (Comment.count / 3).to_i
# Comment.order("Random()").limit(num_to_edit).each do |comment|
#   edit_message = Forgery(:lorem_ipsum).paragraph(sentences: 5, html: true, random: true)
#   comment.update(content: comment.content + edit_message)
# end

# Tag.all.each do |tag|
#   tag.implied_tags.clear
# end

# Tag.all.each do |tag|
#   next unless Forgery(:basic).number(at_least: 1, at_most: 3) == 1
#   num_to_add = Forgery(:basic).number(at_least: 1, at_most: 3)
#   tags_to_add = Tag.order("Random()").first(num_to_add)
#   tag.add_implications(tags_to_add)
# end

Story.find_each do |story|
  num_tags = Forgery(:basic).number(at_least: 1, at_most: 4)
  Tag.order("Random()").first(num_tags).each do |tag|
    story.add_tag(tag)
  end
end
