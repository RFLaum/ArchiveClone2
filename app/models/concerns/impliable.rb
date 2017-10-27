require 'set'

module Impliable
  extend ActiveSupport::Concern

  #if A implies B implies C, then deleting B makes A imply c
  # before_destroy do
  def knit_implications
    implying_tags.each do |parent|
      before = parent.implied_tags
      implied_tags.each do |child|
        # before << child unless before.include?(child)
        #TODO: test this
        add_unless_present(before, child)
      end
    end
  end

  def get_descendant_implications
    self.class.get_descendant_implications(implied_tags)
  end

  #children is a collection of the new child tags
  #returns an array of children that could not be added
  def add_implications(children)
    # new_descs = get_descendant_implications(imp_arr)
    bad_kids = []
    good_kids = []
    # parents = implying_tags.to_set
    children.each do |child|
      # descs = child.get_descendant_implications
      # if child == self || descs.include?(self) #descs.intersect?(parents)
      if child == self || child.get_descendant_implications.include?(self)
        bad_kids << child.name
      else
        good_kids << child
        implied_tags << child
      end
    end

    tagged_objs.each do |obj|
      obj.set_tags_directly(good_kids)
    end
    bad_kids
  end

  def add_imps_by_name(name_str)
    kids = name_str.split(/,\s*/).map do |name|
      self.class.find_or_initialize_by(name: self.class.tr_to_sql(name))
    end
    add_implications(kids)
  end

  module ClassMethods
    def get_descendant_implications(children)
      answer = Set.new
      test_tags = children.dup
      until test_tags.empty?
        tag = test_tags.pop
        test_tags.concat(tag.implied_tags) if answer.add?(tag)
      end
      answer
    end
  end

end
