module ApplicationHelper
  def generate_hash
    Digest::SHA1.hexdigest(Time.now.to_s.split('').shuffle.join)
  end

  def name_link(model, opts = nil)
    link_to model.display_name, model, opts
  end

  def link_name(klass, name, opts = nil)
    link_to name, klass.find_by(klass.name_field => name), opts
  end

  #creates it if it doesn't already exist
  #TODO: remove any uses of this in production code
  def link_name2(klass, name, opts = nil)
    obj = klass.find_or_create_by(klass.name_field => name)
    link_to name, obj, opts
  end

  #if a given collection is present in params, get item associated with key
  #otherwise, return nil
  # def param_col_value(col_name, key)
  #   return nil unless params[col_name]
  #   params[col_name][key]
  # end

  # def cloud_sizer(klass, story_set, classes, max_tags = 100)
  #   num_classes = classes.size
  #   relation = klass.most_common(story_set, max_tags)
  #   min = relation.last.cnt
  #   max = relation.first.cnt
  #   bucket_size = (max - min).to_f / num_classes
  #
  #   relation = relation.reorder('name ASC')
  #
  #   unless bucket_size > 0
  #     return relation.map { |rec| name_link(rec, title: pluralize(rec.cnt, 'story'))}
  #   end
  #
  #   answer = []
  #   relation.each do |rec|
  #     bucket_num = [((rec.cnt - min) / bucket_size).to_i, num_classes - 1].min
  #     answer << name_link(rec, class: classes[bucket_num],
  #                              title: pluralize(rec.cnt, "story"))
  #   end
  #   answer
  # end

  def cloud_sizer(raw_data, classes)
    num_classes = classes.size
    tags = raw_data[0]
    min = raw_data[1]
    max = raw_data[2]
    bucket_size = (max - min).to_f / num_classes

    unless bucket_size > 0
      return tags.map do |tag|
        name_link(tag, title: pluralize(tag.stories_count, 'story'))
      end
    end

    tags.map do |tag|
      bucket_num = ((tag.stories_count - min) / bucket_size).to_i
      bucket_num = [bucket_num, num_classes - 1].min
      name_link(tag, class: classes[bucket_num],
                     title: pluralize(tag.stories_count, 'story'))
    end
  end
end
