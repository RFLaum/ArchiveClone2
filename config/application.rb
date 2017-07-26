require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArchiveClone2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_view.sanitized_allowed_tags = [
      'abbr', 'acronym', 'address', 'b', 'big', 'blockquote', 'br', 'caption',
      'center', 'cite', 'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'div',
      'dl', 'dt', 'em', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'i', 'img',
      'ins', 'kbd', 'li', 'ol', 'p', 'pre', 'q', 's', 'samp', 'small', 'span',
      'strike', 'strong', 'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th',
      'thead', 'tr', 'tt', 'u', 'ul', 'var'
    ]
    config.action_view.sanitized_allowed_attributes = [
      'align', 'alt', 'axis', 'class', 'height', 'name', 'src', 'title', 'width'
    ]
  end
end
