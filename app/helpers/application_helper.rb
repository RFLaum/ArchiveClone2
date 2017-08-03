module ApplicationHelper
  def generate_hash
    Digest::SHA1.hexdigest(Time.now.to_s.split('').shuffle.join)
  end

  def name_link(model)
    if model.attributes.key?("name")
      link_to model.name, model
    elsif model.attributes.key?("title")
      link_to model.title, model
    else
      raise ArgumentError, "no name field"
    end
  end
end
