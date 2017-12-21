#should only access through my defined methods, not through .new, .create,
#.find, etc.
class BannedAddress < ApplicationRecord
  include Updateable
  self.primary_key = :email

  def self.add_email(address)
    find_or_create_by(email: clean_email(address))
  end

  def self.remove_email(address)
    address = clean_email(address)
    find(address).destroy if exists?(address)
  end

  def self.is_banned?(email)
    # exists?(clean_email(email))
    self.where("email ~* ?", make_regex_str(clean_email(email))).exists?
  end

  def self.destroy_users_matching(email)
    User.find_email_by_regex(make_regex_str(email)).each(&:destroy)
  end

  def self.name_field
    :email
  end

  #assumes raw_address is a valid email address
  def self.clean_email(raw_address)
    raw_address = raw_address.strip
    raw_address = raw_address.downcase
    raw_address.sub(/\+[^@]*@/, '@')
    # at_loc = raw_address.index('@')
    # plus_loc = raw_address.index('+')
    # first_end = (plus_loc && plus_loc < at_loc) ? plus_loc : at_loc
    # raw_address[0...first_end] + raw_address[at_loc..-1]
  end

  #assumes that raw_address is already downcased, stripped of whitespace, etc.
  def self.make_regex_str(raw_address)
    # raw_address.sub(/^([^\+@]+)((\+[^@]*)?@)(.*$)/, '$1(\)')
    first_part = raw_address[0...raw_address.index(/[@\+]/)]
    second_part = raw_address[raw_address.index('@')..-1]
    if ['gmail.com', 'googlemail.com'].include? second_part
      second_part = 'g(oogle)?mail.com'
      first_part = first_part.remove('.')
    end
    first_part + '(\+[^@]*)?' + second_part
  end

  private_class_method :clean_email, :make_regex_str
end
