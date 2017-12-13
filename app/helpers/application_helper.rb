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

  #if a given collection is present in params, get item associated with key
  #otherwise, return nil
  # def param_col_value(col_name, key)
  #   return nil unless params[col_name]
  #   params[col_name][key]
  # end

  def cloud_sizer(klass, story_set, classes, max_tags = 100)
    num_classes = classes.size
    relation = klass.most_common(story_set, max_tags)
    min = relation.first.cnt
    max = relation.last.cnt
    bucket_size = (max - min).to_f / num_classes

    answer = []
    # num_classes.times do
    #   answer << []
    # end

    relation = relation.reorder('name ASC')

    relation.each do |rec|
      bucket_num = [((rec.cnt - min) / bucket_size).to_i, num_classes - 1].min
      answer << name_link(rec, { class: classes[bucket_num] })
    end
    answer
  end
end
