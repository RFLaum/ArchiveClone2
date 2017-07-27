module Taggable
  extend ActiveSupport::Concern

  def set_tags(tag_name_arr, clear_existing = false)
    tags = get_tags
    tags.clear if clear_existing
    tag_name_arr.each do |name|
      cooked_name = tag_class.tr_to_sql(name)
      unless tags.exists?(name: cooked_name)
        tags << tag_class.find_or_initialize_by(name: cooked_name)
      end
    end
  end

  def set_tag_string(tag_str, clear_existing = false)
    set_tags(tag_str.split(/,\s*/), clear_existing)
  end

  def tags_public
    get_tags.map(&:name).join(", ")
  end

  def tags_public=(new_tags_string)
    set_tag_string(new_tags_string, true)
  end

end
