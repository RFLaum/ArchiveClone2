class Implication < ApplicationRecord
  belongs_to :spec_tag, class_name: 'Tag', foreign_key: 'implier',
                        primary_key: 'name'
  belongs_to :gen_tag, class_name: 'Tag', foreign_key: 'implied',
                       primary_key: 'name'
end
