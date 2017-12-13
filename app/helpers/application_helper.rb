module ApplicationHelper
  def generate_hash
    Digest::SHA1.hexdigest(Time.now.to_s.split('').shuffle.join)
  end

  def name_link(model, opts = nil)
    # if model.respond_to?(:name) #model.attributes.key?("name")
    #   link_to model.name, model
    # elsif model.respond_to?(:title) #model.attributes.key?("title")
    #   link_to model.title, model
    # else
    #   raise ArgumentError, "no name field"
    # end
    link_to model.display_name, model, opts
  end

  def link_name(klass, name, opts = nil)
    link_to name, klass.find_by(klass.name_field => name), opts
  end

  #if a given collection is present in params, get item associated with key
  #otherwise, return nil
  # def param_col_value(col_name, key)
  #   return nil unless params[col_name]
  #   params[col_name][key]
  # end

  def cloud_sizer(klass, story_set, classes, max_tags = 100)
    num_classes = classes.size
    relation = klass.most_common(story_set, max_tags)
    min = relation.last.cnt
    max = relation.first.cnt
    bucket_size = (max - min).to_f / num_classes

    relation = relation.reorder('name ASC')

    unless bucket_size > 0
      return relation.map { |rec| name_link(rec, title: pluralize(rec.cnt, 'story'))}
    end

    answer = []
    relation.each do |rec|
      bucket_num = [((rec.cnt - min) / bucket_size).to_i, num_classes - 1].min
      answer << name_link(rec, class: classes[bucket_num],
                               title: pluralize(rec.cnt, "story"))
    end
    answer
  end
end
