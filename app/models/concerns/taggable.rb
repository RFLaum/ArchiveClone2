module Taggable
  extend ActiveSupport::Concern

  def add_tag(tag, type = nil)
    tag_holder = get_tags(type)
    # unless tag_holder.include?(tag)
    #   tag_holder << tag
    #   tag.implied_tags.each do |child|
    #     add_tag(child, type)
    #   end
    # end
    # if add_unless_present(tag_holder, tag)
    #   tag.implied_tags.each do |child|
    #     add_tag(child, type)
    #   end
    # end
    add_tag_with_holder(tag, tag_holder)
  end

  def add_tag_with_holder(tag, holder)
    # if add_unless_present(holder, tag)
    #   tag.implied_tags.each do |child|
    #     add_tag_with_holder(child, holder)
    #   end
    # end
    add_unless_present(holder, tag)
  end

  def set_tags_directly(tag_arr, clear_existing = false, type = nil)
    hldr = get_tags(type)
    # hldr.clear if clear_existing
    if clear_existing
      hldr.replace(tag_arr)
      # tag_arr.each do |tag|
      #   tag.implied_tags.each do |child|
      #     add_tag_with_holder(child, hldr)
      #   end
      # end
    else
      tag_arr.each do |tag|
        add_tag_with_holder(tag, hldr)
      end
    end
  end

  def set_tags(tag_name_arr, clear_existing = false, type = nil)
    klass = tag_class(type)
    # name_att = klass.method_defined?(:name) ? :name : :title
    tag_arr = tag_name_arr.map do |name|
      cooked_name = klass.tr_to_sql(name)
      klass.find_or_initialize_by(name: cooked_name)
    end
    set_tags_directly(tag_arr, clear_existing, type)
  end

  def set_tag_string(tag_str, clear_existing = false, type = nil)
    set_tags(tag_str.split(/,\s*/), clear_existing, type)
  end

  def tags_public(type = nil)
    # name_att = tag_class(type).method_defined?(:name) ? :name : :title
    get_tags(type).map(&:name).join(", ")
  end

  def tags_public=(new_tags_string)
    # set_tag_string(new_tags_string, true, type)
    tags_public_internal(new_tags_string)
  end

  def tags_public_internal(new_tags_string, type = nil)
    set_tag_string(new_tags_string, true, type)
  end

  def tags_add=(new_tags_string, type = nil)
    set_tag_string(new_tags_string, false, type)
  end

  def deleted_tags=(tags_to_delete)
    tag_holder = get_tags
    # tag_holder.delete(tag_holder.find(tags_to_delete))
    delete_only(tags_to_delete, tag_holder)
    add_missing_imps(tag_holder)
  end

  def delete_only(tags_del, tag_holder)
    tag_holder.delete(tag_holder.find(tags_del))
  end

  def add_missing_imps(tag_holder, type = nil)
    tag_holder.each do |tag|
      tag.implied_tags.each do |child|
        add_tag(child, type)
      end
    end
  end

  def add_obj(obj)
    get_tags(obj.class.to_s.downcase.to_sym) << obj
  end

  def add_kids(obj)
    obj.implied_tags.each do |child|
      add_obj(child)
    end
  end
end
