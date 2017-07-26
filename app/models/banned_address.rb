#should only access through my defined methods, not through .new, .create,
#.find, etc.
class BannedAddress < ApplicationRecord
  self.primary_key = :email

  def self.add_email(address)
    find_or_create_by(email: clean_email(address))
  end

  def self.remove_email(address)
    address = clean_email(address)
    find(address).destroy if exists?(address)
  end

  def self.is_banned?(email)
    exists?(clean_email(email))
  end

  #assumes raw_address is a valid email address
  def self.clean_email(raw_address)
    raw_address = raw_address.downcase
    at_loc = raw_address.index('@')
    plus_loc = raw_address.index('+')
    first_end = (plus_loc && plus_loc < at_loc) ? plus_loc : at_loc
    raw_address[0...first_end] + raw_address[at_loc..-1]
  end

  private_class_method :clean_email
end
