module ApplicationHelper
  def generate_hash
    Digest::SHA1.hexdigest(Time.now.to_s.split('').shuffle.join)
  end
end
