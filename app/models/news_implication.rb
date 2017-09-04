class NewsImplication < ApplicationRecord
  belongs_to :spec_tag, class_name: 'NewsTag', foreign_key: 'implier_id'
  belongs_to :gen_tag, class_name: 'NewsTag', foreign_key: 'implied_id'
end
