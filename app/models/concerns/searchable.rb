module Searchable
  extend ActiveSupport::Concern
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks

  module ClassMethods
    def convert_query(raw_query, field_name, q = where('true'), complete = false)
      padder = '(% )?'
      # query = raw_query.downcase.strip
      query = raw_query.downcase.squish
      #note that the final query uses the SQL standard's definition of a regular
      #expression, which is an unusual one
      query.gsub!(/[\\\[\]\+\{\}\^\$\(\)_%]/, '\\<\1>')
      #squeeze all whitespace; preferable to squeeze! because it handles ALL
      #whitespace, not just spaces
      # query.gsub!(/\s+/, ' ')
      #remove spaces around pipes
      query.gsub!(/\s?\|\s?/, '|')
      #remove spaces after - (negate symbol)
      query.gsub!('- ', '-')
      #remove standalone wildcards
      query.gsub!(/[\A ][\*\?][\z ]/, '')
      #remove characters that are meaningless as last character
      query.chop! if ['|', '-'].include?(query[-1])
      query = query[1..-1] if query[0] == '|'
      query += '"' if query.count('"').odd?

      query.tr!('?*', '_%')

      terms = query.scan(/(("[^"]*"|\S)+)/).map { |x| x[0] }

      terms.each do |term|
        is_negated = term[0] == '-'
        term = term[1..-1] if is_negated
        # this_string = field_name + ' SIMILAR TO ?'
        this_string = "LOWER(#{field_name}) SIMILAR TO ?"
        if complete
          cooked_term = term.delete('"')
        else
          cooked_term = padder + term.delete('"') + padder
        end
        q = is_negated ? q.where.not(this_string, cooked_term) : q.where(this_string, cooked_term)
        # q = q.where(this_string, '(% )?' + term.delete('"') + '( %)?')
      end

      q
    end

    #field_name and query are strings
    # def convert_elastic(field_name, query)
    #   __elasticsearch__.search(
    #     query: {
    #       query_string: {
    #         default_field: field_name,
    #         default_operator: 'AND',
    #         query: query
    #       }
    #     }
    #   ).records
    # end

    def convert_time(raw_string)
      cooked = raw_string.gsub('&gt;', '>')
      cooked.gsub!('&lt;', '<')
      cooked.downcase!

      answer = {}
      #1st group is operand, 2nd is number, 3rd is unit, 4th is discarded
      #note that [0] is the whole thing, so we start from index 1
      parts = cooked.match(/^([<>]?)([\d\s-]+)(year|week|month|day|hour)s?(\s*ago)?\s*$/)
      return answer unless parts

      dash_loc = parts[2].index('-')
      if dash_loc
        answer[:min] = time_range_parse(parts[2][0...dash_loc], parts[3])
        answer[:max] = time_range_parse(parts[2][(dash_loc + 1)..-1], parts[3])
      else
        time = time_range_parse(parts[2], parts[3])
        case parts[1]
        when '<'
          answer[:min] = time
        when '>'
          answer[:max] = time
        when ''
          answer[:min] = time.send("beginning_of_#{parts[3]}")
          answer[:max] = time.send("end_of_#{parts[3]}")
        end
      end

      answer
    end

    def time_range_parse(num, unit)
      num.to_i.send(unit).ago
    end

  end
end
