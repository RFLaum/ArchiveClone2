module Taggable
  extend ActiveSupport::Concern

  def add_tag(tag, type = nil)
    tag_holder = get_tags(type)
    add_tag_with_holder(tag, tag_holder)
  end

  def add_tag_with_holder(tag, holder)
    add_unless_present(holder, tag)
  end

  def set_tags_directly(tag_arr, clear_existing = false, type = nil)
    hldr = get_tags(type)
    if clear_existing
      #this causes problems because the after_add callback is called *before*
      #the replace is finished going, so if tag A implies tag B, and we have the
      #string A, B, then B will get added a second time
      # hldr.replace(tag_arr)

      #can't use hldr.clear, because it doesn't fire the after_remove callback
      hldr.replace([])
    end
    tag_arr.each do |tag|
      add_tag_with_holder(tag, hldr)
    end
  end

  def set_tags(tag_name_arr, clear_existing = false, type = nil)
    klass = tag_class(type)
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
    get_tags(type).map(&:name).join(", ")
  end

  def tags_public=(new_tags_string)
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
    delete_only(tags_to_delete, tag_holder, get_prim_key)
    add_missing_imps(tag_holder)
  end

  def get_prim_key; :id; end

  def delete_only(tags_del, tag_holder, prim_key)
    # this causes problems if asked to delete a tag that wasn't there in the
    #first place
    # tag_holder.delete(tag_holder.find(tags_del))
    tag_holder.delete(tag_holder.where(prim_key => tags_del))
  end

  def add_missing_imps(tag_holder, type = nil)
    dest_coll = get_tags(type)
    tag_holder.each do |tag|
      tag.implied_tags.each do |child|
        # add_tag(child, type)
        add_tag_with_holder(child, dest_coll)
      end
    end
  end

  def add_obj(obj)
    add_tag_with_holder(obj, get_tags(obj.class.to_s.downcase.to_sym))
  end

  def add_kids(obj)
    obj.implied_tags.each do |child|
      add_obj(child)
    end
  end
end
