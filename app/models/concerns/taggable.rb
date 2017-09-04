module Taggable
  extend ActiveSupport::Concern

  def add_tag(tag)
    unless get_tags.include?(tag)
      get_tags << tag
      tag.implied_tags.each do |child|
        add_tag(child)
      end
    end
  end

  def set_tags_directly(tag_arr, clear_existing = false)
    get_tags.clear if clear_existing
    tag_arr.each do |tag|
      add_tag(tag)
    end
  end

  def set_tags(tag_name_arr, clear_existing = false)
    # tag_name_arr = tag_name_arr.dup
    # tags = get_tags
    # tags.clear if clear_existing
    #can't use each because we're modifying the array as we iterate
    # tag_name_arr.each do |name|
    # until tag_name_arr.empty?
    #   cooked_name = tag_class.tr_to_sql(tag_name_arr.pop)
    #   unless tags.exists?(name: cooked_name)
    #     this_tag = tag_class.find_or_initialize_by(name: cooked_name)
    #     tags << this_tag
    #     tag_name_arr.concat(this_tag.implied_tags.map(&:name))
    #   end
    # end
    # tag_name_arr.each do |name|
    #   cooked_name = tag_class.tr_to_sql(name)
    #   tag = tag_class.find_or_initialize_by(name: cooked_name)
    #   add_tag(tag)
    # end
    tag_arr = tag_name_arr.map do |name|
      cooked_name = tag_class.tr_to_sql(name)
      tag_class.find_or_initialize_by(name: cooked_name)
    end
    set_tags_directly(tag_arr, clear_existing)
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

  def tags_add=(new_tags_string)
    set_tag_string(new_tags_string)
  end

  def deleted_tags=(tags_to_delete)
    # objs = get_tags.find(tags_to_delete)
    # objs.each do |tag|
    #   tag.implying_tags.each do |implier|
    #     if get_tags.include?(implier) && !obs.include?(implier)
    #
    #     end
    #   end
    # end

    # logger.debug "del tags test"
    # logger.debug "count: #{get_tags.size}"
    get_tags.delete(get_tags.find(tags_to_delete))
    # logger.debug "count: #{get_tags.size}"
    get_tags.each do |tag|
      tag.implied_tags.each do |child|
        add_tag(child)
      end
    end
    # logger.debug "count: #{get_tags.size}"

  end

end
