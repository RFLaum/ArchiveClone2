module Nameclean
  extend ActiveSupport::Concern

  def to_param
    prim_val.gsub('*', '***')
            .gsub('/', '*s*')
            .gsub('&', '*a*')
            .gsub('.', '*d*')
            .gsub('?', '*q*')
            .gsub('#', '*h*')
  end

  module ClassMethods

    def un_param(str)
      # while pos = str.index('*')
      # end
      # str = str.gsub('***', '*')
      # str = str.gsub('***', '*')
      #          .gsub('*s*', '/')
      #          .gsub('*a*', '&')
      #          .gsub('*d*', '.')
      #          .gsub('*q*', '?')
      #          .gsub('*h*', '?')
      # find_by(name: str)
      str.gsub('***', '*')
         .gsub('*s*', '/')
         .gsub('*a*', '&')
         .gsub('*d*', '.')
         .gsub('*q*', '?')
         .gsub('*h*', '?')
    end

  end
end
